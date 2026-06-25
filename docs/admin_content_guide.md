# Panduan Admin: Mengelola Konten KursusKilat via Supabase Dashboard

Dokumen ini ditujukan untuk **developer** dan **admin konten** yang mengisi atau memperbarui materi, level game, dan soal quiz aplikasi KursusKilat **tanpa mengubah kode Flutter**.

---

## 1. Tujuan dokumentasi

Aplikasi Flutter KursusKilat **hanya membaca data** dari Supabase. Aplikasi tidak menyimpan konten final (mata pelajaran, bacaan, level, soal) secara permanen di dalam kode produksi.

| Peran | Tanggung jawab |
|-------|----------------|
| **Flutter app** | Menampilkan data, navigasi, quiz, auth, progress user |
| **Supabase Dashboard** | Menyimpan dan mengelola konten final yang tampil di app |

Artinya:

- Menambah mata pelajaran baru → isi tabel di Supabase, bukan hardcode di Dart.
- Mengubah teks materi atau soal → edit baris di Supabase.
- Menyembunyikan konten draft → set `is_published = false`.

Fallback statis di Flutter (jika ada) hanya cadangan saat koneksi/database kosong. **Konten resmi harus di Supabase.**

---

## 2. Struktur konten aplikasi

Konten KursusKilat disusun berjenjang. Setiap lapisan punya fungsi jelas:

```
courses  →  materials  →  game_levels  →  questions
(mata      (bacaan /      (level di       (10 soal
 pelajaran)  sub-materi)    map game)       pilihan ganda)
```

### Ringkasan hubungan

| Tabel | Fungsi | Relasi |
|-------|--------|--------|
| `courses` | Mata pelajaran / topik besar | Induk dari `materials` |
| `materials` | Materi bacaan dalam satu mata pelajaran | `course_id` → `courses.id` |
| `game_levels` | Level di peta game | `material_id` → `materials.id` |
| `questions` | Soal quiz per level | `level_id` → `game_levels.id` |

### Alur dari sudut pandang user

1. User membuka **Materi** → melihat daftar `courses`.
2. User membuka detail mata pelajaran → membaca `materials` (video pembuka dari `courses.intro_video_url` + bacaan).
3. User bermain di **Game** → menyelesaikan `game_levels`.
4. Setiap level menampilkan **10 soal** dari `questions` yang terhubung ke level tersebut.

---

## 3. Cara mengisi `courses`

Tabel `courses` = **mata pelajaran / topik besar**.

### Contoh mata pelajaran

- Dasar Pemrograman
- Algoritma & Struktur Data
- Basis Data
- Jaringan Komputer
- Kecerdasan Buatan

### Kolom penting

| Kolom | Keterangan |
|-------|------------|
| `title` | Judul mata pelajaran (tampil di app) |
| `emoji` | Ikon/emoji mata pelajaran |
| `category` | Label kategori (mis. `PROGRAMMING`, `NETWORKING`) |
| `description` | Deskripsi singkat mata pelajaran |
| `intro_video_url` | **Video pembuka — 1 URL per mata pelajaran** |
| `modules_total` | Jumlah materi (informasi; usahakan selaras dengan jumlah `materials`) |
| `sort_order` | Urutan tampil di daftar mata pelajaran |
| `is_published` | `true` = tampil di app, `false` = disembunyikan |
| `accent_start`, `accent_end` | Warna aksen kartu (nilai integer ARGB) |

### `intro_video_url`

- Satu mata pelajaran = **satu video pembuka** di bagian atas halaman detail materi.
- Isi dengan URL video (YouTube, CDN, atau hosting lain yang didukung player app).
- Jika masih kosong (`''`), app dapat menampilkan placeholder/simulasi video sampai URL diisi.

### Langkah di Supabase Dashboard

1. Buka **Table Editor** → tabel `courses`.
2. Klik **Insert row**.
3. Isi judul, emoji, deskripsi, dan `intro_video_url`.
4. Set `sort_order` agar urutan daftar rapi.
5. Pastikan `is_published = true` jika siap tampil.

---

## 4. Cara mengisi `materials`

Tabel `materials` = **materi bacaan** di dalam satu mata pelajaran.

### Prinsip urutan

Materi harus diurutkan **dari basic ke advanced** menggunakan `sort_order`:

| sort_order | Contoh judul | Tingkat |
|------------|--------------|---------|
| 1 | Istilah Dasar | Paling dasar |
| 2 | Konsep Inti | Menengah |
| 3 | Hubungan Antar Konsep | Lebih dalam |
| 4 | Pola Soal Kuis | Persiapan quiz |

### Kolom penting

