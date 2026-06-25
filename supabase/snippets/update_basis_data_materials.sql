-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Update konten materi: Basis Data (course_id = 3)
-- Jalankan di Supabase Cloud → SQL Editor
-- Video intro: belum diisi (intro_video_url tetap kosong)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK DATA SEBELUM UPDATE ───────────────────────────────────────────
SELECT id, course_id, sort_order, title
FROM materials
WHERE course_id = 3
ORDER BY sort_order ASC;

SELECT id, title, description, intro_video_url
FROM courses
WHERE id = 3;


-- ─── 1. UPDATE DESKRIPSI MATA PELAJARAN ───────────────────────────────────
UPDATE courses
SET
  description = 'Pelajari basis data: DBMS, model relasional, normalisasi, SQL & CRUD, JOIN, transaksi ACID, keamanan, dan basis data NoSQL modern.',
  modules_total = 4
WHERE id = 3;


-- ─── 2. MATERI 1 — Pengenalan Basis Data (sort_order = 1) ─────────────────
UPDATE materials
SET
  title = 'Pengenalan Basis Data',
  emoji = '📊',
  duration_label = 'Ringkas',
  content = $$Basis data atau database adalah kumpulan data yang disimpan secara terstruktur dan terorganisir sehingga dapat diakses, dikelola, dan diperbarui dengan mudah. Sebelum basis data ada, data disimpan dalam file-file terpisah yang tidak saling terhubung, sehingga menyulitkan pencarian dan sering menyebabkan data yang sama disimpan berulang kali di tempat berbeda. Kehadiran basis data menyelesaikan masalah tersebut dengan menyediakan satu tempat terpusat yang menjadi sumber kebenaran tunggal bagi seluruh data dalam sebuah sistem. Hampir semua aplikasi yang kita gunakan sehari-hari, mulai dari media sosial hingga perbankan, bergantung sepenuhnya pada basis data untuk menyimpan dan mengelola informasinya.

Untuk mengelola basis data, digunakan perangkat lunak khusus yang disebut DBMS atau Database Management System. DBMS bertugas sebagai perantara antara pengguna atau aplikasi dengan data yang tersimpan, memastikan data bisa diakses dengan cepat, aman, dan konsisten. Terdapat berbagai jenis DBMS yang tersedia seperti MySQL, PostgreSQL, dan Oracle untuk basis data berbasis tabel, serta MongoDB untuk basis data yang lebih fleksibel berbasis dokumen. Memilih DBMS yang tepat sangat bergantung pada kebutuhan sistem yang akan dibangun, karena setiap DBMS memiliki kekuatan dan keterbatasannya masing-masing.$$,
  key_points = '[
    "Basis data adalah tempat penyimpanan data yang terstruktur dan terpusat sehingga mudah diakses dan dikelola.",
    "Sebelum basis data ada, penyimpanan data dalam file terpisah menyebabkan banyak redundansi dan kesulitan pengelolaan.",
    "DBMS adalah perangkat lunak yang menjadi perantara antara pengguna dan data yang tersimpan di dalam basis data.",
    "Pemilihan jenis DBMS harus disesuaikan dengan kebutuhan sistem karena setiap DBMS memiliki karakteristik yang berbeda."
  ]'::jsonb,
  sort_order = 1,
  is_published = true
WHERE course_id = 3 AND sort_order = 1;


-- ─── 3. MATERI 2 — Model dan Struktur Basis Data Relasional ──────────────
UPDATE materials
SET
  title = 'Model dan Struktur Basis Data Relasional',
  emoji = '🗂️',
  duration_label = 'Teori',
  content = $$Basis data relasional adalah model basis data yang paling banyak digunakan hingga saat ini, di mana data disimpan dalam bentuk tabel yang terdiri dari baris dan kolom. Setiap tabel merepresentasikan satu entitas, misalnya tabel pelanggan, tabel produk, atau tabel transaksi, dan setiap baris dalam tabel mewakili satu data unik yang disebut record. Antar tabel bisa saling dihubungkan menggunakan kunci yang disebut foreign key, sehingga informasi dari beberapa tabel bisa digabungkan untuk menghasilkan data yang lebih lengkap dan bermakna. Konsep inilah yang menjadi kekuatan utama basis data relasional — kemampuannya dalam merepresentasikan hubungan antar data yang kompleks secara efisien.

Agar basis data relasional bekerja secara optimal, struktur tabelnya perlu dirancang dengan baik melalui proses yang disebut normalisasi. Normalisasi adalah teknik mengorganisir tabel sedemikian rupa sehingga tidak ada data yang disimpan secara berulang, dan setiap data berada di tempat yang paling tepat. Selain itu, setiap tabel membutuhkan sebuah kolom khusus yang nilainya unik dan tidak boleh kosong untuk mengidentifikasi setiap record secara pasti — kolom inilah yang disebut primary key. Rancangan basis data yang baik adalah fondasi dari sistem yang tidak hanya bekerja dengan benar, tetapi juga efisien dalam jangka panjang seiring data terus bertambah.$$,
  key_points = '[
    "Basis data relasional menyimpan data dalam bentuk tabel yang terdiri dari baris dan kolom dengan struktur yang jelas.",
    "Foreign key menghubungkan antar tabel sehingga data yang berkaitan bisa digabungkan dan diolah bersama.",
    "Primary key adalah identitas unik setiap record dalam sebuah tabel yang tidak boleh kosong atau duplikat.",
    "Normalisasi adalah proses merancang struktur tabel agar data tidak tersimpan secara berulang dan pengelolaan menjadi lebih efisien."
  ]'::jsonb,
  sort_order = 2,
  is_published = true
