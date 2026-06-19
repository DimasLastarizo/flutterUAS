-- Restore table privileges setelah DROP/CREATE di schema v2.
-- Tanpa ini, Flutter (role authenticated/anon) gagal SELECT meski RLS sudah benar.

GRANT SELECT ON TABLE public.content_meta TO anon, authenticated;
GRANT SELECT, UPDATE ON TABLE public.profiles TO authenticated;
GRANT SELECT ON TABLE public.profiles TO anon, authenticated;
GRANT SELECT ON TABLE public.courses TO anon, authenticated;
GRANT SELECT ON TABLE public.materials TO anon, authenticated;
GRANT SELECT ON TABLE public.game_levels TO anon, authenticated;
GRANT SELECT ON TABLE public.questions TO anon, authenticated;
GRANT SELECT, INSERT, UPDATE ON TABLE public.user_level_progress TO authenticated;
GRANT SELECT ON TABLE public.leaderboard_entries TO anon, authenticated;
GRANT INSERT, UPDATE ON TABLE public.leaderboard_entries TO authenticated;

-- Sequence usage for serial inserts (seed / admin)
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO anon, authenticated;
