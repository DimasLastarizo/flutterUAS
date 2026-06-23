-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Game konten BATCH 2: Level 5–8 (materi menengah)
-- Jalankan di Supabase Cloud → SQL Editor (bagian per bagian, atas ke bawah)
--
-- Level 5 → Fundamental AI                        (course 5, material sort_order 1)
-- Level 6 → Dasar-Dasar Kode Program              (course 1, material sort_order 2)
-- Level 7 → Kompleksitas dan Analisis Algoritma   (course 2, material sort_order 2)
-- Level 8 → Model dan Struktur Basis Data Relasional (course 3, material sort_order 2)
--
-- Setelah run: tutup app → flutter run ke Cloud → tes level 5–8 + Baca Materi
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK SEBELUM UPDATE ─────────────────────────────────────────────────
SELECT gl.level_number, gl.title, gl.material_id, m.title AS material_title, m.course_id, m.sort_order
FROM game_levels gl
JOIN materials m ON m.id = gl.material_id
WHERE gl.level_number BETWEEN 5 AND 8
ORDER BY gl.level_number;

SELECT gl.level_number, COUNT(q.id) AS question_count
FROM game_levels gl
LEFT JOIN questions q ON q.level_id = gl.id
WHERE gl.level_number BETWEEN 5 AND 8
GROUP BY gl.level_number
ORDER BY gl.level_number;


-- ─── 1. UPDATE METADATA LEVEL 5–8 ────────────────────────────────────────

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 5 AND sort_order = 1),
  title = 'Fundamental AI',
  topic = 'Kecerdasan Buatan',
  topic_category_index = 4,
  course_index = 4,
  material_index = 0,
  questions_count = 10
WHERE level_number = 5;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 1 AND sort_order = 2),
  title = 'Dasar-Dasar Kode Program',
  topic = 'Dasar Pemrograman',
  topic_category_index = 0,
  course_index = 0,
  material_index = 1,
  questions_count = 10
WHERE level_number = 6;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 2 AND sort_order = 2),
  title = 'Kompleksitas dan Analisis Algoritma',
  topic = 'Algoritma & Struktur Data',
  topic_category_index = 1,
  course_index = 1,
  material_index = 1,
  questions_count = 10
WHERE level_number = 7;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 3 AND sort_order = 2),
  title = 'Model dan Struktur Basis Data Relasional',
  topic = 'Basis Data',
  topic_category_index = 2,
  course_index = 2,
  material_index = 1,
  questions_count = 10
WHERE level_number = 8;


-- ─── 2. HAPUS SOAL LAMA LEVEL 5–8 ────────────────────────────────────────
DELETE FROM questions
WHERE level_id IN (
  SELECT id FROM game_levels WHERE level_number BETWEEN 5 AND 8
);


-- ─── 3. SOAL LEVEL 5 — Fundamental AI ────────────────────────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Kecerdasan Buatan',
  'Kecerdasan buatan (AI) pada dasarnya berfokus pada...',
  '["Hanya merakit hardware","Mengembangkan sistem yang mampu tugas berbasis kecerdasan manusia","Mengganti internet","Menyimpan file tanpa struktur","Memperbaiki kabel jaringan"]'::jsonb,
  1,
  'AI berfokus pada sistem yang mampu memahami bahasa, mengenali pola, mengambil keputusan, dan memecahkan masalah.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Kecerdasan Buatan',
  'Ilmuwan yang sering disebut meletakkan fondasi teoretis AI sejak 1950-an adalah...',
  '["Bill Gates","Alan Turing","Tim Berners-Lee","Nikola Tesla","Grace Hopper"]'::jsonb,
  1,
  'Alan Turing mengajukan pertanyaan fundamental tentang apakah mesin bisa berpikir.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Kecerdasan Buatan',
  'Pendekatan AI awal yang mengandalkan aturan logis manual disebut...',
  '["Deep learning","Rule-based / berbasis aturan","Subnetting","Normalisasi","Routing"]'::jsonb,
  1,
  'AI awal diprogram dengan aturan eksplisit — sistem hanya melakukan apa yang diperintahkan.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Kecerdasan Buatan',
  'Machine learning berbeda dari AI rule-based karena...',
  '["Tidak membutuhkan data","Sistem belajar pola dari data, bukan diprogram manual tiap kasus","Hanya untuk gambar","Tidak bisa prediksi","Hanya jalan offline"]'::jsonb,
  1,
  'Machine learning memungkinkan sistem menemukan pola dan membuat prediksi dari data.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Kecerdasan Buatan',
  'Deep learning terinspirasi dari...',
  '["Cara kerja otak manusia","Protokol TCP/IP","Struktur tabel SQL","Topologi LAN","Format file PDF"]'::jsonb,
  0,
  'Deep learning terinspirasi jaringan saraf biologis dan mampu memproses data kompleks.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Kecerdasan Buatan',
  'Contoh data kompleks yang sering diproses deep learning adalah...',
  '["Hanya angka bulat kecil","Gambar, suara, dan teks","Hanya tanggal kalender","Hanya warna UI","Hanya nama file"]'::jsonb,
  1,
  'Deep learning unggul pada data kompleks seperti gambar, audio, dan teks.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Kecerdasan Buatan',
  'AI modern meledak pesat sebagian besar berkat...',
  '["Keyboard lebih besar","Data besar dan komputasi yang kuat","Monitor lebih tipis","Kabel lebih panjang","Printer lebih cepat"]'::jsonb,
  1,
  'Ketersediaan big data dan peningkatan kemampuan komputasi mendorong perkembangan AI.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Kecerdasan Buatan',
  'Contoh AI tertanam dalam kehidupan sehari-hari adalah...',
  '["Rekomendasi konten dan asisten virtual","Hanya kalkulator manual","Penyimpanan floppy disk","Kabel power supply","Solder PCB"]'::jsonb,
  0,
  'Rekomendasi konten, asisten virtual, dan deteksi wajah adalah contoh AI nyata.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Kecerdasan Buatan',
  'Hubungan deep learning dan machine learning adalah...',
  '["Deep learning adalah cabang dari machine learning","Machine learning bagian dari deep learning saja","Keduanya identik tanpa beda","Deep learning tidak pakai data","Machine learning tidak belajar"]'::jsonb,
  0,
  'Deep learning adalah evolusi/cabang ML dengan jaringan neural yang lebih dalam.'
