-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Game konten BATCH 1: Level 1–4 (materi pengenalan)
-- Jalankan di Supabase Cloud → SQL Editor
--
-- Level 1 → Pengenalan Pemrograman      (course 1, material sort_order 1)
-- Level 2 → Pengenalan Algoritma         (course 2, material sort_order 1)
-- Level 3 → Pengenalan Basis Data        (course 3, material sort_order 1)
-- Level 4 → Pengenalan Jaringan Komputer (course 4, material sort_order 1)
--
-- Setelah run: tutup app → flutter run ke Cloud → tes Game level 1–4 + Baca Materi
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK SEBELUM UPDATE ─────────────────────────────────────────────────
SELECT gl.level_number, gl.title, gl.material_id, m.title AS material_title, m.course_id
FROM game_levels gl
JOIN materials m ON m.id = gl.material_id
WHERE gl.level_number BETWEEN 1 AND 4
ORDER BY gl.level_number;

SELECT gl.level_number, COUNT(q.id) AS question_count
FROM game_levels gl
LEFT JOIN questions q ON q.level_id = gl.id
WHERE gl.level_number BETWEEN 1 AND 4
GROUP BY gl.level_number
ORDER BY gl.level_number;


-- ─── 1. UPDATE METADATA LEVEL 1–4 ────────────────────────────────────────

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 1 AND sort_order = 1),
  title = 'Pengenalan Pemrograman',
  topic = 'Dasar Pemrograman',
  topic_category_index = 0,
  course_index = 0,
  material_index = 0,
  questions_count = 10
WHERE level_number = 1;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 2 AND sort_order = 1),
  title = 'Pengenalan Algoritma',
  topic = 'Algoritma & Struktur Data',
  topic_category_index = 1,
  course_index = 1,
  material_index = 0,
  questions_count = 10
WHERE level_number = 2;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 3 AND sort_order = 1),
  title = 'Pengenalan Basis Data',
  topic = 'Basis Data',
  topic_category_index = 2,
  course_index = 2,
  material_index = 0,
  questions_count = 10
WHERE level_number = 3;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 4 AND sort_order = 1),
  title = 'Pengenalan Jaringan Komputer',
  topic = 'Jaringan Komputer',
  topic_category_index = 3,
  course_index = 3,
  material_index = 0,
  questions_count = 10
WHERE level_number = 4;


-- ─── 2. HAPUS SOAL LAMA LEVEL 1–4 ────────────────────────────────────────
DELETE FROM questions
WHERE level_id IN (
  SELECT id FROM game_levels WHERE level_number BETWEEN 1 AND 4
);


-- ─── 3. SOAL LEVEL 1 — Pengenalan Pemrograman ────────────────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Dasar Pemrograman',
  'Pemrograman pada dasarnya adalah proses...',
  '["Menghias tampilan layar komputer","Memberikan instruksi terstruktur kepada komputer","Menyalin file antar folder","Memperbaiki kerusakan hardware","Mengatur jaringan WiFi"]'::jsonb,
  1,
  'Pemrograman adalah cara memberi instruksi logis dan terstruktur agar komputer menyelesaikan tugas tertentu.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Dasar Pemrograman',
  'Langkah-langkah logis terstruktur untuk menyelesaikan masalah sebelum ditulis sebagai kode disebut...',
  '["Compiler","Algoritma","Database","Protokol","Firewall"]'::jsonb,
  1,
  'Algoritma adalah inti setiap program — rangkaian langkah logis yang terdefinisi jelas.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Dasar Pemrograman',
  'Diagram alur yang membantu memvisualisasikan logika program sebelum diimplementasikan disebut...',
  '["ERD","Flowchart","Subnet mask","Stack trace","Binary tree"]'::jsonb,
  1,
  'Flowchart membantu merancang alur logika program secara visual sebelum menulis kode.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Dasar Pemrograman',
  'Prinsip dasar kerja program secara umum adalah...',
  '["Hanya output tanpa input","Input, proses, lalu output","Proses tanpa keluaran","Input langsung menjadi file","Output tanpa pemrosesan"]'::jsonb,
  1,
  'Semua program pada dasarnya menerima masukan, memprosesnya, lalu menghasilkan keluaran.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Dasar Pemrograman',
  'Bahasa pemrograman berfungsi sebagai...',
  '["Pengganti sistem operasi","Jembatan antara manusia dan komputer","Alat scan virus","Media penyimpanan permanen","Protokol jaringan"]'::jsonb,
  1,
  'Bahasa pemrograman menjadi perantara agar instruksi manusia dapat dipahami dan dijalankan komputer.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Dasar Pemrograman',
  'Mengapa komputer tidak bisa "menebak" apa yang harus dilakukan tanpa program?',
  '["Karena RAM terlalu kecil","Karena komputer hanya menjalankan instruksi yang didefinisikan","Karena monitor belum dicolok","Karena internet lambat","Karena keyboard rusak"]'::jsonb,
  1,
  'Komputer tidak berpikir seperti manusia — ia hanya mengeksekusi perintah yang sudah dirancang.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Dasar Pemrograman',
  'Manakah yang termasuk contoh bahasa pemrograman?',
  '["HTML saja sebagai bahasa logika","Python","HTTP","TCP/IP","JPEG"]'::jsonb,
  1,
  'Python, Java, dan C++ adalah contoh bahasa pemrograman untuk menulis instruksi program.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Dasar Pemrograman',
  'Data yang dimasukkan ke program sebelum diproses disebut...',
  '["Output","Input","Backup","Cache","Index"]'::jsonb,
  1,
  'Input adalah masukan yang diterima program sebelum tahap pemrosesan.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Dasar Pemrograman',
  'Hasil akhir yang dihasilkan program setelah diproses disebut...',
  '["Input","Variabel","Output","Loop","Pointer"]'::jsonb,
  2,
  'Output adalah keluaran hasil pemrosesan program.'
