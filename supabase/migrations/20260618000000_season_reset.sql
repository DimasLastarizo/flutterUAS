-- ═══════════════════════════════════════════════════════════════════════════
-- Reset season bulanan: leaderboard bulan + XP + progress game
-- Dipicu lazy saat user login (RPC reset_season_if_needed), tanpa pg_cron.
-- ═══════════════════════════════════════════════════════════════════════════

ALTER TABLE content_meta
  ADD COLUMN IF NOT EXISTS season_key text;

UPDATE content_meta
SET season_key = to_char(timezone('Asia/Jakarta', now()), 'YYYY-MM')
WHERE id = 1 AND season_key IS NULL;

-- ─── Helper: kunci season aktif (YYYY-MM, timezone Jakarta) ─────────────────
CREATE OR REPLACE FUNCTION public.current_season_key()
RETURNS text
LANGUAGE sql
STABLE
AS $$
  SELECT to_char(timezone('Asia/Jakarta', now()), 'YYYY-MM');
$$;

-- ─── RPC: reset global jika bulan berganti ───────────────────────────────────
CREATE OR REPLACE FUNCTION public.reset_season_if_needed()
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current text := public.current_season_key();
  v_did_reset boolean := false;
BEGIN
  IF auth.uid() IS NULL THEN
    RETURN jsonb_build_object('reset', false, 'season', v_current);
  END IF;

  -- Hanya satu transaksi yang menang jika banyak user buka app bersamaan.
  UPDATE content_meta
  SET season_key = v_current,
      updated_at = now()
  WHERE id = 1
    AND (season_key IS NULL OR season_key <> v_current);

  IF NOT FOUND THEN
    RETURN jsonb_build_object('reset', false, 'season', v_current);
  END IF;

  -- Leaderboard season aktif — tidak simpan history.
  DELETE FROM leaderboard_entries
  WHERE period_type = 'bulan';

  -- XP season user kembali nol.
  UPDATE profiles SET
    xp = 0,
    level = 1,
    total_completed_levels = 0,
    updated_at = now();

  -- Progress game kembali ke awal.
  DELETE FROM user_level_progress;

  INSERT INTO user_level_progress (user_id, level_number, status, stars, score, xp_earned)
  SELECT id, 1, 'aktif', 0, 0, 0
  FROM profiles
  ON CONFLICT (user_id, level_number) DO UPDATE SET
    status = 'aktif',
    stars = 0,
    score = 0,
    xp_earned = 0,
    updated_at = now();

  v_did_reset := true;

  RETURN jsonb_build_object('reset', v_did_reset, 'season', v_current);
END;
$$;

GRANT EXECUTE ON FUNCTION public.reset_season_if_needed() TO authenticated;

-- ─── Quiz: sinkron leaderboard ke season aktif (bulan) ───────────────────────
CREATE OR REPLACE FUNCTION public.submit_level_result(
  p_level_number int,
  p_correct_count int
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id        uuid := auth.uid();
  v_stars          int;
  v_old_score      int := 0;
  v_old_xp         int := 0;
  v_xp_delta       int := 0;
  v_first_complete boolean := false;
  v_profile        profiles%ROWTYPE;
  v_initials       text;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_correct_count < 0 OR p_correct_count > 10 THEN
    RAISE EXCEPTION 'Invalid correct count (0-10)';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM game_levels WHERE level_number = p_level_number AND is_published
  ) THEN
    RAISE EXCEPTION 'Level not found';
  END IF;

  PERFORM public.reset_season_if_needed();
  PERFORM public.ensure_user_progress();

  v_stars := public.calc_stars(p_correct_count);

  SELECT score, xp_earned
  INTO v_old_score, v_old_xp
  FROM user_level_progress
  WHERE user_id = v_user_id AND level_number = p_level_number;

  IF FOUND THEN
    IF p_correct_count > v_old_score THEN
      v_xp_delta := p_correct_count - v_old_score;
    END IF;
    IF v_old_score = 0 AND p_correct_count >= 1 THEN
      v_first_complete := true;
    END IF;
    UPDATE user_level_progress SET
      status     = 'selesai',
      stars      = GREATEST(stars, v_stars),
      score      = GREATEST(score, p_correct_count),
      xp_earned  = GREATEST(xp_earned, p_correct_count),
      updated_at = now()
    WHERE user_id = v_user_id AND level_number = p_level_number;
  ELSE
    v_xp_delta := p_correct_count;
    v_first_complete := p_correct_count >= 1;
    INSERT INTO user_level_progress (
      user_id, level_number, status, stars, score, xp_earned
    ) VALUES (
      v_user_id, p_level_number, 'selesai', v_stars, p_correct_count, p_correct_count
    );
  END IF;

  IF NOT v_first_complete AND p_correct_count >= 1 AND v_old_score = 0 THEN
    v_first_complete := true;
  END IF;

  IF p_correct_count >= 1 THEN
    INSERT INTO user_level_progress (user_id, level_number, status, stars, score, xp_earned)
    VALUES (v_user_id, p_level_number + 1, 'aktif', 0, 0, 0)
    ON CONFLICT (user_id, level_number) DO UPDATE SET
      status = CASE
        WHEN user_level_progress.status = 'terkunci' THEN 'aktif'
        ELSE user_level_progress.status
      END,
      updated_at = now()
    WHERE user_level_progress.status = 'terkunci';
  END IF;

  IF v_xp_delta > 0 OR v_first_complete THEN
    UPDATE profiles SET
      xp = xp + v_xp_delta,
      level = public.calc_user_level(xp + v_xp_delta),
      total_completed_levels = total_completed_levels + CASE WHEN v_first_complete THEN 1 ELSE 0 END,
      updated_at = now()
    WHERE id = v_user_id
    RETURNING * INTO v_profile;

    v_initials := upper(
      left(split_part(v_profile.nama, ' ', 1), 1) ||
      coalesce(left(split_part(v_profile.nama, ' ', 2), 1), '')
    );

    INSERT INTO leaderboard_entries (
      user_id, display_name, initials, xp, level,
      badges, avatar_bg, avatar_text, period_type, is_seed, updated_at
    ) VALUES (
      v_user_id,
      v_profile.nama,
      v_initials,
      v_profile.xp,
      v_profile.level,
      '{}'::text[],
      4278845472,
      4286578704,
      'bulan',
      false,
      now()
    )
    ON CONFLICT (user_id, period_type) WHERE user_id IS NOT NULL DO UPDATE SET
      display_name = EXCLUDED.display_name,
      initials     = EXCLUDED.initials,
      xp           = EXCLUDED.xp,
      level        = EXCLUDED.level,
      is_seed      = false,
      updated_at   = now();
  ELSE
    SELECT * INTO v_profile FROM profiles WHERE id = v_user_id;
  END IF;

  RETURN jsonb_build_object(
    'level_number',   p_level_number,
    'correct_count',  p_correct_count,
    'stars',          v_stars,
    'xp_delta',       v_xp_delta,
    'total_xp',       v_profile.xp,
    'user_level',     v_profile.level,
    'unlocked_next',  p_correct_count >= 1
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.submit_level_result(int, int) TO authenticated;
