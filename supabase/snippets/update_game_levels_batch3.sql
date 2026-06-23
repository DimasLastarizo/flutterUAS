-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Game konten BATCH 3: Level 9–12 (materi lanjutan)
-- Jalankan di Supabase Cloud → SQL Editor (bagian per bagian, atas ke bawah)
--
-- Level  9 → Protokol dan Model Komunikasi Jaringan              (course 4, material sort_order 2)
-- Level 10 → Pengalamatan dan Routing Jaringan                 (course 4, material sort_order 3)
-- Level 11 → Struktur Data Dasar                                 (course 2, material sort_order 3)
-- Level 12 → Algoritma Pencarian, Pengurutan, dan Struktur Data Lanjutan (course 2, material sort_order 4)
--
-- Relasi Game ↔ Materi:
--   Tombol "Baca Materi" di level mengarah ke material_id yang sama di halaman Materi.
--   Soal harus selaras dengan bacaan + key_points materi terkait (sudah diisi di snippet materi).
--
-- Setelah run: tutup app → flutter run ke Cloud → tes level 9–12 + Baca Materi
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK SEBELUM UPDATE ─────────────────────────────────────────────────
SELECT gl.level_number, gl.title, gl.material_id, m.title AS material_title, m.course_id, m.sort_order
FROM game_levels gl
JOIN materials m ON m.id = gl.material_id
WHERE gl.level_number BETWEEN 9 AND 12
ORDER BY gl.level_number;

SELECT gl.level_number, COUNT(q.id) AS question_count
FROM game_levels gl
LEFT JOIN questions q ON q.level_id = gl.id
WHERE gl.level_number BETWEEN 9 AND 12
GROUP BY gl.level_number
ORDER BY gl.level_number;


-- ─── 1. UPDATE METADATA LEVEL 9–12 ───────────────────────────────────────

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 4 AND sort_order = 2),
  title = 'Protokol dan Model Komunikasi Jaringan',
  topic = 'Jaringan Komputer',
  topic_category_index = 3,
  course_index = 3,
  material_index = 1,
  questions_count = 10
WHERE level_number = 9;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 4 AND sort_order = 3),
  title = 'Pengalamatan dan Routing Jaringan',
  topic = 'Jaringan Komputer',
  topic_category_index = 3,
  course_index = 3,
  material_index = 2,
  questions_count = 10
WHERE level_number = 10;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 2 AND sort_order = 3),
  title = 'Struktur Data Dasar',
  topic = 'Algoritma & Struktur Data',
  topic_category_index = 1,
  course_index = 1,
  material_index = 2,
  questions_count = 10
WHERE level_number = 11;

UPDATE game_levels SET
  material_id = (SELECT id FROM materials WHERE course_id = 2 AND sort_order = 4),
  title = 'Algoritma Pencarian, Pengurutan, dan Struktur Data Lanjutan',
  topic = 'Algoritma & Struktur Data',
  topic_category_index = 1,
  course_index = 1,
  material_index = 3,
  questions_count = 10
WHERE level_number = 12;


-- ─── 2. HAPUS SOAL LAMA LEVEL 9–12 ───────────────────────────────────────
DELETE FROM questions
WHERE level_id IN (
  SELECT id FROM game_levels WHERE level_number BETWEEN 9 AND 12
);