| Kolom | Keterangan |
|-------|------------|
| `course_id` | ID mata pelajaran induk (`courses.id`) |
| `title` | Judul materi |
| `emoji` | Emoji materi |
| `duration_label` | Label durasi (mis. `Ringkas`, `Teori`, `Analisis`) |
| `content` | **Teks bacaan utama** materi |
| `key_points` | **Poin penting** — format JSON array, contoh: `["Definisi konsep utama","Fungsi setiap istilah"]` |
| `sort_order` | Urutan materi (1 = materi pertama / paling basic) |
| `is_published` | Kontrol tampil/tidak |

### Catatan `key_points`

Di Dashboard, isi sebagai **JSON array of strings**, contoh:

```json
["Definisi konsep utama", "Fungsi setiap istilah", "Perbedaan istilah yang mirip"]
```

Materi dengan `sort_order = 1` biasanya menjadi **bacaan utama** pertama yang user baca setelah video pembuka.

---

## 5. Cara mengisi `game_levels`

Tabel `game_levels` = **level di peta game**.

### Aturan utama

- **Setiap level terhubung ke tepat 1 materi** lewat `material_id` → `materials.id`.
- Level dengan `level_number` lebih tinggi sebaiknya mengacu pada materi yang **lebih advance** (atau minimal sejalan progres belajar).
- Satu materi dapat dipakai oleh satu level (relasi 1 level : 1 materi).

### Kolom penting

| Kolom | Keterangan |
|-------|------------|
| `level_number` | Nomor level unik di peta (1, 2, 3, …) |
| `material_id` | FK ke `materials.id` — materi yang menjadi dasar level |
| `title` | Nama level di peta (mis. `Pemanasan`, `Misi Aktif`) |
| `topic` | Topik singkat level |
| `questions_count` | Jumlah soal (standar: **10**) |
| `default_status` | Status awal: `selesai`, `aktif`, atau `terkunci` |
| `default_stars` | Bintang default (0–3) |
| `sort_order` | Urutan di peta |
| `is_published` | Kontrol tampil/tidak |

### Tips mapping level ↔ materi

1. Tentukan mata pelajaran (`course_id` via material).
2. Urutkan materi basic → advanced.
3. Level awal → hubungkan ke materi `sort_order` terkecil dalam topik tersebut.
4. Level berikutnya → materi berikutnya atau materi lanjutan yang relevan.

---

## 6. Cara mengisi `questions`

Tabel `questions` = **bank soal quiz** per level.

### Aturan utama

- **Setiap level berisi 10 soal pilihan ganda.**
- Setiap baris soal **harus terhubung** ke level lewat `level_id` → `game_levels.id`.
- Soal harus **relevan** dengan materi pada level tersebut (lihat `material_id` dari level).
- `sort_order` unik per level (1–10).

### Kolom penting

| Kolom | Keterangan |
|-------|------------|
| `level_id` | FK ke `game_levels.id` |
| `sort_order` | Urutan soal dalam level (1–10) |
| `category` | Label kategori/topik soal (mis. `Jaringan Komputer`) |
| `question` | Teks pertanyaan |
| `options` | **JSON array** pilihan jawaban, contoh: `["HTTP","FTP","SMTP","DNS","SSH"]` |
| `answer_index` | Indeks jawaban benar (**0-based**: 0 = pilihan pertama) |
| `explanation` | Penjelasan setelah user menjawab |
| `is_published` | Kontrol tampil/tidak |

### Contoh satu soal

| Field | Nilai |
|-------|-------|
| `question` | Protokol standar untuk halaman web adalah... |
| `options` | `["FTP","HTTP","SMTP","SSH","DNS"]` |
| `answer_index` | `1` (HTTP = indeks ke-2) |
| `explanation` | HTTP adalah protokol standar web. |

---

## 7. Aturan pengisian konten

Ikuti aturan berikut agar app berperilaku konsisten:

### ✅ Wajib

1. **Jangan isi level secara acak** — `material_id` dan `level_number` harus mengikuti progres belajar.
2. **Jangan isi soal yang tidak sesuai materi** — cek materi level sebelum menulis soal.
3. **Gunakan `is_published`** — set `false` untuk draft; hanya baris `true` yang dibaca app (RLS).
4. **Pastikan `sort_order` rapi** — tanpa duplikat yang membingungkan urutan tampil.
5. **Pastikan 1 level punya 10 soal unik** — tidak ada duplikat teks pertanyaan dalam level yang sama; `sort_order` 1–10 terisi penuh.

### ❌ Hindari

- Level tanpa 10 soal → quiz tidak lengkap.
- Soal dengan `answer_index` di luar rentang `options`.
- `material_id` yang merujuk materi dari mata pelajaran lain.
- `level_number` duplikat (kolom unik).
- `key_points` atau `options` bukan format JSON array valid.

