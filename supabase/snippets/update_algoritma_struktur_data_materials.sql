-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Update konten materi: Algoritma & Struktur Data (course_id = 2)
-- Jalankan di Supabase Cloud → SQL Editor
-- Video intro: belum diisi (intro_video_url tetap kosong)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK DATA SEBELUM UPDATE ───────────────────────────────────────────
SELECT id, course_id, sort_order, title
FROM materials
WHERE course_id = 2
ORDER BY sort_order ASC;

SELECT id, title, description, intro_video_url
FROM courses
WHERE id = 2;


-- ─── 1. UPDATE DESKRIPSI MATA PELAJARAN ───────────────────────────────────
UPDATE courses
SET
  description = 'Pelajari algoritma: flowchart, analisis kompleksitas Big O, array, linked list, stack, queue, pencarian, pengurutan, tree, dan graph.',
  modules_total = 4
WHERE id = 2;


-- ─── 2. MATERI 1 — Pengenalan Algoritma (sort_order = 1) ──────────────────
UPDATE materials
SET
  title = 'Pengenalan Algoritma',
  emoji = '🧮',
  duration_label = 'Ringkas',
  content = $$Algoritma adalah serangkaian langkah-langkah logis dan terurut yang dirancang untuk menyelesaikan suatu masalah tertentu. Dalam kehidupan sehari-hari, algoritma sebenarnya sudah sering kita gunakan tanpa kita sadari — misalnya langkah-langkah memasak dari sebuah resep, atau instruksi perakitan furnitur, keduanya pada dasarnya adalah algoritma. Dalam dunia komputer, algoritma menjadi inti dari setiap program yang berjalan karena komputer tidak bisa menebak apa yang harus dilakukan — ia hanya bisa mengikuti instruksi yang telah dirancang dengan tepat dan jelas. Semakin baik sebuah algoritma dirancang, semakin efisien pula sebuah program dalam menyelesaikan tugasnya.

Sebuah algoritma yang baik harus memenuhi beberapa kriteria penting. Pertama, algoritma harus memiliki titik awal dan titik akhir yang jelas sehingga tidak berjalan tanpa henti. Kedua, setiap langkahnya harus terdefinisi dengan tepat tanpa ada ambiguitas, karena komputer tidak bisa menginterpretasikan instruksi yang samar. Ketiga, algoritma harus menghasilkan keluaran yang benar dan konsisten untuk setiap masukan yang diberikan. Untuk menggambarkan algoritma secara visual sebelum diimplementasikan ke dalam kode, sering digunakan flowchart atau pseudocode sebagai alat bantu yang memudahkan perancangan dan komunikasi antar programmer.$$,
  key_points = '[
    "Algoritma adalah langkah-langkah logis dan terurut yang dirancang untuk menyelesaikan suatu masalah secara sistematis.",
    "Komputer sepenuhnya bergantung pada algoritma karena ia hanya bisa menjalankan instruksi yang telah didefinisikan secara jelas.",
    "Algoritma yang baik harus memiliki titik awal dan akhir yang jelas, setiap langkah terdefinisi, serta menghasilkan keluaran yang konsisten.",
    "Flowchart dan pseudocode adalah alat bantu untuk merancang dan mengkomunikasikan algoritma sebelum ditulis dalam bentuk kode."
  ]'::jsonb,
  sort_order = 1,
  is_published = true
WHERE course_id = 2 AND sort_order = 1;


-- ─── 3. MATERI 2 — Kompleksitas dan Analisis Algoritma ────────────────────
UPDATE materials
SET
  title = 'Kompleksitas dan Analisis Algoritma',
  emoji = '📈',
  duration_label = 'Teori',
  content = $$Ketika sebuah masalah bisa diselesaikan dengan lebih dari satu algoritma, pertanyaan selanjutnya adalah algoritma mana yang paling efisien. Di sinilah analisis algoritma berperan — yaitu proses mengukur seberapa banyak sumber daya, baik waktu maupun memori, yang dibutuhkan oleh sebuah algoritma untuk menyelesaikan tugasnya. Efisiensi waktu diukur berdasarkan berapa banyak operasi yang dilakukan seiring bertambahnya jumlah data masukan, sementara efisiensi memori diukur dari seberapa besar ruang penyimpanan yang digunakan. Kemampuan menganalisis efisiensi algoritma adalah hal yang sangat penting karena sebuah algoritma yang lambat bisa menjadi bencana ketika diterapkan pada data berskala besar.

Untuk mengekspresikan efisiensi sebuah algoritma secara matematis, digunakan notasi yang disebut Big O Notation. Notasi ini menggambarkan bagaimana performa sebuah algoritma berubah seiring bertambahnya jumlah data, misalnya algoritma dengan notasi O(n) berarti waktu prosesnya bertambah secara linear seiring data bertambah, sementara O(n²) berarti waktu prosesnya bertambah jauh lebih cepat dan bisa menjadi sangat lambat untuk data berukuran besar. Memahami Big O Notation membantu programmer untuk membandingkan algoritma secara objektif dan memilih pendekatan yang paling tepat untuk situasi tertentu. Ini adalah salah satu konsep yang paling sering diujikan dalam wawancara kerja di perusahaan teknologi besar.$$,
  key_points = '[
    "Analisis algoritma mengukur efisiensi sebuah algoritma berdasarkan kebutuhan waktu dan memori yang digunakannya.",
    "Algoritma yang tidak efisien bisa bekerja baik pada data kecil tetapi menjadi sangat lambat ketika diterapkan pada data berskala besar.",
    "Big O Notation adalah cara matematis untuk mengekspresikan bagaimana performa algoritma berubah seiring bertambahnya jumlah data.",
    "Pemilihan algoritma yang tepat berdasarkan analisis kompleksitasnya adalah keterampilan krusial dalam pengembangan sistem yang efisien."
  ]'::jsonb,
  sort_order = 2,
  is_published = true