FROM game_levels WHERE level_number = 5;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Kecerdasan Buatan',
  'Tugas yang biasanya membutuhkan kecerdasan manusia dan menjadi target AI antara lain...',
  '["Memahami bahasa dan mengenali gambar","Menghitung 1+1 saja","Menyalakan lampu manual","Memutar kipas tanpa listrik","Mencetak kertas kosong"]'::jsonb,
  0,
  'AI menargetkan kemampuan seperti pemahaman bahasa, pengenalan gambar, dan pengambilan keputusan.'
FROM game_levels WHERE level_number = 5;


-- ─── 4. SOAL LEVEL 6 — Dasar-Dasar Kode Program ──────────────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Dasar Pemrograman',
  'Variabel dalam pemrograman berfungsi sebagai...',
  '["Tempat menyimpan data sementara selama program berjalan","Protokol jaringan","Kunci enkripsi","Alamat MAC","Diagram ER"]'::jsonb,
  0,
  'Variabel ibarat kotak penyimpanan bernama untuk data yang dipakai program.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Dasar Pemrograman',
  'Tipe data menentukan...',
  '["Warna icon aplikasi","Jenis nilai yang bisa disimpan variabel","Kecepatan internet","Topologi jaringan","Format video"]'::jsonb,
  1,
  'Tipe data menentukan apakah variabel menyimpan angka, teks, logika, dll.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Dasar Pemrograman',
  'Operator dalam pemrograman digunakan untuk...',
  '["Mengganti sistem operasi","Mengolah data seperti penjumlahan atau perbandingan","Menghapus database","Mengatur DNS","Membuat kabel"]'::jsonb,
  1,
  'Operator mengolah data: aritmatika, perbandingan, penggabungan, dll.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Dasar Pemrograman',
  'Struktur percabangan (kondisional) memungkinkan program...',
  '["Selalu menjalankan baris yang sama","Mengambil keputusan berdasarkan kondisi","Menghapus semua variabel","Berhenti tanpa alasan","Tidak menerima input"]'::jsonb,
  1,
  'Percabangan seperti if/else membuat program bereaksi sesuai kondisi.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Dasar Pemrograman',
  'Perulangan (loop) berguna ketika...',
  '["Tugas perlu dilakukan berulang tanpa menulis perintah sama berkali-kali","Program tidak perlu logika","Data tidak boleh diubah","Variabel dilarang","Output harus kosong"]'::jsonb,
  0,
  'Loop otomatisasi tugas berulang, misalnya memproses banyak data sekaligus.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Dasar Pemrograman',
  'Contoh nilai logika (boolean) yang valid adalah...',
  '["true atau false","Hanya angka desimal","Hanya teks panjang","Hanya warna RGB","Hanya tanggal"]'::jsonb,
  0,
  'Tipe logika menyimpan nilai benar (true) atau salah (false).'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Dasar Pemrograman',
  'Kombinasi variabel, tipe data, dan operator disebut...',
  '["Bahan baku utama menulis program","Protokol HTTP","Foreign key","Subnet mask","Firewall rule"]'::jsonb,
  0,
  'Ketiganya menjadi fondasi dasar sebelum struktur program lebih kompleks.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Dasar Pemrograman',
  'Percabangan "jika ini maka itu, jika tidak maka lain" menggambarkan...',
  '["Perulangan","Kondisional","Normalisasi","Routing","Enkripsi"]'::jsonb,
  1,
  'Itu adalah konsep percabangan atau kondisional dalam alur program.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Dasar Pemrograman',
  'Dengan percabangan dan perulangan, program sudah bisa...',
  '["Hanya menampilkan teks statis","Mengambil keputusan dan bekerja otomatis","Tanpa input apapun","Hanya satu langkah","Tidak menggunakan data"]'::jsonb,
  1,
  'Keduanya memungkinkan program dinamis, efisien, dan otomatis.'
