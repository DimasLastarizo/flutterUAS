-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Update video pembuka (intro_video_url) semua mata pelajaran
-- Jalankan di Supabase Cloud → SQL Editor
--
-- Kolom: courses.intro_video_url (1 URL YouTube per mata pelajaran)
-- App Flutter membaca URL ini dan menampilkan player YouTube di halaman Materi
-- (detail mata pelajaran → tab/bagian video pembuka di atas bacaan).
--
-- Setelah run:
--   1. Tutup app sepenuhnya (jangan hot reload saja)
--   2. flutter run ke Supabase Cloud
--   3. Buka Materi → pilih tiap mata pelajaran → pastikan video YouTube tampil
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK DATA SEBELUM UPDATE (jalankan dulu, catat id jika berbeda) ───
SELECT
  id,
  sort_order,
  title,
  intro_video_url,
  CASE
    WHEN intro_video_url = '' OR intro_video_url IS NULL THEN 'KOSONG'
    ELSE 'SUDAH ADA'
  END AS status_video
FROM courses
ORDER BY sort_order;

-- Harusnya ada 5 baris:
-- 1 | Dasar Pemrograman
-- 2 | Algoritma & Struktur Data
-- 3 | Basis Data
-- 4 | Jaringan Komputer
-- 5 | Kecerdasan Buatan


-- ─── 1. DASAR PEMROGRAMAN (course_id = 1) ─────────────────────────────────
UPDATE courses
SET intro_video_url = 'https://youtu.be/jGyYuQf-GeE?si=81QBd4Pkhegi2K79'
WHERE id = 1;


-- ─── 2. ALGORITMA & STRUKTUR DATA (course_id = 2) ─────────────────────────
UPDATE courses
SET intro_video_url = 'https://youtu.be/hK_D4gIrpZc?si=6S0b5NVCUzthWmcx'
WHERE id = 2;


-- ─── 3. BASIS DATA (course_id = 3) ────────────────────────────────────────
UPDATE courses
SET intro_video_url = 'https://youtu.be/1ts-kEBCXrg?si=h8yJERP01A2LErJW'
WHERE id = 3;


-- ─── 4. JARINGAN KOMPUTER (course_id = 4) ─────────────────────────────────
UPDATE courses
SET intro_video_url = 'https://youtu.be/xT58k6AB7gk?si=fK25thJP965DnD9rki'
WHERE id = 4;


-- ─── 5. KECERDASAN BUATAN (course_id = 5) ─────────────────────────────────
UPDATE courses
SET intro_video_url = 'https://youtu.be/je-rUgH7aaY?si=gNx7AjHFfAiEu90-'
WHERE id = 5;


-- ─── 6. VERIFIKASI SETELAH UPDATE ─────────────────────────────────────────
SELECT
  id,
  sort_order,
  title,
  intro_video_url,
  CASE
    WHEN intro_video_url = '' OR intro_video_url IS NULL THEN '❌ KOSONG'
    ELSE '✅ TERISI'
  END AS status_video
FROM courses
ORDER BY sort_order;

-- Harusnya semua status_video = ✅ TERISI
--
-- Referensi video ID (untuk cek manual di browser):
-- 1 | Dasar Pemrograman           → jGyYuQf-GeE
-- 2 | Algoritma & Struktur Data   → hK_D4gIrpZc
-- 3 | Basis Data                  → 1ts-kEBCXrg
-- 4 | Jaringan Komputer           → xT58k6AB7gk
-- 5 | Kecerdasan Buatan           → je-rUgH7aaY