-- ─── 3. SOAL LEVEL 9 — Protokol dan Model Komunikasi Jaringan ────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Jaringan Komputer',
  'Protokol jaringan pada dasarnya adalah...',
  '["Aturan komunikasi yang disepakati agar perangkat bisa saling bertukar data","Program antivirus","Bahasa pemrograman","Jenis kabel LAN","Format file gambar"]'::jsonb,
  0,
  'Protokol menentukan bagaimana data dikemas, dikirim, diterima, dan diinterpretasikan antar perangkat.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Jaringan Komputer',
  'Tanpa protokol, dua perangkat yang sudah terhubung fisik...',
  '["Otomatis saling mengerti","Tidak akan bisa berkomunikasi secara bermakna","Langsung terenkripsi","Tidak perlu IP address","Selalu lebih cepat"]'::jsonb,
  1,
  'Koneksi fisik saja tidak cukup — protokol membuat perangkat berbeda bisa "saling mengerti".'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Jaringan Komputer',
  'Protokol yang menjadi tulang punggung komunikasi internet modern adalah...',
  '["FTP saja","TCP/IP","JPEG","SQL","HTML semata"]'::jsonb,
  1,
  'TCP/IP adalah protokol paling fundamental yang menjadi dasar kerja internet.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Jaringan Komputer',
  'Model OSI membagi proses komunikasi jaringan menjadi...',
  '["Empat lapisan","Tujuh lapisan","Dua lapisan","Sepuluh lapisan","Satu lapisan saja"]'::jsonb,
  1,
  'Model OSI memiliki 7 lapisan, dari fisik hingga aplikasi.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Jaringan Komputer',
  'Model TCP/IP dibanding OSI lebih...',
  '["Teoretis dan jarang dipakai","Praktis dengan empat lapisan dan banyak diimplementasikan","Hanya untuk LAN","Tanpa protokol","Hanya untuk email"]'::jsonb,
  1,
  'TCP/IP menyederhanakan OSI menjadi 4 lapisan praktis yang menjadi dasar internet nyata.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Jaringan Komputer',
  'Memahami model OSI/TCP/IP membantu teknisi...',
  '["Memilih wallpaper","Mendiagnosis masalah jaringan secara sistematis per lapisan","Menghapus database","Mengompilasi program","Mendesain logo"]'::jsonb,
  1,
  'Model lapisan membantu menentukan di tahap mana masalah jaringan kemungkinan terjadi.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Jaringan Komputer',
  'Protokol menentukan hal-hal berikut, KECUALI...',
  '["Cara data dikemas","Cara data dikirim dan diterima","Cara data diinterpretasikan","Warna casing router","Aturan komunikasi antar perangkat"]'::jsonb,
  3,
  'Protokol mengatur komunikasi data, bukan aspek fisik/perangkat keras seperti warna casing.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Jaringan Komputer',
  'Agar perangkat beda merek dan sistem operasi bisa saling berkomunikasi, dibutuhkan...',
  '["Monitor yang sama","Protokol sebagai aturan bersama","Hard disk identik","Keyboard yang sama","Satu merek router saja"]'::jsonb,
  1,
  'Protokol adalah aturan bersama yang memungkinkan interoperabilitas antar perangkat berbeda.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Jaringan Komputer',
  'Lapisan aplikasi dalam model referensi jaringan berinteraksi langsung dengan...',
  '["Sinyal listrik mentah","Pengguna dan aplikasi","Kabel fiber optik saja","Prosesor CPU","Hard disk"]'::jsonb,
  1,
  'Lapisan aplikasi (layer 7 OSI) adalah yang paling dekat dengan pengguna dan software.'
FROM game_levels WHERE level_number = 9;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Jaringan Komputer',
  'Perbedaan utama model OSI dan TCP/IP adalah...',
  '["OSI lebih praktis di lapangan","TCP/IP lebih teoretis","OSI 7 lapisan teoretis, TCP/IP 4 lapisan praktis","Keduanya identik","TCP/IP tidak dipakai internet"]'::jsonb,
  2,
  'OSI sebagai referensi 7 lapisan; TCP/IP 4 lapisan yang lebih praktis dan dominan di internet.'
FROM game_levels WHERE level_number = 9;