FROM game_levels WHERE level_number = 6;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Dasar Pemrograman',
  'Memproses seratus data sekaligus lebih efisien dengan...',
  '["Menulis 100 baris identik manual","Struktur perulangan","Menghapus variabel","Tanpa operator","Hanya percabangan tanpa loop"]'::jsonb,
  1,
  'Perulangan menghindari penulisan ulang perintah yang sama untuk banyak data.'
FROM game_levels WHERE level_number = 6;


-- ─── 5. SOAL LEVEL 7 — Kompleksitas dan Analisis Algoritma ───────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Algoritma & Struktur Data',
  'Analisis algoritma mengukur efisiensi berdasarkan...',
  '["Warna UI saja","Kebutuhan waktu dan memori","Merek laptop","Jumlah monitor","Ukuran font"]'::jsonb,
  1,
  'Analisis algoritma fokus pada konsumsi waktu eksekusi dan memori.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Algoritma & Struktur Data',
  'Algoritma lambat pada data kecil bisa menjadi masalah besar ketika...',
  '["Diterapkan pada data berskala besar","Hanya di HP","Tidak ada internet","Layar mati","Keyboard rusak"]'::jsonb,
  0,
  'Skala data besar memperbesar dampak algoritma yang tidak efisien.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Algoritma & Struktur Data',
  'Big O Notation digunakan untuk...',
  '["Menyimpan password","Mengekspresikan performa algoritma saat data bertambah","Menggambar flowchart","Membuat tabel SQL","Mengatur IP address"]'::jsonb,
  1,
  'Big O menggambarkan pertumbuhan waktu/ruang algoritma terhadap ukuran input.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Algoritma & Struktur Data',
  'Notasi O(n) berarti waktu proses bertambah...',
  '["Secara linear seiring data bertambah","Selalu konstanta","Secara kuadrat pasti","Menjadi nol","Acak tanpa pola"]'::jsonb,
  0,
  'O(n) = linear — operasi bertambah proporsional dengan jumlah data.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Algoritma & Struktur Data',
  'Notasi O(n²) cenderung...',
  '["Sangat cepat untuk data besar","Sangat lambat untuk data berukuran besar","Tidak pernah dipakai","Sama dengan O(1)","Hanya untuk sorting"]'::jsonb,
  1,
  'O(n²) tumbuh jauh lebih cepat dan sering lambat pada data besar.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Algoritma & Struktur Data',
  'Efisiensi memori dalam analisis algoritma diukur dari...',
  '["Besar ruang penyimpanan yang digunakan","Warna tema app","Jumlah emoji","Panjang username","Merek router"]'::jsonb,
  0,
  'Selain waktu, analisis juga mempertimbangkan konsumsi memori algoritma.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Algoritma & Struktur Data',
  'Membandingkan dua algoritma secara objektif bisa memakai...',
  '["Big O Notation","Warna avatar","Jumlah like","Nama file","Logo perusahaan"]'::jsonb,
  0,
  'Big O membantu perbandingan efisiensi algoritma secara matematis.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Algoritma & Struktur Data',
  'Ketika ada beberapa algoritma untuk masalah sama, pertanyaan kunci adalah...',
  '["Mana yang paling efisien untuk kebutuhan data","Mana yang paling panjang kodenya","Mana yang paling jarang dipakai","Mana yang tanpa logika","Mana yang tanpa output"]'::jsonb,
  0,
  'Pemilihan algoritma harus mempertimbangkan efisiensi dan skala data.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Algoritma & Struktur Data',
  'Big O sering diujikan dalam wawancara teknologi karena...',
  '["Mengukur kemampuan analisis efisiensi solusi","Hanya hafalan warna","Tidak relevan di industri","Mengganti SQL","Untuk desain logo"]'::jsonb,
  0,
  'Memahami kompleksitas algoritma adalah keterampilan krusial di industri tech.'