WHERE course_id = 3 AND sort_order = 2;


-- ─── 4. MATERI 3 — Bahasa Query dan Manipulasi Data ──────────────────────
UPDATE materials
SET
  title = 'Bahasa Query dan Manipulasi Data',
  emoji = '💾',
  duration_label = 'Analisis',
  content = $$Untuk berinteraksi dengan basis data relasional, digunakan bahasa khusus yang disebut SQL atau Structured Query Language. SQL memungkinkan pengguna untuk melakukan berbagai operasi terhadap data, mulai dari mengambil data, menambahkan data baru, memperbarui data yang sudah ada, hingga menghapus data yang tidak lagi diperlukan. Keempat operasi dasar ini dikenal dengan singkatan CRUD — Create, Read, Update, dan Delete — dan menjadi fondasi dari hampir semua interaksi yang terjadi antara aplikasi dengan basis datanya. SQL dirancang agar mudah dibaca bahkan oleh orang yang bukan berlatar belakang teknis, karena sintaksnya menyerupai kalimat dalam bahasa Inggris.

Kemampuan SQL tidak berhenti pada operasi dasar saja. SQL juga memungkinkan penggabungan data dari beberapa tabel sekaligus melalui operasi yang disebut JOIN, sehingga laporan atau informasi yang kompleks bisa dihasilkan hanya dengan satu perintah. Selain itu, SQL menyediakan fungsi agregasi seperti menghitung jumlah data, mencari nilai rata-rata, atau menemukan nilai tertinggi dan terendah dalam sekumpulan data. Kemampuan-kemampuan ini menjadikan SQL sebagai salah satu keterampilan paling dicari di dunia teknologi, karena hampir semua sistem yang menyimpan data pasti membutuhkan seseorang yang bisa mengelola dan menganalisis data tersebut dengan efektif.$$,
  key_points = '[
    "SQL adalah bahasa standar yang digunakan untuk berinteraksi dan memanipulasi data dalam basis data relasional.",
    "CRUD adalah empat operasi dasar dalam pengelolaan data: Create, Read, Update, dan Delete.",
    "Operasi JOIN memungkinkan pengambilan data dari beberapa tabel sekaligus dalam satu perintah yang terintegrasi.",
    "Fungsi agregasi dalam SQL memungkinkan analisis data seperti menghitung jumlah, rata-rata, serta nilai maksimum dan minimum."
  ]'::jsonb,
  sort_order = 3,
  is_published = true
WHERE course_id = 3 AND sort_order = 3;


-- ─── 5. MATERI 4 — Transaksi, Keamanan, dan Basis Data Modern ───────────
UPDATE materials
SET
  title = 'Transaksi, Keamanan, dan Basis Data Modern',
  emoji = '🔒',
  duration_label = 'Lanjutan',
  content = $$Dalam sistem yang digunakan oleh banyak pengguna secara bersamaan, sangat penting untuk memastikan bahwa setiap operasi data berjalan secara utuh dan tidak menimbulkan konflik. Konsep transaksi hadir untuk menjawab kebutuhan ini — transaksi adalah serangkaian operasi yang harus dijalankan secara keseluruhan atau tidak sama sekali. Jika salah satu langkah dalam transaksi gagal, maka seluruh proses akan dibatalkan dan data dikembalikan ke kondisi semula, sehingga tidak ada data yang setengah tersimpan atau tidak konsisten. Prinsip ini dijamin oleh empat sifat utama yang dikenal sebagai ACID: Atomicity, Consistency, Isolation, dan Durability.

Selain transaksi, keamanan data juga menjadi aspek yang tidak kalah penting dalam pengelolaan basis data. Tidak semua pengguna seharusnya bisa mengakses atau mengubah semua data, sehingga DBMS menyediakan sistem hak akses yang mengatur siapa boleh melakukan apa terhadap data tertentu. Di sisi lain, dunia basis data terus berkembang dengan munculnya basis data NoSQL yang dirancang untuk menangani data dalam jumlah sangat besar dengan struktur yang lebih fleksibel, seperti data media sosial atau data sensor Internet of Things. Perkembangan ini menunjukkan bahwa basis data bukan teknologi yang stagnan, melainkan terus berevolusi mengikuti kebutuhan dan tantangan dunia digital yang semakin kompleks.$$,
  key_points = '[
    "Transaksi memastikan serangkaian operasi data berjalan secara utuh — jika gagal di tengah jalan, semua perubahan akan dibatalkan.",
    "Prinsip ACID menjamin keandalan transaksi dalam basis data agar data selalu berada dalam kondisi yang konsisten dan valid.",
    "Sistem hak akses dalam DBMS mengatur batasan operasi yang bisa dilakukan oleh setiap pengguna terhadap data tertentu.",
    "Basis data NoSQL hadir sebagai solusi modern untuk menangani data berskala besar dengan struktur yang lebih dinamis dan fleksibel."
  ]'::jsonb,
  sort_order = 4,
  is_published = true
WHERE course_id = 3 AND sort_order = 4;


-- ─── 6. VERIFIKASI SETELAH UPDATE ─────────────────────────────────────────
SELECT
  id,
  sort_order,
  title,
  emoji,
  duration_label,
  left(content, 80) || '...' AS content_preview,
  key_points
FROM materials
WHERE course_id = 3
ORDER BY sort_order ASC;

-- Harusnya urutan:
-- 1 | Pengenalan Basis Data
-- 2 | Model dan Struktur Basis Data Relasional
-- 3 | Bahasa Query dan Manipulasi Data
-- 4 | Transaksi, Keamanan, dan Basis Data Modern
