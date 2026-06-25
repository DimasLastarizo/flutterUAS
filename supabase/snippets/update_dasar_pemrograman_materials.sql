-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Update konten materi: Dasar Pemrograman (course_id = 1)
-- Jalankan di Supabase Cloud → SQL Editor
-- Video intro: belum diisi (intro_video_url tetap kosong)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK DATA SEBELUM UPDATE (jalankan dulu, catat id jika perlu) ───────
SELECT id, course_id, sort_order, title
FROM materials
WHERE course_id = 1
ORDER BY sort_order;

SELECT id, title, description, intro_video_url
FROM courses
WHERE id = 1;


-- ─── 1. UPDATE DESKRIPSI MATA PELAJARAN ───────────────────────────────────
UPDATE courses
SET
  description = 'Pelajari fondasi pemrograman: algoritma, variabel, percabangan, perulangan, fungsi, struktur data, hingga konsep OOP.',
  modules_total = 4
WHERE id = 1;


-- ─── 2. MATERI 1 — Pengenalan Pemrograman (sort_order = 1, Bacaan Utama) ─
UPDATE materials
SET
  title = 'Pengenalan Pemrograman',
  emoji = '📘',
  duration_label = 'Ringkas',
  content = $$Pemrograman adalah proses memberikan instruksi kepada komputer agar dapat menyelesaikan suatu tugas tertentu. Komputer sendiri tidak bisa berpikir seperti manusia — ia hanya menjalankan perintah yang diberikan secara tepat dan berurutan. Oleh karena itu, seorang programmer perlu menyusun langkah-langkah penyelesaian masalah secara logis sebelum menuliskannya dalam bentuk kode. Langkah-langkah terstruktur inilah yang disebut algoritma, dan seringkali divisualisasikan menggunakan diagram alur bernama flowchart agar lebih mudah dipahami sebelum diimplementasikan.

Bahasa pemrograman adalah jembatan antara manusia dan komputer. Ada banyak bahasa pemrograman yang tersedia seperti Python, Java, dan C++, masing-masing dirancang untuk kebutuhan yang berbeda. Namun apapun bahasanya, semua program pada dasarnya bekerja dengan prinsip yang sama: menerima masukan, memprosesnya, lalu menghasilkan keluaran. Memahami konsep dasar ini adalah fondasi paling penting sebelum seseorang melangkah lebih jauh ke dunia pemrograman.$$,
  key_points = '[
    "Pemrograman adalah cara manusia memberikan instruksi kepada komputer secara terstruktur dan logis.",
    "Algoritma adalah inti dari setiap program — tanpa algoritma yang jelas, kode yang ditulis tidak akan efektif.",
    "Flowchart membantu memvisualisasikan alur logika sebelum kode ditulis.",
    "Semua bahasa pemrograman bekerja dengan prinsip dasar yang sama: masukan, proses, dan keluaran."
  ]'::jsonb,
  sort_order = 1,
  is_published = true
WHERE course_id = 1 AND sort_order = 1;


-- ─── 3. MATERI 2 — Dasar-Dasar Kode Program ───────────────────────────────
UPDATE materials
SET
  title = 'Dasar-Dasar Kode Program',
  emoji = '💻',
  duration_label = 'Teori',
  content = $$Setiap program yang ditulis pasti bekerja dengan data, dan untuk menyimpan data tersebut digunakan yang namanya variabel. Variabel ibarat sebuah kotak penyimpanan yang diberi nama, di mana di dalamnya bisa tersimpan angka, teks, atau nilai logika benar/salah — inilah yang disebut tipe data. Selain menyimpan data, program juga perlu mengolahnya menggunakan operator seperti penjumlahan, perbandingan, atau penggabungan. Kombinasi variabel, tipe data, dan operator inilah yang menjadi bahan baku utama dalam menulis sebuah program.

Agar program bisa bereaksi terhadap situasi yang berbeda, dibutuhkan struktur percabangan seperti "jika ini maka lakukan itu, jika tidak maka lakukan yang lain." Konsep inilah yang dikenal sebagai percabangan atau kondisional. Selain itu, banyak tugas dalam pemrograman yang perlu dilakukan berulang kali, misalnya memproses seratus data sekaligus — untuk itu digunakan struktur perulangan. Dengan memahami percabangan dan perulangan, seorang programmer sudah bisa menulis program yang mampu mengambil keputusan dan bekerja secara otomatis dan efisien.$$,
  key_points = '[
    "Variabel adalah tempat menyimpan data sementara selama program berjalan.",
    "Tipe data menentukan jenis nilai yang bisa disimpan, seperti angka, teks, atau nilai logika.",
    "Percabangan memungkinkan program mengambil keputusan berdasarkan kondisi tertentu.",
    "Perulangan memungkinkan program mengerjakan tugas yang sama secara otomatis tanpa harus menulis ulang perintah berkali-kali."
  ]'::jsonb,
  sort_order = 2,
  is_published = true