FROM game_levels WHERE level_number = 7;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Algoritma & Struktur Data',
  'Operasi algoritma diukur seiring bertambahnya...',
  '["Jumlah data masukan (input size)","Jumlah monitor","Ukuran keyboard","Panjang kabel LAN","Jumlah tab browser"]'::jsonb,
  0,
  'Analisis kompleksitas melihat bagaimana performa berubah saat input bertambah.'
FROM game_levels WHERE level_number = 7;


-- ─── 6. SOAL LEVEL 8 — Model dan Struktur Basis Data Relasional ──────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Basis Data',
  'Basis data relasional menyimpan data dalam bentuk...',
  '["Tabel berisi baris dan kolom","Hanya file teks acak","Hanya gambar","Hanya video stream","Folder tanpa struktur"]'::jsonb,
  0,
  'Model relasional menggunakan tabel dengan baris (record) dan kolom (field).'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Basis Data',
  'Setiap baris dalam tabel relasional disebut...',
  '["Record","Protokol","Packet","Subnet","Loop"]'::jsonb,
  0,
  'Satu baris mewakili satu record/data unik dalam tabel.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Basis Data',
  'Foreign key berfungsi untuk...',
  '["Menghubungkan antar tabel","Mengganti primary key","Menghapus database","Mengatur DNS","Mempercepat CPU"]'::jsonb,
  0,
  'Foreign key menciptakan relasi antar tabel agar data bisa digabungkan.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Basis Data',
  'Primary key adalah...',
  '["Identitas unik setiap record, tidak boleh kosong/duplikat","Kolom opsional sembarang","Password admin","Alamat IP","Nama file backup"]'::jsonb,
  0,
  'Primary key mengidentifikasi setiap baris secara unik dalam tabel.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Basis Data',
  'Normalisasi bertujuan...',
  '["Menyimpan data berulang di banyak tempat","Mengorganisir tabel agar data tidak redundan","Menghapus semua relasi","Mengganti SQL","Mematikan transaksi"]'::jsonb,
  1,
  'Normalisasi merapikan struktur tabel dan mengurangi duplikasi data.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Basis Data',
  'Kekuatan utama basis data relasional adalah...',
  '["Merepresentasikan hubungan antar data kompleks secara efisien","Tanpa struktur apapun","Hanya satu baris per database","Tidak bisa JOIN","Tanpa kunci"]'::jsonb,
  0,
  'Relasi antar tabel via kunci memungkinkan data terhubung dan diolah bersama.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Basis Data',
  'Tabel "pelanggan" dan "transaksi" biasanya dihubungkan lewat...',
  '["Foreign key","MAC address","HTTP header","Flowchart","Big O"]'::jsonb,
  0,
  'Foreign key menghubungkan transaksi ke pelanggan terkait.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Basis Data',
  'Rancangan basis data yang baik penting karena...',
  '["Fondasi sistem efisien seiring data terus bertambah","Hanya untuk tampilan UI","Tidak mempengaruhi performa","Mengganti kebutuhan backup","Menghilangkan DBMS"]'::jsonb,
  0,
  'Desain tabel yang baik menjaga sistem tetap benar dan efisien jangka panjang.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Basis Data',
  'Setiap tabel idealnya merepresentasikan...',
  '["Satu entitas (mis. produk, pelanggan)","Semua data dunia dalam satu baris","Hanya metadata jaringan","Hanya log error","Hanya cache browser"]'::jsonb,
  0,
  'Praktik baik: satu tabel untuk satu jenis entitas.'
FROM game_levels WHERE level_number = 8;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Basis Data',
  'Data yang disimpan berulang di banyak tabel tanpa perencanaan menimbulkan...',
  '["Redundansi dan inkonsistensi","Peningkatan keamanan otomatis","Tidak perlu primary key","JOIN tidak mungkin","Transaksi ACID hilang"]'::jsonb,
  0,
  'Redundansi sulit dirawat — normalisasi mengatasi masalah ini.'
FROM game_levels WHERE level_number = 8;


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
WHERE gl.level_number BETWEEN 5 AND 8
ORDER BY gl.level_number;

SELECT gl.level_number, COUNT(q.id) AS soal
FROM game_levels gl
LEFT JOIN questions q ON q.level_id = gl.id
WHERE gl.level_number BETWEEN 5 AND 8
GROUP BY gl.level_number
ORDER BY gl.level_number;

-- Cek duplikat teks soal di batch 2 (harusnya 0 baris)
SELECT question, COUNT(*) AS jumlah
FROM questions q
JOIN game_levels gl ON gl.id = q.level_id
WHERE gl.level_number BETWEEN 5 AND 8
GROUP BY question
HAVING COUNT(*) > 1;
