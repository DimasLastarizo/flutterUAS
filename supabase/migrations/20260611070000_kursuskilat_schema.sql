-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — schema backend
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── Meta versi konten ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS content_meta (
  id          int PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  version     int NOT NULL DEFAULT 1,
  published_at timestamptz NOT NULL DEFAULT now(),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

INSERT INTO content_meta (id, version) VALUES (1, 1) ON CONFLICT (id) DO NOTHING;

-- ─── Profil user (terhubung ke auth.users) ───────────────────────────────────
CREATE TABLE IF NOT EXISTS profiles (
  id         uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username   text UNIQUE NOT NULL,
  nama       text NOT NULL,
  email      text NOT NULL,
  role       text NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  xp         int NOT NULL DEFAULT 0,
  level      int NOT NULL DEFAULT 1,
  streak     int NOT NULL DEFAULT 0,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_profiles_username ON profiles (lower(username));

-- ─── Kursus / materi (daftar di tab Materi) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS courses (
  id              serial PRIMARY KEY,
  emoji           text NOT NULL,
  category        text NOT NULL,
  title           text NOT NULL,
  instructor      text NOT NULL DEFAULT 'KursusKilat',
  description     text NOT NULL DEFAULT '',
  total_duration  text NOT NULL DEFAULT '',
  rating          text NOT NULL DEFAULT '-',
  total_students  text NOT NULL DEFAULT '',
  modules_total   int NOT NULL DEFAULT 4,
  accent_start    bigint NOT NULL,
  accent_end      bigint NOT NULL,
  sort_order      int NOT NULL DEFAULT 0,
  is_published    boolean NOT NULL DEFAULT true,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- ─── Level game ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS game_levels (
  id              serial PRIMARY KEY,
  level_number    int UNIQUE NOT NULL,
  title           text NOT NULL,
  topic           text NOT NULL,
  module_index    int NOT NULL DEFAULT 0,
  questions_count int NOT NULL DEFAULT 5,
  default_status  text NOT NULL DEFAULT 'terkunci'
    CHECK (default_status IN ('selesai', 'aktif', 'terkunci')),
  default_stars   int NOT NULL DEFAULT 0,
  sort_order      int NOT NULL DEFAULT 0,
  is_published    boolean NOT NULL DEFAULT true
);

-- ─── Bank soal quiz ──────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS questions (
  id            serial PRIMARY KEY,
  module_index  int NOT NULL,
  sort_order    int NOT NULL,
  category      text NOT NULL,
  question      text NOT NULL,
  options       jsonb NOT NULL,
  answer_index  int NOT NULL,
  explanation   text NOT NULL DEFAULT '',
  is_published  boolean NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_questions_module ON questions (module_index, sort_order);

-- ─── Progress level per user ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS user_level_progress (
  user_id       uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  level_number  int NOT NULL,
  status        text NOT NULL CHECK (status IN ('selesai', 'aktif', 'terkunci')),
  stars         int NOT NULL DEFAULT 0,
  updated_at    timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, level_number)
);

-- ─── Leaderboard ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS leaderboard_entries (
  id           uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id      uuid REFERENCES profiles(id) ON DELETE SET NULL,
  display_name text NOT NULL,
  initials     text NOT NULL,
  xp           int NOT NULL DEFAULT 0,
  level        int NOT NULL DEFAULT 1,
  badges       text[] NOT NULL DEFAULT '{}',
  avatar_bg    bigint NOT NULL,
  avatar_text  bigint NOT NULL,
  period_type  text NOT NULL CHECK (period_type IN ('minggu', 'bulan', 'semua')),
  is_seed      boolean NOT NULL DEFAULT false,
  updated_at   timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_leaderboard_period ON leaderboard_entries (period_type, xp DESC);

-- ─── Trigger: buat profil saat user daftar ───────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, username, nama, email)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'nama', 'User'),
    NEW.email
  );
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── RPC: login pakai username ───────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.get_email_for_username(p_username text)
RETURNS text
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT email FROM profiles WHERE lower(username) = lower(p_username) LIMIT 1;
$$;

GRANT EXECUTE ON FUNCTION public.get_email_for_username(text) TO anon, authenticated;

-- ─── RPC: cek username tersedia ──────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_username_available(p_username text)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
  SELECT NOT EXISTS (
    SELECT 1 FROM profiles WHERE lower(username) = lower(p_username)
  );
$$;

GRANT EXECUTE ON FUNCTION public.is_username_available(text) TO anon, authenticated;

-- ─── RLS ─────────────────────────────────────────────────────────────────────
ALTER TABLE content_meta ENABLE ROW LEVEL SECURITY;
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE game_levels ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_level_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE leaderboard_entries ENABLE ROW LEVEL SECURITY;

-- content_meta: semua boleh baca
CREATE POLICY "content_meta_read" ON content_meta FOR SELECT TO anon, authenticated USING (true);

-- profiles
CREATE POLICY "profiles_read_own" ON profiles FOR SELECT TO authenticated
  USING (auth.uid() = id);
CREATE POLICY "profiles_read_public_leaderboard" ON profiles FOR SELECT TO authenticated
  USING (true);
CREATE POLICY "profiles_update_own" ON profiles FOR UPDATE TO authenticated
  USING (auth.uid() = id) WITH CHECK (auth.uid() = id);

-- courses, levels, questions: baca jika published
CREATE POLICY "courses_read" ON courses FOR SELECT TO anon, authenticated
  USING (is_published = true);
CREATE POLICY "game_levels_read" ON game_levels FOR SELECT TO anon, authenticated
  USING (is_published = true);
CREATE POLICY "questions_read" ON questions FOR SELECT TO anon, authenticated
  USING (is_published = true);

-- user progress
CREATE POLICY "progress_read_own" ON user_level_progress FOR SELECT TO authenticated
  USING (auth.uid() = user_id);
CREATE POLICY "progress_write_own" ON user_level_progress FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);
CREATE POLICY "progress_update_own" ON user_level_progress FOR UPDATE TO authenticated
  USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- leaderboard: semua boleh baca
CREATE POLICY "leaderboard_read" ON leaderboard_entries FOR SELECT TO anon, authenticated
  USING (true);
CREATE POLICY "leaderboard_upsert_own" ON leaderboard_entries FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR user_id IS NULL);
CREATE POLICY "leaderboard_update_own" ON leaderboard_entries FOR UPDATE TO authenticated
  USING (user_id = auth.uid());