-- ─── 4. SOAL LEVEL 10 — Pengalamatan dan Routing Jaringan ────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Jaringan Komputer',
  'IP address berfungsi sebagai...',
  '["Identitas logis perangkat untuk menentukan tujuan pengiriman data","Password WiFi","Nama domain website","Format file video","Algoritma sorting"]'::jsonb,
  0,
  'IP address bekerja seperti alamat rumah — identitas logis agar data sampai ke perangkat yang tepat.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Jaringan Komputer',
  'MAC address berbeda dari IP address karena MAC...',
  '["Bersifat permanen dan tertanam pada perangkat keras","Selalu bisa diubah user","Hanya untuk website","Sama dengan DNS","Hanya dipakai router"]'::jsonb,
  0,
  'MAC address permanen di hardware; IP address logis dan bisa berubah.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Jaringan Komputer',
  'Routing adalah proses...',
  '["Menyimpan file di cloud","Menentukan jalur terbaik data menuju tujuan","Mengompilasi kode program","Menghapus virus","Memformat hard disk"]'::jsonb,
  1,
  'Routing menentukan jalur yang harus dilalui paket data agar sampai ke jaringan/perangkat tujuan.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Jaringan Komputer',
  'Perangkat yang bertugas routing antar jaringan berbeda adalah...',
  '["Switch","Router","Monitor","Printer","Scanner"]'::jsonb,
  1,
  'Router meneruskan paket data antar jaringan; switch mengarahkan data dalam satu LAN.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Jaringan Komputer',
  'Switch pada jaringan lokal berfungsi...',
  '["Meneruskan paket antar negara","Mengarahkan data di dalam satu jaringan lokal","Mengenkripsi semua email","Mengganti IP global","Menyimpan backup database"]'::jsonb,
  1,
  'Switch menghubungkan perangkat dalam LAN yang sama dan mengarahkan frame ke tujuan lokal.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Jaringan Komputer',
  'Subnetting bertujuan...',
  '["Memperbesar satu jaringan tanpa batas","Membagi jaringan besar menjadi sub-jaringan lebih kecil yang efisien","Menghapus IP address","Mengganti protokol TCP","Mematikan router"]'::jsonb,
  1,
  'Subnetting membagi jaringan besar agar pengelolaan alamat IP lebih terorganisir dan efisien.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Jaringan Komputer',
  'IP address digunakan untuk menentukan...',
  '["Tujuan akhir pengiriman data","Warna kabel","Kecepatan CPU","Resolusi monitor","Format audio"]'::jsonb,
  0,
  'IP address menentukan tujuan logis; MAC address dipakai untuk komunikasi dalam jaringan lokal.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Jaringan Komputer',
  'Ketika data dikirim ke perangkat di jaringan berbeda, proses yang terjadi adalah...',
  '["Normalisasi tabel","Routing","Compiling","Bubble sort","Enkapsulasi OOP"]'::jsonb,
  1,
  'Routing diperlukan saat tujuan berada di jaringan lain — router menentukan jalur terbaik.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Jaringan Komputer',
  'Pemahaman pengalamatan dan routing penting karena...',
  '["Kompetensi inti di bidang jaringan komputer","Hanya untuk desain UI","Tidak relevan di era cloud","Mengganti kebutuhan protokol","Menghilangkan kebutuhan IP"]'::jsonb,
  0,
  'Pengalamatan dan routing adalah fondasi praktis administrasi dan troubleshooting jaringan.'
FROM game_levels WHERE level_number = 10;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Jaringan Komputer',
  'MAC address dan IP address bekerja sama dalam pengiriman data, di mana...',
  '["Keduanya identik fungsinya","IP untuk tujuan akhir, MAC untuk komunikasi lokal","MAC untuk internet global saja","IP hanya untuk printer","MAC menggantikan DNS"]'::jsonb,
  1,
  'IP menentukan tujuan end-to-end; MAC dipakai untuk pengiriman frame dalam segmen jaringan lokal.'
FROM game_levels WHERE level_number = 10;


