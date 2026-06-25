-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Update konten materi: Jaringan Komputer (course_id = 4)
-- Jalankan di Supabase Cloud → SQL Editor
-- Video intro: belum diisi (intro_video_url tetap kosong)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK DATA SEBELUM UPDATE ───────────────────────────────────────────
SELECT id, course_id, sort_order, title
FROM materials
WHERE course_id = 4
ORDER BY sort_order ASC;

SELECT id, title, description, intro_video_url
FROM courses
WHERE id = 4;


-- ─── 1. UPDATE DESKRIPSI MATA PELAJARAN ───────────────────────────────────
UPDATE courses
SET
  description = 'Pelajari jaringan komputer: LAN/MAN/WAN, protokol TCP/IP, pengalamatan IP, routing, keamanan jaringan, VPN, dan jaringan modern.',
  modules_total = 4
WHERE id = 4;


-- ─── 2. MATERI 1 — Pengenalan Jaringan Komputer (sort_order = 1) ─────────
UPDATE materials
SET
  title = 'Pengenalan Jaringan Komputer',
  emoji = '🌐',
  duration_label = 'Ringkas',
  content = $$Jaringan komputer adalah sistem yang menghubungkan dua atau lebih perangkat komputasi agar dapat saling berkomunikasi dan berbagi sumber daya. Kebutuhan akan jaringan muncul karena manusia membutuhkan cara yang efisien untuk bertukar informasi, berbagi file, maupun menggunakan perangkat seperti printer secara bersama-sama tanpa harus berpindah tempat. Sebelum jaringan ada, data harus dipindahkan secara fisik menggunakan media seperti disket atau kabel langsung, yang tentu sangat tidak efisien untuk skala besar. Jaringan komputer hadir sebagai solusi yang mengubah cara manusia bekerja, berkomunikasi, dan mengakses informasi secara fundamental.

Jaringan komputer dibedakan berdasarkan cakupan geografisnya. Jaringan yang hanya mencakup satu gedung atau area kecil disebut LAN (Local Area Network), sementara yang mencakup satu kota disebut MAN (Metropolitan Area Network), dan yang mencakup antarnegara atau bahkan seluruh dunia disebut WAN (Wide Area Network) — dan internet adalah contoh terbesar dari WAN. Setiap jenis jaringan ini memiliki karakteristik, kecepatan, dan kebutuhan infrastruktur yang berbeda-beda. Memahami perbedaan jenis jaringan ini adalah langkah pertama yang penting sebelum mempelajari bagaimana jaringan sebenarnya bekerja di balik layar.$$,
  key_points = '[
    "Jaringan komputer memungkinkan perangkat saling berkomunikasi dan berbagi sumber daya secara efisien.",
    "Kebutuhan jaringan lahir dari keterbatasan pertukaran data secara fisik yang tidak praktis untuk skala besar.",
    "Jaringan dibedakan berdasarkan cakupannya: LAN untuk area kecil, MAN untuk kota, dan WAN untuk skala luas antar wilayah.",
    "Internet adalah contoh nyata dari jaringan WAN terbesar yang menghubungkan miliaran perangkat di seluruh dunia."
  ]'::jsonb,
  sort_order = 1,
  is_published = true
WHERE course_id = 4 AND sort_order = 1;


-- ─── 3. MATERI 2 — Protokol dan Model Komunikasi Jaringan ─────────────────
UPDATE materials
SET
  title = 'Protokol dan Model Komunikasi Jaringan',
  emoji = '📡',
  duration_label = 'Teori',
  content = $$Agar dua perangkat yang berbeda merek, sistem operasi, maupun spesifikasi bisa saling berkomunikasi, dibutuhkan sebuah aturan bersama yang disepakati — inilah yang disebut protokol jaringan. Protokol menentukan bagaimana data dikemas, dikirim, diterima, dan diinterpretasikan oleh perangkat di kedua sisi komunikasi. Tanpa protokol, dua perangkat tidak akan bisa "saling mengerti" meskipun secara fisik sudah terhubung. Protokol yang paling dikenal dan paling banyak digunakan hingga saat ini adalah TCP/IP, yang menjadi tulang punggung komunikasi di internet.

Untuk membantu memahami bagaimana komunikasi jaringan bekerja secara sistematis, para ahli mengembangkan model referensi. Model OSI membagi proses komunikasi menjadi tujuh lapisan, mulai dari lapisan fisik yang menangani sinyal listrik hingga lapisan aplikasi yang berinteraksi langsung dengan pengguna. Sementara model TCP/IP menyederhanakan konsep tersebut menjadi empat lapisan yang lebih praktis dan banyak diimplementasikan di dunia nyata. Memahami kedua model ini membantu seorang teknisi atau engineer untuk mendiagnosis masalah jaringan dengan lebih sistematis karena mereka tahu di lapisan mana sebuah masalah kemungkinan terjadi.$$,
  key_points = '[
    "Protokol adalah aturan komunikasi yang disepakati bersama agar perangkat yang berbeda bisa saling bertukar data.",
    "Tanpa protokol, perangkat yang terhubung secara fisik pun tidak akan bisa berkomunikasi satu sama lain.",
    "Model OSI membagi komunikasi jaringan menjadi tujuh lapisan yang masing-masing memiliki fungsi spesifik.",
    "Model TCP/IP adalah versi praktis dari OSI yang terdiri dari empat lapisan dan menjadi dasar kerja internet modern."
  ]'::jsonb,
  sort_order = 2,
  is_published = true