WHERE course_id = 2 AND sort_order = 2;


-- ─── 4. MATERI 3 — Struktur Data Dasar ───────────────────────────────────
UPDATE materials
SET
  title = 'Struktur Data Dasar',
  emoji = '🧩',
  duration_label = 'Analisis',
  content = $$Struktur data adalah cara mengorganisir dan menyimpan data dalam memori komputer agar bisa diakses dan diproses secara efisien sesuai kebutuhan. Pemilihan struktur data yang tepat sama pentingnya dengan pemilihan algoritma yang tepat, karena keduanya saling bergantung dan bersama-sama menentukan performa keseluruhan sebuah program. Struktur data paling dasar adalah array, yaitu kumpulan elemen yang disimpan secara berurutan dalam memori dan diakses menggunakan indeks. Selain array, terdapat linked list yang menyimpan data dalam bentuk rantai simpul yang saling terhubung, memberikan fleksibilitas lebih dalam penambahan dan penghapusan data dibandingkan array yang ukurannya cenderung tetap.

Dua struktur data dasar lain yang sangat penting adalah stack dan queue. Stack bekerja dengan prinsip "yang terakhir masuk adalah yang pertama keluar," seperti tumpukan piring di mana piring yang paling baru diletakkan di atas adalah yang pertama diambil. Sebaliknya, queue bekerja dengan prinsip "yang pertama masuk adalah yang pertama keluar," seperti antrian kasir di mana orang yang lebih dulu datang akan lebih dulu dilayani. Kedua struktur data ini terdengar sederhana, namun penerapannya sangat luas dalam dunia nyata, mulai dari manajemen memori di sistem operasi hingga antrian permintaan di server web yang melayani jutaan pengguna sekaligus.$$,
  key_points = '[
    "Struktur data adalah cara mengorganisir data dalam memori agar bisa diakses dan diproses secara efisien sesuai kebutuhan.",
    "Array menyimpan data secara berurutan dan diakses via indeks, sementara linked list menyimpan data dalam rantai simpul yang lebih fleksibel.",
    "Stack menerapkan prinsip \"terakhir masuk pertama keluar\" dan sering digunakan dalam manajemen memori dan navigasi halaman.",
    "Queue menerapkan prinsip \"pertama masuk pertama keluar\" dan banyak digunakan dalam sistem antrian dan pemrosesan permintaan server."
  ]'::jsonb,
  sort_order = 3,
  is_published = true
WHERE course_id = 2 AND sort_order = 3;


-- ─── 5. MATERI 4 — Algoritma Pencarian, Pengurutan, dan Struktur Data Lanjutan
UPDATE materials
SET
  title = 'Algoritma Pencarian, Pengurutan, dan Struktur Data Lanjutan',
  emoji = '🎯',
  duration_label = 'Lanjutan',
  content = $$Dua kategori algoritma yang paling sering digunakan dalam pemrograman sehari-hari adalah algoritma pencarian dan pengurutan. Algoritma pencarian digunakan untuk menemukan data tertentu dari sekumpulan data, dengan dua pendekatan paling umum yaitu pencarian linear yang memeriksa setiap elemen satu per satu, dan pencarian biner yang jauh lebih cepat namun mensyaratkan data sudah dalam kondisi terurut. Sementara itu, algoritma pengurutan digunakan untuk menyusun data dalam urutan tertentu, dengan berbagai pendekatan yang berbeda-beda seperti bubble sort yang mudah dipahami namun lambat, hingga merge sort dan quick sort yang jauh lebih efisien untuk data berskala besar.

Selain struktur data dasar, terdapat struktur data lanjutan yang dirancang untuk kasus penggunaan yang lebih spesifik dan kompleks. Tree atau pohon adalah struktur data hierarkis yang merepresentasikan hubungan bertingkat, dan salah satu variannya yang paling terkenal adalah binary search tree yang memungkinkan pencarian data dengan sangat efisien. Graph adalah struktur data yang merepresentasikan hubungan antar entitas secara bebas tanpa hierarki yang kaku, dan digunakan dalam berbagai aplikasi nyata seperti peta navigasi, jaringan sosial, hingga algoritma rekomendasi. Menguasai struktur data lanjutan ini adalah tanda bahwa seorang programmer telah siap untuk memecahkan masalah-masalah yang benar-benar kompleks di dunia nyata.$$,
  key_points = '[
    "Algoritma pencarian linear memeriksa data satu per satu, sementara pencarian biner jauh lebih cepat dengan syarat data sudah terurut.",
    "Algoritma pengurutan seperti merge sort dan quick sort jauh lebih efisien dibandingkan bubble sort untuk menangani data berskala besar.",
    "Tree adalah struktur data hierarkis yang memungkinkan pencarian dan pengelolaan data secara sangat efisien melalui hubungan bertingkat.",
    "Graph merepresentasikan hubungan bebas antar entitas dan menjadi fondasi dari berbagai aplikasi seperti navigasi, media sosial, dan sistem rekomendasi."
  ]'::jsonb,
  sort_order = 4,
  is_published = true
WHERE course_id = 2 AND sort_order = 4;


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
WHERE course_id = 2
ORDER BY sort_order ASC;

-- Harusnya urutan:
-- 1 | Pengenalan Algoritma
-- 2 | Kompleksitas dan Analisis Algoritma
-- 3 | Struktur Data Dasar
-- 4 | Algoritma Pencarian, Pengurutan, dan Struktur Data Lanjutan