-- ─── 5. SOAL LEVEL 11 — Struktur Data Dasar ──────────────────────────────

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Algoritma & Struktur Data',
  'Struktur data adalah...',
  '["Cara mengorganisir data dalam memori agar diakses dan diproses efisien","Protokol jaringan","Bahasa query SQL","Jenis kabel LAN","Format file PDF"]'::jsonb,
  0,
  'Struktur data menentukan bagaimana data disusun di memori sesuai kebutuhan operasi program.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Algoritma & Struktur Data',
  'Array menyimpan elemen dengan cara...',
  '["Acak tanpa urutan","Berurutan dan diakses via indeks","Hanya sebagai teks","Tanpa bisa diubah","Hanya satu elemen"]'::jsonb,
  1,
  'Array adalah kumpulan elemen berurutan yang diakses menggunakan indeks numerik.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Algoritma & Struktur Data',
  'Linked list dibanding array lebih fleksibel dalam...',
  '["Penambahan dan penghapusan elemen","Akses indeks acak yang selalu O(1)","Penyimpanan tanpa pointer","Ukuran yang selalu tetap","Tanpa node"]'::jsonb,
  0,
  'Linked list memudahkan insert/delete karena elemen dihubungkan pointer, tidak perlu geser massal.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Algoritma & Struktur Data',
  'Stack menerapkan prinsip...',
  '["First In, First Out (FIFO)","Last In, First Out (LIFO)","Random access only","Tanpa urutan","Hanya untuk teks"]'::jsonb,
  1,
  'Stack: elemen terakhir masuk adalah yang pertama keluar (LIFO), seperti tumpukan piring.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Algoritma & Struktur Data',
  'Queue menerapkan prinsip...',
  '["Last In, First Out (LIFO)","First In, First Out (FIFO)","Tanpa antrian","Hanya satu elemen","Acak"]'::jsonb,
  1,
  'Queue: yang pertama masuk dilayani pertama (FIFO), seperti antrian kasir.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Algoritma & Struktur Data',
  'Contoh penerapan stack di dunia nyata adalah...',
  '["Antrian permintaan server web","Tombol back pada browser / undo","DNS lookup","JOIN SQL","Subnetting"]'::jsonb,
  1,
  'Stack dipakai untuk navigasi back, undo, dan manajemen memori call stack.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Algoritma & Struktur Data',
  'Contoh penerapan queue di dunia nyata adalah...',
  '["Tumpukan undo editor","Antrian permintaan di server web","Binary search tree","Primary key","Flowchart"]'::jsonb,
  1,
  'Queue banyak dipakai untuk antrian job/task, seperti permintaan ke server.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Algoritma & Struktur Data',
  'Pemilihan struktur data yang tepat mempengaruhi...',
  '["Hanya warna UI","Performa dan efisiensi program secara keseluruhan","Merek laptop","Kecepatan internet","Format video"]'::jsonb,
  1,
  'Struktur data dan algoritma saling bergantung — keduanya menentukan performa program.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Algoritma & Struktur Data',
  'Linked list menyimpan data dalam bentuk...',
  '["Tabel baris-kolom","Rantai simpul (node) yang saling terhubung","File teks acak","Subnet IP","Record database saja"]'::jsonb,
  1,
  'Setiap node linked list berisi data dan referensi ke node berikutnya.'
FROM game_levels WHERE level_number = 11;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Algoritma & Struktur Data',
  'Struktur data paling dasar yang diakses lewat indeks numerik adalah...',
  '["Graph","Array","Queue saja","Tree saja","Hash table saja"]'::jsonb,
  1,
  'Array adalah struktur data fundamental dengan akses indeks langsung.'
FROM game_levels WHERE level_number = 11;