WHERE course_id = 4 AND sort_order = 2;


-- ─── 4. MATERI 3 — Pengalamatan dan Routing Jaringan ──────────────────────
UPDATE materials
SET
  title = 'Pengalamatan dan Routing Jaringan',
  emoji = '🗺️',
  duration_label = 'Analisis',
  content = $$Setiap perangkat yang terhubung ke jaringan membutuhkan sebuah identitas unik agar data bisa dikirim ke tujuan yang tepat — identitas inilah yang disebut IP address. IP address bekerja seperti alamat rumah di dunia nyata, di mana setiap perangkat memiliki alamat yang berbeda sehingga data tidak salah kirim. Selain IP address yang bersifat logis dan bisa berubah, setiap perangkat jaringan juga memiliki MAC address yang bersifat permanen dan tertanam langsung pada perangkat keras. Kedua jenis alamat ini bekerja sama dalam proses pengiriman data, di mana IP address digunakan untuk menentukan tujuan akhir sementara MAC address digunakan untuk komunikasi di dalam jaringan lokal.

Ketika data dikirim dari satu perangkat ke perangkat lain yang berada di jaringan berbeda, dibutuhkan sebuah proses yang disebut routing — yaitu proses menentukan jalur terbaik yang harus dilalui data agar sampai ke tujuan. Perangkat yang bertugas melakukan routing disebut router, sementara switch bertugas mengarahkan data di dalam satu jaringan lokal yang sama. Konsep subnetting juga berperan penting di sini, yaitu teknik membagi satu jaringan besar menjadi beberapa jaringan lebih kecil agar pengelolaan alamat IP menjadi lebih efisien dan terorganisir. Pemahaman tentang pengalamatan dan routing adalah kompetensi inti yang wajib dimiliki oleh siapapun yang ingin berkarier di bidang jaringan komputer.$$,
  key_points = '[
    "IP address adalah identitas logis setiap perangkat dalam jaringan yang digunakan untuk menentukan tujuan pengiriman data.",
    "MAC address adalah identitas permanen yang tertanam pada perangkat keras dan digunakan untuk komunikasi dalam jaringan lokal.",
    "Routing adalah proses menentukan jalur terbaik bagi data untuk mencapai tujuannya melewati berbagai jaringan.",
    "Subnetting memungkinkan pembagian jaringan besar menjadi bagian-bagian kecil yang lebih mudah dikelola dan lebih efisien."
  ]'::jsonb,
  sort_order = 3,
  is_published = true
WHERE course_id = 4 AND sort_order = 3;


-- ─── 5. MATERI 4 — Keamanan dan Jaringan Modern ─────────────────────────
UPDATE materials
SET
  title = 'Keamanan dan Jaringan Modern',
  emoji = '🔐',
  duration_label = 'Lanjutan',
  content = $$Seiring jaringan komputer menjadi bagian tak terpisahkan dari kehidupan sehari-hari, ancaman terhadap keamanan jaringan pun semakin beragam dan canggih. Serangan seperti pencurian data, penyadapan komunikasi, hingga serangan yang membanjiri server dengan permintaan palsu menjadi tantangan nyata yang harus dihadapi. Untuk melindungi jaringan dari ancaman tersebut, digunakan berbagai mekanisme keamanan seperti firewall yang menyaring lalu lintas data masuk dan keluar, serta enkripsi yang mengubah data menjadi format tidak terbaca sehingga hanya pihak yang berwenang yang bisa memahaminya. Keamanan jaringan bukan lagi pilihan, melainkan kebutuhan mutlak di era digital ini.

Di sisi lain, teknologi jaringan terus berkembang pesat melampaui konsep jaringan fisik konvensional. VPN atau Virtual Private Network memungkinkan pengguna untuk membuat koneksi yang aman dan terenkripsi melalui jaringan publik seolah-olah mereka berada dalam jaringan privat yang sama. Cloud networking menggeser infrastruktur jaringan dari perangkat fisik ke layanan berbasis internet yang lebih fleksibel dan mudah dikelola. Ditambah dengan perkembangan jaringan nirkabel dari generasi ke generasi hingga kini mencapai era 5G, jaringan komputer modern telah bertransformasi menjadi fondasi utama yang menopang hampir seluruh aspek kehidupan digital manusia.$$,
  key_points = '[
    "Ancaman keamanan jaringan semakin kompleks, mulai dari pencurian data hingga serangan yang melumpuhkan layanan secara massal.",
    "Firewall dan enkripsi adalah dua mekanisme utama yang digunakan untuk melindungi data dan jaringan dari akses yang tidak sah.",
    "VPN memungkinkan komunikasi yang aman melalui jaringan publik dengan menciptakan jalur terenkripsi yang bersifat privat.",
    "Cloud networking dan jaringan nirkabel generasi terbaru telah mengubah cara infrastruktur jaringan dibangun dan dikelola secara modern."
  ]'::jsonb,
  sort_order = 4,
  is_published = true
WHERE course_id = 4 AND sort_order = 4;


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
WHERE course_id = 4
ORDER BY sort_order ASC;

-- Harusnya urutan:
-- 1 | Pengenalan Jaringan Komputer
-- 2 | Protokol dan Model Komunikasi Jaringan
-- 3 | Pengalamatan dan Routing Jaringan
-- 4 | Keamanan dan Jaringan Modern
