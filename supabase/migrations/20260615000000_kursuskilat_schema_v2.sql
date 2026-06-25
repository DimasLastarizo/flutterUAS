-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — schema v2 (courses → materials → game_levels → questions)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Drop struktur lama (local dev — aman di-reset) ─────────────────────────
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS game_levels CASCADE;
DROP TABLE IF EXISTS materials CASCADE;
DROP TABLE IF EXISTS courses CASCADE;

-- ─── Kolom tambahan profiles ─────────────────────────────────────────────────
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS total_completed_levels int NOT NULL DEFAULT 0;

-- ─── Kolom tambahan user_level_progress ──────────────────────────────────────
ALTER TABLE user_level_progress
  ADD COLUMN IF NOT EXISTS score int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS xp_earned int NOT NULL DEFAULT 0;

-- ─── Mata pelajaran / subject ────────────────────────────────────────────────
CREATE TABLE courses (
  id               serial PRIMARY KEY,
  emoji            text NOT NULL,
  category         text NOT NULL,
  title            text NOT NULL,
  instructor       text NOT NULL DEFAULT 'KursusKilat',
  description      text NOT NULL DEFAULT '',
  intro_video_url  text NOT NULL DEFAULT '',
  total_duration   text NOT NULL DEFAULT '',
  rating           text NOT NULL DEFAULT '-',
  total_students   text NOT NULL DEFAULT '',
  modules_total    int NOT NULL DEFAULT 4,
  accent_start     bigint NOT NULL,
  accent_end       bigint NOT NULL,
  sort_order       int NOT NULL DEFAULT 0,
  is_published     boolean NOT NULL DEFAULT true,
  created_at       timestamptz NOT NULL DEFAULT now()
);

-- ─── Materi di dalam mata pelajaran ──────────────────────────────────────────
CREATE TABLE materials (
  id              serial PRIMARY KEY,
  course_id       int NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
  title           text NOT NULL,
  emoji           text NOT NULL DEFAULT '📘',
  duration_label  text NOT NULL DEFAULT 'Ringkas',
  content         text NOT NULL DEFAULT '',
  key_points      jsonb NOT NULL DEFAULT '[]'::jsonb,
  sort_order      int NOT NULL DEFAULT 0,
  is_published    boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_materials_course ON materials (course_id, sort_order);

-- ─── Level game (1 level = 1 materi) ─────────────────────────────────────────
CREATE TABLE game_levels (
  id                   serial PRIMARY KEY,
  level_number         int UNIQUE NOT NULL,
  material_id          int NOT NULL REFERENCES materials(id),
  title                text NOT NULL,
  topic                text NOT NULL,
  topic_category_index int NOT NULL DEFAULT 0,
  course_index         int NOT NULL DEFAULT 0,
  material_index       int NOT NULL DEFAULT 0,
  questions_count      int NOT NULL DEFAULT 10,
  default_status       text NOT NULL DEFAULT 'terkunci'
    CHECK (default_status IN ('selesai', 'aktif', 'terkunci')),
  default_stars        int NOT NULL DEFAULT 0,
  sort_order           int NOT NULL DEFAULT 0,
  is_published         boolean NOT NULL DEFAULT true
);

CREATE INDEX idx_game_levels_material ON game_levels (material_id);

-- ─── Soal quiz (10 soal per level) ───────────────────────────────────────────
CREATE TABLE questions (
  id            serial PRIMARY KEY,
  level_id      int NOT NULL REFERENCES game_levels(id) ON DELETE CASCADE,
  sort_order    int NOT NULL,
  category      text NOT NULL,
  question      text NOT NULL,
  options       jsonb NOT NULL,
  answer_index  int NOT NULL,
  explanation   text NOT NULL DEFAULT '',
  is_published  boolean NOT NULL DEFAULT true,
  UNIQUE (level_id, sort_order)
);

CREATE INDEX idx_questions_level ON questions (level_id, sort_order);

-- ─── Leaderboard: unique per user per periode ────────────────────────────────
CREATE UNIQUE INDEX IF NOT EXISTS idx_leaderboard_user_period
  ON leaderboard_entries (user_id, period_type)
  WHERE user_id IS NOT NULL;

-- ─── RLS policies baru ───────────────────────────────────────────────────────
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "courses_read" ON courses FOR SELECT TO anon, authenticated
  USING (is_published = true);
CREATE POLICY "game_levels_read" ON game_levels FOR SELECT TO anon, authenticated
  USING (is_published = true);
CREATE POLICY "questions_read" ON questions FOR SELECT TO anon, authenticated
  USING (is_published = true);

CREATE POLICY "materials_read" ON materials FOR SELECT TO anon, authenticated
  USING (is_published = true);

-- ─── Helper: hitung stars dari jumlah benar ──────────────────────────────────
CREATE OR REPLACE FUNCTION public.calc_stars(p_correct int)
RETURNS int
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT CASE
    WHEN p_correct >= 8 THEN 3
    WHEN p_correct >= 5 THEN 2
    WHEN p_correct >= 1 THEN 1
    ELSE 0
  END;
$$;

-- ─── Helper: hitung level dari XP ────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.calc_user_level(p_xp int)
RETURNS int
LANGUAGE sql
IMMUTABLE
AS $$
  SELECT GREATEST(1, (p_xp / 160) + 1);
$$;

-- ─── RPC: inisialisasi progress user baru (level 1 aktif) ───────────────────
CREATE OR REPLACE FUNCTION public.ensure_user_progress()
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN RETURN; END IF;

  IF NOT EXISTS (
    SELECT 1 FROM user_level_progress WHERE user_id = v_user_id
  ) THEN
    INSERT INTO user_level_progress (user_id, level_number, status, stars, score, xp_earned)
    VALUES (v_user_id, 1, 'aktif', 0, 0, 0)
    ON CONFLICT DO NOTHING;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.ensure_user_progress() TO authenticated;

-- ─── RPC: submit hasil quiz level ────────────────────────────────────────────
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
  v_new_xp         int;
  v_new_level      int;
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

  -- Unlock level berikutnya jika skor >= 1
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

  -- Update XP profil
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

    -- Sinkronkan leaderboard periode "semua"
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
      'semua',
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