FROM game_levels WHERE level_number = 1;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Dasar Pemrograman',
  'Algoritma yang baik harus memiliki karakteristik berikut, KECUALI...',
  '["Titik awal dan akhir jelas","Setiap langkah terdefinisi","Menghasilkan keluaran konsisten","Langkah sengaja dibuat ambigu","Dapat diikuti secara berurutan"]'::jsonb,
  3,
  'Algoritma tidak boleh ambigu — setiap langkah harus jelas agar komputer bisa mengeksekusinya.'
FROM game_levels WHERE level_number = 1;


-- ─── 4. SOAL LEVEL 2 — Pengenalan Algoritma ──────────────────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Algoritma & Struktur Data',
  'Algoritma dapat diartikan sebagai...',
  '["Kumpulan hardware jaringan","Langkah logis terurut untuk menyelesaikan masalah","Bahasa markup web","Protokol transfer file","Tabel basis data"]'::jsonb,
  1,
  'Algoritma adalah serangkaian langkah logis dan terurut untuk menyelesaikan suatu masalah.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Algoritma & Struktur Data',
  'Contoh algoritma dalam kehidupan sehari-hari adalah...',
  '["Mengikuti langkah resep memasak","Menunggu sinyal lampu tanpa urutan","Menutup mata saat tidur","Membiarkan piring kotor","Menyalakan TV tanpa remote"]'::jsonb,
  0,
  'Resep memasak adalah algoritma — langkah terurut dengan input, proses, dan hasil akhir.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Algoritma & Struktur Data',
  'Mengapa komputer sepenuhnya bergantung pada algoritma?',
  '["Karena tidak punya monitor","Karena hanya menjalankan instruksi terdefinisi","Karena RAM selalu penuh","Karena tidak ada internet","Karena keyboard terbatas"]'::jsonb,
  1,
  'Komputer tidak bisa menebak — ia hanya mengeksekusi instruksi algoritma yang sudah dirancang.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Algoritma & Struktur Data',
  'Alat bantu untuk merancang algoritma secara visual sebelum kode ditulis adalah...',
  '["Firewall","Flowchart","Subnetting","Normalisasi","Enkripsi"]'::jsonb,
  1,
  'Flowchart dan pseudocode membantu merancang serta mengkomunikasikan algoritma.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Algoritma & Struktur Data',
  'Pseudocode berguna karena...',
  '["Mengganti kebutuhan testing","Memudahkan perancangan dan komunikasi antar programmer","Menghapus kebutuhan algoritma","Mengganti basis data","Mempercepat internet"]'::jsonb,
  1,
  'Pseudocode memudahkan perancangan algoritma dan komunikasi sebelum implementasi kode.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Algoritma & Struktur Data',
  'Salah satu kriteria algoritma yang baik adalah...',
  '["Tidak perlu titik akhir","Titik awal dan akhir jelas","Langkah boleh ambigu","Hasil boleh acak","Tidak perlu masukan"]'::jsonb,
  1,
  'Algoritma baik harus punya titik awal/akhir jelas dan langkah terdefinisi.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Algoritma & Struktur Data',
  'Algoritma yang baik untuk masukan yang sama harus...',
  '["Menghasilkan keluaran berbeda-beda","Menghasilkan keluaran konsisten","Tidak menghasilkan apa pun","Hanya jalan sekali","Selalu error"]'::jsonb,
  1,
  'Algoritma harus deterministik — masukan sama menghasilkan keluaran yang konsisten.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Algoritma & Struktur Data',
  'Instruksi perakitan furnitur dari manual termasuk dalam kategori...',
  '["Protokol jaringan","Algoritma","Query SQL","Foreign key","MAC address"]'::jsonb,
  1,
  'Langkah perakitan manual adalah contoh algoritma — urutan instruksi terstruktur.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Algoritma & Struktur Data',
  'Inti dari setiap program komputer adalah...',
  '["Warna ikon aplikasi","Algoritma","Ukuran layar","Merek keyboard","Logo perusahaan"]'::jsonb,
  1,
  'Setiap program dibangun di atas algoritma — langkah penyelesaian masalah yang jelas.'
