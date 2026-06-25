-- Verification: submit_level_result zero-score safety
-- Run: supabase db query --local -f supabase/snippets/test_zero_score.sql

INSERT INTO auth.users (
  id, instance_id, aud, role, email, encrypted_password,
  email_confirmed_at, created_at, updated_at
) VALUES (
  '11111111-1111-1111-1111-111111111111',
  '00000000-0000-0000-0000-000000000000',
  'authenticated', 'authenticated', 'zero-test@example.com',
  crypt('password', gen_salt('bf')), now(), now(), now()
) ON CONFLICT (id) DO NOTHING;

INSERT INTO profiles (id, username, nama, email)
VALUES (
  '11111111-1111-1111-1111-111111111111',
  'zerotest', 'Zero Test', 'zero-test@example.com'
) ON CONFLICT (id) DO NOTHING;

DO $$
DECLARE
  v_user_id uuid := '11111111-1111-1111-1111-111111111111';
  v_result jsonb;
  v_status text;
  v_xp_before int;
  v_xp_after int;
BEGIN
  PERFORM set_config('request.jwt.claim.sub', v_user_id::text, true);
  PERFORM set_config('request.jwt.claim.role', 'authenticated', true);

  DELETE FROM user_level_progress WHERE user_id = v_user_id;
  UPDATE profiles SET xp = 0, total_completed_levels = 0 WHERE id = v_user_id;

  PERFORM public.ensure_user_progress();

  SELECT xp INTO v_xp_before FROM profiles WHERE id = v_user_id;

  v_result := public.submit_level_result(1, 0);
  IF coalesce((v_result->>'unlocked_next')::boolean, true) THEN
    RAISE EXCEPTION 'FAIL: unlocked_next should be false for score 0';
  END IF;
  IF coalesce((v_result->>'xp_delta')::int, -1) <> 0 THEN
    RAISE EXCEPTION 'FAIL: xp_delta should be 0 for score 0';
  END IF;

  SELECT status INTO v_status
  FROM user_level_progress
  WHERE user_id = v_user_id AND level_number = 1;
  IF v_status <> 'aktif' THEN
    RAISE EXCEPTION 'FAIL: level 1 should stay aktif after score 0, got %', v_status;
  END IF;

  SELECT xp INTO v_xp_after FROM profiles WHERE id = v_user_id;
  IF v_xp_after <> v_xp_before THEN
    RAISE EXCEPTION 'FAIL: XP should not change on score 0';
  END IF;

  v_result := public.submit_level_result(1, 5);
  IF NOT coalesce((v_result->>'unlocked_next')::boolean, false) THEN
    RAISE EXCEPTION 'FAIL: unlocked_next should be true for score 5';
  END IF;
  IF coalesce((v_result->>'xp_delta')::int, 0) <> 5 THEN
    RAISE EXCEPTION 'FAIL: xp_delta should be 5 for first score 5';
  END IF;

  SELECT status INTO v_status
  FROM user_level_progress
  WHERE user_id = v_user_id AND level_number = 1;
  IF v_status <> 'selesai' THEN
    RAISE EXCEPTION 'FAIL: level 1 should be selesai after score 5';
  END IF;

  SELECT status INTO v_status
  FROM user_level_progress
  WHERE user_id = v_user_id AND level_number = 2;
  IF v_status <> 'aktif' THEN
    RAISE EXCEPTION 'FAIL: level 2 should be aktif after score 5';
  END IF;

  RAISE NOTICE 'PASS: submit_level_result zero-score safety OK';
END $$;