### Checklist sebelum publish

- [ ] Course `is_published = true`
- [ ] Semua materials course tersebut `is_published = true`
- [ ] Level terkait `is_published = true`
- [ ] Tiap level punya tepat 10 questions dengan `sort_order` 1–10
- [ ] Tidak ada soal duplikat dalam satu level
- [ ] `intro_video_url` sudah diisi (jika video final sudah tersedia)

---

## 8. Contoh alur pengisian: Jaringan Komputer

Contoh end-to-end untuk mata pelajaran **Jaringan Komputer**.

### Langkah 1 — Buat `course`

| Kolom | Nilai contoh |
|-------|----------------|
| `emoji` | 🌐 |
| `category` | NETWORKING |
| `title` | Jaringan Komputer |
| `description` | Protokol, alamat jaringan, model komunikasi, dan keamanan dasar jaringan. |
| `intro_video_url` | `https://...` (URL video pengantar) |
| `modules_total` | 4 |
| `sort_order` | 4 |

→ Catat **`courses.id`** (mis. `4`).

### Langkah 2 — Buat `materials` (4 materi, basic → advanced)

| sort_order | title | course_id |
|------------|-------|-----------|
| 1 | Istilah Dasar | 4 |
| 2 | Konsep Inti | 4 |
| 3 | Hubungan Antar Konsep | 4 |
| 4 | Pola Soal Kuis | 4 |

Isi `content` dan `key_points` untuk tiap baris.

→ Catat **`materials.id`** masing-masing (mis. 13, 14, 15, 16).

### Langkah 3 — Buat `game_levels`

Contoh level yang memakai materi Jaringan Komputer:

| level_number | material_id | title | topic |
|--------------|-------------|-------|-------|
| 4 | 13 (Istilah Dasar) | Misi Aktif | Jaringan Komputer |
| 9 | 14 (Konsep Inti) | Speed Run | Jaringan Komputer |

Set `questions_count = 10`, `default_status` sesuai desain peta.

→ Catat **`game_levels.id`** untuk tiap level.

### Langkah 4 — Buat `questions` (10 soal per level)

Untuk level **Misi Aktif** (`level_id` = ID level 4), insert 10 baris:

| sort_order | question (ringkas) |
|------------|-------------------|
| 1 | Protokol standar untuk halaman web adalah... |
| 2 | Alamat IP versi 4 terdiri dari... |
| 3 | Model OSI memiliki berapa layer? |
| … | … |
| 10 | WAN (Wide Area Network) biasanya... |

Semua soal: `category = 'Jaringan Komputer'`, relevan dengan materi **Istilah Dasar / Jaringan**.

Ulangi untuk level 9 dengan soal yang selaras materi **Konsep Inti**.

### Diagram alur

```
Course: Jaringan Komputer (id=4)
  │
  ├── Material: Istilah Dasar (sort_order=1, id=13)
  │     └── Game Level 4: Misi Aktif
  │           └── Questions × 10 (sort_order 1–10)
  │
  ├── Material: Konsep Inti (sort_order=2, id=14)
  │     └── Game Level 9: Speed Run
  │           └── Questions × 10 (sort_order 1–10)
  │
  ├── Material: Hubungan Antar Konsep (sort_order=3)
  └── Material: Pola Soal Kuis (sort_order=4)
```

---

## 9. Catatan production

### Supabase Local vs Supabase Cloud

| Lingkungan | Penggunaan |
|------------|------------|
| **Supabase Local** | Development, uji seed, eksperimen tim dev |
| **Supabase Cloud** | **Production** — versi final / Play Store |

Untuk rilis **Play Store** atau production:

1. Konten final **dikelola di Supabase Cloud**, bukan hanya database lokal.
2. Flutter app production harus diarahkan ke **URL dan anon key** project Cloud.
3. Perubahan konten (materi, soal, level) dilakukan lewat **Supabase Dashboard Cloud** — tanpa perlu rilis ulang app, selama struktur tabel sama.
4. Backup rutin dan review `is_published` sebelum konten live.

### Siapa yang boleh mengedit?

- Gunakan akun dengan akses **admin/service role** di Dashboard untuk insert/update/delete.
- App mobile hanya punya akses **baca** (RLS: `SELECT` untuk baris `is_published = true`).

### Referensi teknis di repo

- Schema: `supabase/migrations/20260615000000_kursuskilat_schema_v2.sql`
- Data contoh awal: `supabase/seed.sql`
- Generator seed (dev): `kursuskilat/UAS/tool/generate_seed.dart`

---

*Terakhir diperbarui: dokumentasi ini mengacu pada schema KursusKilat v2 (courses → materials → game_levels → questions).*