FROM game_levels WHERE level_number = 2;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Algoritma & Struktur Data',
  'Langkah algoritma harus ditulis...',
  '["Secara samar agar fleksibel","Tanpa ambiguitas dan terdefinisi jelas","Hanya dalam satu baris","Tanpa urutan","Hanya oleh AI"]'::jsonb,
  1,
  'Komputer tidak bisa menginterpretasi instruksi samar — setiap langkah harus jelas.'
FROM game_levels WHERE level_number = 2;


-- ─── 5. SOAL LEVEL 3 — Pengenalan Basis Data ───────────────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Basis Data',
  'Basis data atau database adalah...',
  '["Kumpulan data terstruktur dan terorganisir","Folder gambar acak","Program antivirus","Protokol email","Perangkat input"]'::jsonb,
  0,
  'Basis data menyimpan data secara terstruktur agar mudah diakses, dikelola, dan diperbarui.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Basis Data',
  'Masalah utama penyimpanan data dalam file terpisah adalah...',
  '["File terlalu kecil","Redundansi dan sulit dikelola","Tidak bisa dibuka","Hanya untuk teks","Tidak perlu backup"]'::jsonb,
  1,
  'File terpisah sering menyebabkan data duplikat dan sulit dicari — basis data mengatasi ini.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Basis Data',
  'DBMS kepanjangan dari...',
  '["Data Backup Management System","Database Management System","Digital Binary Memory Storage","Direct Bus Module Switch","Domain Base Mail Server"]'::jsonb,
  1,
  'DBMS (Database Management System) mengelola akses dan konsistensi data.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Basis Data',
  'Fungsi utama DBMS adalah...',
  '["Mengganti sistem operasi","Menjadi perantara antara aplikasi/pengguna dan data","Menghapus semua data otomatis","Mengatur warna UI","Mempercepat CPU"]'::jsonb,
  1,
  'DBMS memastikan data dapat diakses dengan cepat, aman, dan konsisten.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Basis Data',
  'Manakah yang termasuk DBMS berbasis tabel (relasional)?',
  '["MongoDB","PostgreSQL","JPEG","HTTP","FTP"]'::jsonb,
  1,
  'MySQL, PostgreSQL, dan Oracle adalah DBMS relasional berbasis tabel.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Basis Data',
  'MongoDB lebih cocok dikategorikan sebagai DBMS...',
  '["Hanya untuk spreadsheet","Berbasis dokumen yang fleksibel","Hanya untuk gambar","Tanpa penyimpanan","Khusus email"]'::jsonb,
  1,
  'MongoDB adalah contoh DBMS berbasis dokumen dengan struktur lebih fleksibel.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Basis Data',
  'Istilah "sumber kebenaran tunggal" dalam basis data berarti...',
  '["Data disimpan di banyak tempat berbeda","Data terpusat dan authoritative","Data tidak pernah diubah","Data hanya untuk admin","Data tanpa backup"]'::jsonb,
  1,
  'Basis data menjadi satu tempat terpusat yang menjadi referensi utama data sistem.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Basis Data',
  'Aplikasi seperti media sosial dan perbankan sangat bergantung pada...',
  '["Printer","Basis data","Speaker","Mouse","Kabel HDMI"]'::jsonb,
  1,
  'Hampir semua aplikasi modern menyimpan dan mengelola informasi lewat basis data.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Basis Data',
  'Pemilihan DBMS sebaiknya disesuaikan dengan...',
  '["Warna logo perusahaan","Kebutuhan dan karakteristik sistem","Merek laptop","Jumlah monitor","Ukuran keyboard"]'::jsonb,
  1,
  'Setiap DBMS punya kekuatan dan keterbatasan — pilih sesuai kebutuhan sistem.'
FROM game_levels WHERE level_number = 3;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Basis Data',
  'Kehadiran basis data mengatasi masalah...',
  '["Layar terlalu kecil","Data sama tersimpan berulang di tempat berbeda","Keyboard tidak nyaman","Baterai lemah","Suara speaker"]'::jsonb,
  1,
  'Basis data mengurangi redundansi dan memudahkan pengelolaan data terpusat.'
FROM game_levels WHERE level_number = 3;