-- ─── 6. SOAL LEVEL 12 — Algoritma Pencarian, Pengurutan, dan Struktur Data Lanjutan

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 1, 'Algoritma & Struktur Data',
  'Pencarian linear (linear search) bekerja dengan...',
  '["Membagi data menjadi dua setiap langkah","Memeriksa setiap elemen satu per satu","Hanya pada data terurut","Tanpa memeriksa elemen","Hanya via indeks acak"]'::jsonb,
  1,
  'Linear search memeriksa elemen secara berurutan dari awal hingga ditemukan.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 2, 'Algoritma & Struktur Data',
  'Binary search dapat digunakan jika data...',
  '["Acak tanpa urutan","Sudah terurut (sorted)","Hanya berisi teks","Kosong","Lebih dari 1 juta elemen saja"]'::jsonb,
  1,
  'Binary search membagi data terurut menjadi dua — syarat mutlak data harus sorted.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 3, 'Algoritma & Struktur Data',
  'Dibanding linear search, binary search pada data besar cenderung...',
  '["Lebih lambat","Jauh lebih cepat (dengan syarat data terurut)","Sama cepatnya selalu","Tidak bisa dipakai","Hanya untuk string"]'::jsonb,
  1,
  'Binary search O(log n) jauh lebih efisien daripada linear O(n) pada data besar terurut.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 4, 'Algoritma & Struktur Data',
  'Bubble sort dikenal...',
  '["Paling efisien untuk data besar","Mudah dipahami namun lambat untuk data besar","Hanya untuk data terurut","Tidak termasuk algoritma sorting","O(log n)"]'::jsonb,
  1,
  'Bubble sort sederhana untuk dipelajari, tetapi O(n²) sehingga lambat pada data besar.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 5, 'Algoritma & Struktur Data',
  'Merge sort dan quick sort dibanding bubble sort untuk data besar...',
  '["Lebih lambat","Jauh lebih efisien","Tidak bisa sorting","Hanya untuk 10 elemen","Identik performa"]'::jsonb,
  1,
  'Merge/quick sort jauh lebih efisien (biasanya O(n log n)) untuk skala data besar.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 6, 'Algoritma & Struktur Data',
  'Tree (pohon) adalah struktur data...',
  '["Linier tanpa cabang","Hierarkis dengan hubungan bertingkat","Hanya FIFO","Hanya LIFO","Tanpa relasi antar node"]'::jsonb,
  1,
  'Tree merepresentasikan hubungan hierarkis parent-child, seperti folder atau organisasi.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 7, 'Algoritma & Struktur Data',
  'Binary search tree (BST) memungkinkan...',
  '["Pencarian data dengan efisien via struktur hierarkis","Hanya penyimpanan teks","Tanpa perbandingan nilai","Hanya untuk graph","Sorting tanpa data"]'::jsonb,
  0,
  'BST memanfaatkan properti urutan kiri-kanan untuk pencarian dan insert yang efisien.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 8, 'Algoritma & Struktur Data',
  'Graph merepresentasikan...',
  '["Hanya data linier berurutan","Hubungan antar entitas secara bebas tanpa hierarki kaku","Hanya tabel SQL","Hanya antrian FIFO","Satu node saja"]'::jsonb,
  1,
  'Graph model hubungan bebas antar vertex — dipakai navigasi, sosial media, rekomendasi.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 9, 'Algoritma & Struktur Data',
  'Contoh aplikasi nyata graph adalah...',
  '["Kalkulator sederhana","Peta navigasi dan jaringan sosial","Penyimpanan boolean saja","Format CSV saja","Subnet mask"]'::jsonb,
  1,
  'Graph menjadi fondasi peta rute, jaringan pertemanan, dan sistem rekomendasi.'
FROM game_levels WHERE level_number = 12;

INSERT INTO questions (level_id, sort_order, category, question, options, answer_index, explanation)
SELECT id, 10, 'Algoritma & Struktur Data',
  'Menguasai pencarian, pengurutan, tree, dan graph menandakan programmer...',
  '["Baru belajar variabel","Siap memecahkan masalah kompleks di dunia nyata","Tidak perlu analisis algoritma","Hanya bisa HTML","Tidak perlu struktur data"]'::jsonb,
  1,
  'Topik lanjutan ini menunjukkan kesiapan menghadapi masalah skala dan kompleksitas nyata.'
FROM game_levels WHERE level_number = 12;


-- ─── 7. VERIFIKASI SETELAH UPDATE ────────────────────────────────────────

SELECT
  gl.level_number,
  gl.title,
  gl.topic,
  gl.course_index,
  gl.material_index,
  m.title AS material_title,
  c.title AS course_title,
  m.sort_order AS material_sort_order
FROM game_levels gl
JOIN materials m ON m.id = gl.material_id
JOIN courses c ON c.id = m.course_id
WHERE gl.level_number BETWEEN 9 AND 12
ORDER BY gl.level_number;

SELECT gl.level_number, COUNT(q.id) AS soal
FROM game_levels gl
LEFT JOIN questions q ON q.level_id = gl.id
WHERE gl.level_number BETWEEN 9 AND 12
GROUP BY gl.level_number
ORDER BY gl.level_number;
-- Harusnya tiap level = 10 soal

-- Cek duplikat teks soal di batch 3 (harusnya 0 baris)
SELECT question, COUNT(*) AS jumlah
FROM questions q
JOIN game_levels gl ON gl.id = q.level_id
WHERE gl.level_number BETWEEN 9 AND 12
GROUP BY question
HAVING COUNT(*) > 1;

-- Ringkasan relasi Game ↔ Materi (12 level penuh)
SELECT
  gl.level_number,
  gl.title AS level_title,
  c.title AS course,
  m.title AS linked_material,
  m.sort_order
FROM game_levels gl
JOIN materials m ON m.id = gl.material_id
JOIN courses c ON c.id = m.course_id
ORDER BY gl.level_number;