WHERE course_id = 1 AND sort_order = 2;


-- ─── 4. MATERI 3 — Struktur Program yang Lebih Terorganisir ───────────────
UPDATE materials
SET
  title = 'Struktur Program yang Lebih Terorganisir',
  emoji = '🧩',
  duration_label = 'Analisis',
  content = $$Seiring bertambahnya kompleksitas sebuah program, menulis semua instruksi dalam satu blok besar menjadi tidak efisien dan sulit dipahami. Di sinilah konsep fungsi atau prosedur berperan penting — yaitu cara memecah program besar menjadi bagian-bagian kecil yang masing-masing memiliki tugas spesifik. Fungsi bisa dipanggil kapan saja dibutuhkan tanpa harus menulis ulang logikanya, sehingga kode menjadi lebih ringkas, mudah dibaca, dan mudah diperbaiki jika ada kesalahan.

Selain fungsi, program yang terorganisir juga membutuhkan cara menyimpan banyak data sekaligus secara efisien. Untuk itulah digunakan array atau list, yang memungkinkan penyimpanan kumpulan data dalam satu wadah yang terstruktur. Lebih jauh, terdapat berbagai struktur data seperti tumpukan, antrian, dan peta yang masing-masing dirancang untuk kasus penggunaan tertentu. Memilih struktur data yang tepat adalah salah satu keterampilan penting yang membedakan programmer pemula dengan programmer yang sudah berpengalaman.$$,
  key_points = '[
    "Fungsi memungkinkan program dipecah menjadi bagian kecil yang memiliki tugas spesifik dan bisa digunakan kembali.",
    "Kode yang terstruktur dengan fungsi jauh lebih mudah dibaca, dikelola, dan diperbaiki.",
    "Array dan list adalah cara menyimpan banyak data sekaligus dalam satu wadah yang terorganisir.",
    "Pemilihan struktur data yang tepat sangat mempengaruhi efisiensi dan performa sebuah program."
  ]'::jsonb,
  sort_order = 3,
  is_published = true
WHERE course_id = 1 AND sort_order = 3;


-- ─── 5. MATERI 4 — Pemrograman Berorientasi Objek & Logika Lanjutan ───────
UPDATE materials
SET
  title = 'Pemrograman Berorientasi Objek & Logika Lanjutan',
  emoji = '🏗️',
  duration_label = 'Lanjutan',
  content = $$Pemrograman Berorientasi Objek atau OOP adalah paradigma pemrograman yang mengorganisir program berdasarkan "objek" — representasi dari benda atau konsep di dunia nyata yang memiliki data (atribut) dan perilaku (metode) tersendiri. Cetak biru dari sebuah objek disebut class, dan dari satu class bisa dibuat banyak objek yang berbeda. Konsep ini membuat program menjadi lebih mudah dimodelkan, dikembangkan secara tim, serta diperluas tanpa harus mengubah bagian yang sudah berjalan dengan baik.

OOP juga memperkenalkan konsep pewarisan, di mana sebuah class bisa mewarisi sifat dan kemampuan dari class lain sehingga tidak perlu menulis ulang logika yang sama. Selain itu, dalam pemrograman tingkat lanjut, penanganan error menjadi hal yang sangat krusial — program yang baik bukan hanya yang berjalan benar saat kondisi normal, tetapi juga yang mampu menangani situasi tak terduga dengan anggun tanpa langsung berhenti bekerja. Dengan menguasai OOP dan penanganan error, seorang programmer sudah siap membangun sistem perangkat lunak yang nyata, berskala besar, dan dapat diandalkan.$$,
  key_points = '[
    "OOP mengorganisir program melalui objek yang memiliki atribut dan metode, membuat kode lebih terstruktur dan mudah dikembangkan.",
    "Class adalah cetak biru dari objek — satu class bisa menghasilkan banyak objek dengan karakteristiknya masing-masing.",
    "Pewarisan memungkinkan sebuah class mengambil sifat dari class lain, sehingga menghindari penulisan kode yang berulang.",
    "Penanganan error adalah kemampuan program untuk tetap berjalan dengan baik meskipun menghadapi situasi yang tidak terduga."
  ]'::jsonb,
  sort_order = 4,
  is_published = true
WHERE course_id = 1 AND sort_order = 4;


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
WHERE course_id = 1
ORDER BY sort_order;

-- Harusnya urutan:
-- 1 | Pengenalan Pemrograman
-- 2 | Dasar-Dasar Kode Program
-- 3 | Struktur Program yang Lebih Terorganisir
-- 4 | Pemrograman Berorientasi Objek & Logika Lanjutan