-- ─── 6. SOAL LEVEL 4 — Pengenalan Jaringan Komputer ─────────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Jaringan Komputer',
  'Jaringan komputer pada dasarnya adalah...',
  '["Sistem penghubung perangkat agar saling berkomunikasi","Program antivirus","Bahasa pemrograman","Jenis basis data","Alat desain grafis"]'::jsonb,
  0,
  'Jaringan komputer menghubungkan perangkat untuk berkomunikasi dan berbagi sumber daya.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Jaringan Komputer',
  'Salah satu manfaat jaringan komputer adalah...',
  '["Harus selalu memindahkan data fisically","Berbagi printer atau file tanpa berpindah tempat","Menonaktifkan semua perangkat","Menghapus semua data","Mematikan internet"]'::jsonb,
  1,
  'Jaringan memungkinkan berbagi sumber daya seperti printer dan file secara efisien.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Jaringan Komputer',
  'Sebelum jaringan luas digunakan, pertukaran data skala besar sering dilakukan dengan...',
  '["Cloud otomatis","Memindahkan data secara fisik (mis. disket)","Hanya lewat satelit","Tanpa media apapun","Email saja"]'::jsonb,
  1,
  'Dulu data sering dipindah fisik — jaringan mengatasi keterbatasan itu.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Jaringan Komputer',
  'LAN (Local Area Network) mencakup area...',
  '["Seluruh dunia","Satu gedung atau area kecil","Hanya antar benua","Hanya satelit","Tanpa perangkat fisik"]'::jsonb,
  1,
  'LAN adalah jaringan lokal untuk area terbatas seperti satu gedung.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Jaringan Komputer',
  'MAN (Metropolitan Area Network) mencakup area...',
  '["Satu ruangan saja","Satu kota","Seluruh planet tanpa batas","Hanya dalam satu chip","Hanya kabel USB"]'::jsonb,
  1,
  'MAN mencakup jaringan skala metropolitan atau satu kota.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Jaringan Komputer',
  'WAN (Wide Area Network) dan contoh terbesarnya adalah...',
  '["LAN kantor kecil","Internet","Kabel HDMI","Hard disk","Monitor"]'::jsonb,
  1,
  'WAN mencakup area luas antar wilayah — internet adalah contoh WAN terbesar.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Jaringan Komputer',
  'Setiap jenis jaringan (LAN, MAN, WAN) memiliki perbedaan pada...',
  '["Hanya warna kabel","Karakteristik, kecepatan, dan infrastruktur","Jumlah monitor","Merek mouse","Ukuran font"]'::jsonb,
  1,
  'LAN, MAN, dan WAN berbeda cakupan, kecepatan, dan kebutuhan infrastruktur.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Jaringan Komputer',
  'Memahami perbedaan LAN, MAN, dan WAN penting karena...',
  '["Untuk memilih wallpaper","Langkah awal sebelum mempelajari cara jaringan bekerja","Agar tidak perlu internet","Supaya RAM bertambah","Agar CPU lebih dingin"]'::jsonb,
  1,
  'Membedakan jenis jaringan adalah fondasi sebelum mempelajari mekanisme komunikasi data.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Jaringan Komputer',
  'Internet menghubungkan...',
  '["Hanya dua laptop di satu meja","Miliaran perangkat di seluruh dunia","Hanya printer","Hanya server lokal","Perangkat tanpa data"]'::jsonb,
  1,
  'Internet adalah WAN global yang menghubungkan miliaran perangkat.'
FROM game_levels WHERE level_number = 4;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Jaringan Komputer',
  'Jaringan komputer secara fundamental mengubah cara manusia...',
  '["Hanya menyimpan foto offline","Bekerja, berkomunikasi, dan mengakses informasi","Mengetik tanpa keyboard","Menonton TV analog saja","Mencetak tanpa kertas"]'::jsonb,
  1,
  'Jaringan mengubah cara kerja dan akses informasi — pertukaran data jadi efisien.'
FROM game_levels WHERE level_number = 4;


-- ─── 7. VERIFIKASI SETELAH UPDATE ────────────────────────────────────────

SELECT
  gl.level_number,
  gl.title,
  gl.topic,
  gl.course_index,
  gl.material_index,
  m.title AS material_title,
  c.title AS course_title
FROM game_levels gl
JOIN materials m ON m.id = gl.material_id
JOIN courses c ON c.id = m.course_id
WHERE gl.level_number BETWEEN 1 AND 4
ORDER BY gl.level_number;

SELECT gl.level_number, COUNT(q.id) AS soal
FROM game_levels gl
LEFT JOIN questions q ON q.level_id = gl.id
WHERE gl.level_number BETWEEN 1 AND 4
GROUP BY gl.level_number
ORDER BY gl.level_number;
-- Harusnya tiap level = 10 soal
