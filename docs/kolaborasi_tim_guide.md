# Panduan Kolaborasi Tim KursusKilat
**Tim 3 orang · Flutter + Supabase Cloud · GitHub `main` langsung**

Dokumen ini **khusus internal tim**. Isinya perintah lengkap — tinggal copy-paste.

---

## Daftar isi

1. [Info project (copy-paste)](#1-info-project-copy-paste)
2. [Setup pertama kali di laptop baru](#2-setup-pertama-kali-di-laptop-baru)
3. [Aturan kerja tim (WAJIB)](#3-aturan-kerja-tim-wajib)
4. [Alur harian — mulai kerja](#4-alur-harian--mulai-kerja)
5. [Alur harian — selesai & push](#5-alur-harian--selesai--push)
6. [Alur harian — teman lanjut kerja](#6-alur-harian--teman-lanjut-kerja)
7. [Update konten Supabase (materi / game / video)](#7-update-konten-supabase-materi--game--video)
8. [Troubleshooting](#8-troubleshooting)
9. [FAQ](#9-faq)

---

## 1. Info project (copy-paste)

| Item | Nilai |
|------|-------|
| **Repo GitHub** | `https://github.com/DimasLastarizo/flutterUAS.git` |
| **Branch** | `main` (semua push ke sini, tanpa branch terpisah) |
| **Folder app Flutter** | `kursuskilat/UAS/` |
| **Supabase Cloud URL** | `https://qxsmrunqoylplbpogzgo.supabase.co` |
| **Supabase Dashboard** | `https://supabase.com/dashboard/project/qxsmrunqoylplbpogzgo` |

### Perintah jalanin app (SIMPAN INI — pakai setiap hari)

Buka terminal / CMD / PowerShell, masuk ke folder app, lalu jalankan **persis** baris ini:

```bash
cd kursuskilat/UAS
flutter run --dart-define=SUPABASE_URL=https://qxsmrunqoylplbpogzgo.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4c21ydW5xb3lscGxicG9nemdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NzE3NjUsImV4cCI6MjA5NzQ0Nzc2NX0.vEnOHdsUVjIl0bHoElAatiKKjjsgrVpaeu4-4jfxwFo
```

> **Catatan:** `anon key` memang untuk dipakai di app (bukan rahasia seperti password admin). **Jangan share `service_role key`** ke siapapun — itu akses penuh database.

### Struktur folder penting di repo

```
flutterUAS/
├── kursuskilat/UAS/          ← kode Flutter (kerja di sini)
│   └── lib/screens/          ← halaman app
├── supabase/
│   ├── snippets/             ← SQL isi konten (materi, game, video)
│   └── migrations/           ← perubahan struktur tabel (jarang, hati-hati)
└── docs/
    ├── admin_content_guide.md
    └── kolaborasi_tim_guide.md   ← file ini
```

---

## 2. Setup pertama kali di laptop baru

Lakukan **sekali saja** saat pertama kali join project.

### 2.1 Pastikan sudah terinstall

- [ ] **Git** — cek: `git --version`
- [ ] **Flutter** — cek: `flutter --version`
- [ ] **Android Studio** atau Android SDK (untuk jalanin di HP Android)
- [ ] Akun GitHub sudah **di-invite** ke repo `DimasLastarizo/flutterUAS`

### 2.2 Clone repo

```bash
git clone https://github.com/DimasLastarizo/flutterUAS.git
cd flutterUAS
```

**Contoh path di Windows:**
`D:\VS code\flutree\flutterUAS`

Path di laptop teman boleh beda — yang penting isi foldernya sama setelah clone.

### 2.3 Install dependency Flutter

```bash
cd kursuskilat/UAS
flutter pub get
```

**Harusnya muncul:** `Got dependencies!` tanpa error merah.

### 2.4 Siapkan HP Android

1. Di HP: **Settings → About phone → tap Build number 7x** → Developer options aktif
2. **Settings → Developer options → USB debugging** → ON
3. Colok HP ke laptop pakai kabel USB
4. Di HP muncul popup **Allow USB debugging?** → Allow / Izinkan
5. Cek HP terdeteksi:

```bash
flutter devices
```

**Harusnya muncul** nama HP kamu, contoh:
```
22111317PG (mobile) • android-arm64 • Android 14 ...
```

Kalau HP tidak muncul → cabut-colok kabel, ganti mode USB ke **File transfer / MTP**, coba lagi.

### 2.5 Jalankan app pertama kali

Dari folder `kursuskilat/UAS`, jalankan perintah lengkap di **Bagian 1** (flutter run + dart-define).

**Tunggu sampai:**
- Terminal menampilkan `Flutter run key commands` (r = hot reload, R = restart, q = quit)
- App terbuka di HP

### 2.6 Tes koneksi Supabase Cloud

Di HP, buka app lalu cek:

- [ ] Tab **Materi** → muncul daftar mata pelajaran (Dasar Pemrograman, Basis Data, dll.)
- [ ] Tab **Game** → muncul peta level
- [ ] Buka satu materi → video / bacaan tampil

Kalau **data kosong atau error** → lihat [Troubleshooting](#8-troubleshooting).

---

## 3. Aturan kerja tim (WAJIB)

Tim kita **tidak pakai branch**. Semua push langsung ke `main`. Supaya aman:

### Satu orang kerja GitHub pada satu waktu

```
Orang A: chat "mulai kerja" → pull → coding → push → chat "sudah push"
Orang B & C: TIDAK push / commit selama A belum selesai
Orang B: setelah A push → pull → giliran kerja
```

### Template chat grup

**Sebelum mulai:**
```
🟡 [NAMA] mulai kerja: [judul tugas, contoh "fix video fullscreen"]
Jangan push dulu ya
```

**Setelah push:**
```
🟢 [NAMA] sudah push ke main: [judul tugas]
Silakan pull
```

**Sebelum update Supabase (SQL):**
```
🟠 [NAMA] mau jalankan SQL di Cloud: [nama file, contoh update_intro_videos.sql]
```

---

## 4. Alur harian — mulai kerja

### Step 1 — Kabari tim di chat

Kirim pesan 🟡 (lihat template di atas). **Tunggu konfirmasi** kalau ada teman yang belum push / masih kerja.

### Step 2 — Buka terminal, masuk folder repo

```bash
cd D:\VS code\flutree\flutterUAS
```
*(Ganti path sesuai lokasi clone di laptop kamu)*

### Step 3 — Pull kode terbaru dari GitHub

```bash
git checkout main
git pull origin main
```

**Harusnya muncul:**
- `Already up to date.` → sudah paling baru, lanjut
- ATAU daftar file yang di-update → berhasil pull

**Kalau muncul error conflict** → stop, chat tim, jangan push dulu. Lihat [Troubleshooting](#8-troubleshooting).

### Step 4 — Update dependency (kalau ada perubahan package)

```bash
cd kursuskilat/UAS
flutter pub get
```

### Step 5 — Colok HP & jalankan app

```bash
flutter devices
```

Pastikan HP muncul, lalu:

```bash
flutter run --dart-define=SUPABASE_URL=https://qxsmrunqoylplbpogzgo.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4c21ydW5xb3lscGxicG9nemdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NzE3NjUsImV4cCI6MjA5NzQ0Nzc2NX0.vEnOHdsUVjIl0bHoElAatiKKjjsgrVpaeu4-4jfxwFo
```

### Step 6 — Mulai coding

- Edit file di VS Code / Cursor, biasanya di `kursuskilat/UAS/lib/`
- Setelah ubah UI/logic: tekan **`r`** di terminal = hot reload
- Kalau hot reload aneh: tekan **`R`** = hot restart (full restart app)
- Kalau masih aneh: **`q`** quit, lalu `flutter run ...` lagi

### Step 7 — Tes di HP sebelum push

Centang manual:

- [ ] App tidak crash saat dibuka
- [ ] Fitur yang kamu ubah jalan normal
- [ ] Halaman Materi & Game masih bisa dibuka (regression check)

---

## 5. Alur harian — selesai & push

### Step 1 — Stop app (opsional tapi rapi)

Di terminal flutter, tekan **`q`**

### Step 2 — Cek file apa saja yang berubah

```bash
cd D:\VS code\flutree\flutterUAS
git status
```

**Contoh output:**
```
modified:   kursuskilat/UAS/lib/screens/module_detail_page.dart
modified:   docs/kolaborasi_tim_guide.md
```

Pastikan **tidak ada file aneh** (build folder, .env, dll.) yang ikut ke commit. Folder `build/` seharusnya tidak muncul (sudah di `.gitignore`).

### Step 3 — Stage & commit

```bash
git add .
git commit -m "feat: deskripsi singkat apa yang kamu ubah"
```

**Contoh commit message yang bagus:**
```bash
git commit -m "fix: fullscreen video landscape tidak balik portrait"
git commit -m "feat: isi intro video semua mata pelajaran"
git commit -m "docs: update panduan kolaborasi tim"
```

### Step 4 — Push ke GitHub

```bash
git push origin main
```

**Harusnya muncul:**
```
To https://github.com/DimasLastarizo/flutterUAS.git
   abc1234..def5678  main -> main
```

**Kalau ditolak (rejected):**
```bash
git pull origin main
# selesaikan conflict kalau ada
git push origin main
```

### Step 5 — Kabari tim di chat

Kirim pesan 🟢 (lihat template Bagian 3).

---

## 6. Alur harian — teman lanjut kerja

Kalau teman sudah kirim 🟢 "sudah push":

```bash
cd D:\VS code\flutree\flutterUAS
git checkout main
git pull origin main
cd kursuskilat/UAS
flutter pub get
```

Lalu kirim 🟡 dan mulai dari [Bagian 4](#4-alur-harian--mulai-kerja).

**Tidak perlu** clone ulang. Cukup `git pull`.

---

## 7. Update konten Supabase (materi / game / video)

Konten (materi bacaan, soal game, link video) disimpan di **Supabase Cloud**, bukan di kode Flutter. Semua anggota otomatis lihat data yang sama setelah restart app.

### Alur lengkap (contoh: update video pembuka)

**Step 1 — Kabari tim** 🟠 di chat

**Step 2 — Pull dulu (supaya file SQL di repo paling baru)**

```bash
git pull origin main
```

**Step 3 — Buka / edit file SQL di repo**

Contoh: `supabase/snippets/update_intro_videos.sql`

**Step 4 — Commit & push file SQL ke GitHub**

```bash
git add supabase/snippets/update_intro_videos.sql
git commit -m "feat: update intro video semua mata pelajaran"
git push origin main
```

**Step 5 — Jalankan SQL di Supabase Cloud**

1. Buka browser: `https://supabase.com/dashboard/project/qxsmrunqoylplbpogzgo`
2. Login akun Supabase yang punya akses project
3. Klik menu **SQL Editor** (kiri)
4. Klik **New query**
5. Copy-paste isi file SQL dari repo
6. Klik **Run** (tombol hijau)
7. Pastikan tidak ada error merah

**Step 6 — Tes di HP**

```bash
cd kursuskilat/UAS
flutter run --dart-define=SUPABASE_URL=https://qxsmrunqoylplbpogzgo.supabase.co --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF4c21ydW5xb3lscGxicG9nemdvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE4NzE3NjUsImV4cCI6MjA5NzQ0Nzc2NX0.vEnOHdsUVjIl0bHoElAatiKKjjsgrVpaeu4-4jfxwFo
```

- Tutup app di HP sepenuhnya (swipe dari recent apps)
- Buka lagi dari flutter run
- Cek halaman Materi → video harus tampil

**Step 7 — Kabari tim** 🟢 + catatan "data Cloud sudah di-update, pull + restart app"

> **Penting:** Teman **tidak perlu pull** cuma untuk lihat data baru di app — cukup restart app. Tapi **perlu pull** kalau mau dapat file SQL terbaru di laptop mereka.

### File SQL yang sudah ada di repo

| File | Fungsi |
|------|--------|
| `supabase/snippets/update_dasar_pemrograman_materials.sql` | Konten materi Dasar Pemrograman |
| `supabase/snippets/update_algoritma_struktur_data_materials.sql` | Konten materi Algoritma & Struktur Data |
| `supabase/snippets/update_basis_data_materials.sql` | Konten materi Basis Data |
| `supabase/snippets/update_jaringan_komputer_materials.sql` | Konten materi Jaringan Komputer |
| `supabase/snippets/update_kecerdasan_buatan_materials.sql` | Konten materi Kecerdasan Buatan |
| `supabase/snippets/update_intro_videos.sql` | Link video pembuka semua mata pelajaran |
| `supabase/snippets/update_game_levels_batch1.sql` | Soal game level 1–4 |
| `supabase/snippets/update_game_levels_batch2.sql` | Soal game level 5–8 |
| `supabase/snippets/update_game_levels_batch3.sql` | Soal game level 9–12 |

Panduan detail isi konten: `docs/admin_content_guide.md`

---

## 8. Troubleshooting

### `git push` ditolak — "Updates were rejected"

Artinya ada commit baru di GitHub yang belum kamu punya.

```bash
git pull origin main
git push origin main
```

Kalau conflict → chat tim, selesaikan bareng.

---

### App jalan tapi Materi/Game kosong

1. Pastikan perintah `flutter run` pakai **dart-define lengkap** (Bagian 1)
2. Cek internet HP & laptop
3. Buka Supabase Dashboard → **Table Editor** → cek tabel `courses` ada datanya
4. Restart app (`q` lalu flutter run lagi)

---

### `flutter devices` HP tidak muncul

1. USB debugging ON di HP
2. Ganti kabel / port USB
3. Mode USB = File transfer (MTP)
4. Allow popup USB debugging di HP
5. Jalankan: `flutter doctor` — lihat ada error Android toolchain

---

### Hot reload tidak ngaruh

1. Tekan **`R`** (capital R) = hot restart
2. Kalau masih gagal: **`q`** quit → `flutter run ...` dari awal
3. Untuk perubahan native / dependency baru → wajib restart penuh

---

### Video YouTube error "Playback on other apps disabled" (Error 150)

Video tidak allow embed. Ganti link di Supabase:

```sql
UPDATE courses
SET intro_video_url = 'https://youtu.be/LINK_BARU'
WHERE id = 3;  -- ganti id sesuai mata pelajaran
```

Jalankan di SQL Editor Cloud. Lihat juga `supabase/snippets/update_intro_videos.sql`.

---

### Konflik Git (file ada `<<<<<<<`)

1. **Jangan panic, jangan push dulu**
2. Buka file conflict di editor
3. Hapus marker `<<<<<<<`, `=======`, `>>>>>>>`
4. Simpan versi kode yang benar (diskusi tim kalau ragu)
5. Lalu:

```bash
git add .
git commit -m "merge: resolve conflict"
git push origin main
```

---

## 9. FAQ

**Q: Pull GitHub perlu tiap hari?**  
A: **Ya**, setiap kali mau mulai kerja — supaya kode lokal sama dengan teman.

**Q: Supabase perlu di-pull?**  
A: **Tidak.** Cloud otomatis sama. Cukup `flutter run` dengan URL & key yang sama.

**Q: Boleh dua orang kerja bareng?**  
A: Boleh **asal tidak push barengan**. Koordinasi di chat: satu orang selesai push dulu, baru giliran berikutnya.

**Q: Lupa perintah flutter run?**  
A: Copy dari **Bagian 1** dokumen ini. Simpan juga di notes HP/laptop.

**Q: Path folder beda antar laptop?**  
A: Normal. Yang penting setelah `cd` kamu ada di folder `flutterUAS` dan `kursuskilat/UAS` untuk flutter.

**Q: Perlu buat branch?**  
A: **Tidak** — tim kita pakai `main` langsung + koordinasi chat.

---

## Ringkasan super cepat

```
MULAI  → chat 🟡 → git pull → flutter pub get → flutter run (perintah lengkap Bagian 1) → coding → tes HP
SELESAI → git add . → git commit -m "..." → git push origin main → chat 🟢
TEMAN  → git pull → lanjut kerja
SUPABASE → edit SQL di repo → push → jalankan di SQL Editor Cloud → restart app → chat tim
```

---

*Terakhir di-update: Juni 2026 · Repo: https://github.com/DimasLastarizo/flutterUAS*
