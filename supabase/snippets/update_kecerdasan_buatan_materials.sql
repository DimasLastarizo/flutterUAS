-- ═══════════════════════════════════════════════════════════════════════════
-- KursusKilat — Update konten materi: Kecerdasan Buatan (course_id = 5)
-- Jalankan di Supabase Cloud → SQL Editor
-- Video intro: belum diisi (intro_video_url tetap kosong)
-- ═══════════════════════════════════════════════════════════════════════════

-- ─── 0. CEK DATA SEBELUM UPDATE ───────────────────────────────────────────
SELECT id, course_id, sort_order, title
FROM materials
WHERE course_id = 5
ORDER BY sort_order ASC;

SELECT id, title, description, intro_video_url
FROM courses
WHERE id = 5;


-- ─── 1. UPDATE DESKRIPSI MATA PELAJARAN ───────────────────────────────────
UPDATE courses
SET
  description = 'Pelajari AI: machine learning, deep learning, artificial neural network, NLP, Large Language Model, dan AI Agent modern.',
  modules_total = 4
WHERE id = 5;


-- ─── 2. MATERI 1 — Fundamental AI (sort_order = 1) ────────────────────────
UPDATE materials
SET
  title = 'Fundamental AI',
  emoji = '🤖',
  duration_label = 'Ringkas',
  content = $$Kecerdasan buatan atau Artificial Intelligence adalah cabang ilmu komputer yang berfokus pada pengembangan sistem yang mampu melakukan tugas-tugas yang biasanya membutuhkan kecerdasan manusia, seperti memahami bahasa, mengenali gambar, mengambil keputusan, dan memecahkan masalah. Ide dasar AI sebenarnya sudah muncul sejak tahun 1950-an ketika ilmuwan Alan Turing mengajukan pertanyaan filosofis tentang apakah mesin bisa berpikir, yang kemudian melahirkan fondasi teoritis bagi seluruh perkembangan AI hingga saat ini. Selama beberapa dekade, AI mengalami pasang surut dalam hal minat dan pendanaan, namun meledak secara masif di era modern berkat tersedianya data dalam jumlah sangat besar dan peningkatan kemampuan komputasi yang luar biasa. Kini AI bukan lagi sekadar konsep ilmiah, melainkan teknologi nyata yang sudah tertanam dalam kehidupan sehari-hari manusia mulai dari rekomendasi konten hingga asisten virtual.

AI sendiri terbagi menjadi beberapa pendekatan besar yang berkembang seiring waktu. Pendekatan awal AI mengandalkan aturan-aturan logis yang dibuat secara manual oleh manusia, di mana sistem hanya bisa melakukan apa yang secara eksplisit diperintahkan. Kemudian muncul machine learning, sebuah pendekatan revolusioner di mana sistem tidak lagi diprogram secara manual melainkan belajar sendiri dari data yang diberikan untuk menemukan pola dan membuat prediksi. Lebih jauh lagi, deep learning hadir sebagai cabang dari machine learning yang terinspirasi dari cara kerja otak manusia, mampu memproses data yang sangat kompleks seperti gambar, suara, dan teks dengan tingkat akurasi yang melampaui kemampuan manusia dalam banyak bidang tertentu.$$,
  key_points = '[
    "Kecerdasan buatan adalah cabang ilmu komputer yang mengembangkan sistem mampu melakukan tugas yang biasanya membutuhkan kecerdasan manusia.",
    "Fondasi teoritis AI diletakkan oleh Alan Turing sejak tahun 1950-an dan berkembang pesat berkat ketersediaan data besar dan komputasi modern.",
    "Machine learning memungkinkan sistem belajar dari data secara mandiri tanpa harus diprogram secara eksplisit untuk setiap situasi.",
    "Deep learning adalah evolusi dari machine learning yang terinspirasi cara kerja otak dan mampu memproses data kompleks dengan akurasi tinggi."
  ]'::jsonb,
  sort_order = 1,
  is_published = true
WHERE course_id = 5 AND sort_order = 1;


-- ─── 3. MATERI 2 — Artificial Neural Network (ANN) ────────────────────────
UPDATE materials
SET
  title = 'Artificial Neural Network (ANN)',
  emoji = '🧠',
  duration_label = 'Teori',
  content = $$Artificial Neural Network atau ANN adalah model komputasi yang terinspirasi dari struktur dan cara kerja jaringan saraf biologis di otak manusia. Otak manusia terdiri dari miliaran neuron yang saling terhubung dan berkomunikasi melalui sinyal listrik, dan ANN meniru konsep ini dengan menciptakan jaringan dari unit-unit komputasi buatan yang disebut neuron artifisial. Setiap neuron menerima masukan, memprosesnya dengan memberikan bobot tertentu pada setiap masukan, lalu menghasilkan keluaran yang diteruskan ke neuron berikutnya. Dengan cara inilah ANN mampu mempelajari pola yang sangat kompleks dari data, sesuatu yang tidak bisa dilakukan oleh algoritma pemrograman konvensional yang berbasis aturan.

Sebuah ANN umumnya terdiri dari tiga jenis lapisan utama: lapisan masukan yang menerima data mentah, lapisan tersembunyi yang melakukan pemrosesan dan ekstraksi fitur secara bertahap, serta lapisan keluaran yang menghasilkan prediksi atau keputusan akhir. Proses belajar dalam ANN terjadi melalui mekanisme yang disebut backpropagation, di mana jaringan secara berulang membandingkan hasil prediksinya dengan jawaban yang benar, lalu menyesuaikan bobot setiap koneksi antar neuron agar prediksi berikutnya menjadi lebih akurat. Semakin banyak lapisan tersembunyi yang dimiliki sebuah jaringan, semakin dalam kemampuannya dalam memahami pola yang kompleks — inilah yang menjadi asal usul istilah "deep learning" yang merujuk pada ANN dengan banyak lapisan tersembunyi.$$,
  key_points = '[
    "ANN adalah model komputasi yang meniru struktur jaringan saraf biologis otak manusia untuk memproses dan mempelajari pola dari data.",
    "Setiap neuron artifisial menerima masukan, memberikan bobot pada setiap masukan, lalu meneruskan hasilnya ke neuron berikutnya dalam jaringan.",
    "ANN terdiri dari lapisan masukan, lapisan tersembunyi, dan lapisan keluaran yang masing-masing memiliki peran spesifik dalam proses pembelajaran.",
    "Backpropagation adalah mekanisme utama pembelajaran ANN, di mana bobot koneksi disesuaikan secara terus-menerus agar prediksi semakin akurat."
  ]'::jsonb,
  sort_order = 2,
  is_published = true
WHERE course_id = 5 AND sort_order = 2;


-- ─── 4. MATERI 3 — Natural Language Processing (NLP) ────────────────────
UPDATE materials
SET
  title = 'Natural Language Processing (NLP)',
  emoji = '💬',
  duration_label = 'Analisis',
  content = $$Natural Language Processing atau NLP adalah cabang kecerdasan buatan yang berfokus pada kemampuan komputer untuk memahami, menginterpretasikan, dan menghasilkan bahasa manusia secara alami. Bahasa manusia adalah salah satu hal paling kompleks yang harus dipahami oleh mesin, karena mengandung konteks, ambiguitas, sarkasme, idiom, dan nuansa budaya yang tidak bisa ditangkap hanya dengan mencocokkan kata per kata. Selama bertahun-tahun, pendekatan NLP bergantung pada aturan linguistik yang dibuat secara manual, namun pendekatan ini memiliki keterbatasan besar karena bahasa manusia terlalu dinamis dan terus berkembang. Revolusi besar terjadi ketika NLP mulai mengadopsi pendekatan berbasis machine learning dan deep learning, yang memungkinkan sistem belajar memahami bahasa langsung dari miliaran contoh teks nyata.

Aplikasi NLP kini sudah sangat luas dan menyentuh hampir setiap aspek kehidupan digital. Mesin pencari menggunakan NLP untuk memahami maksud di balik kata kunci yang diketik pengguna, bukan sekadar mencocokkan kata. Sistem terjemahan otomatis seperti Google Translate menggunakan NLP untuk mengalihbahasakan teks dengan mempertimbangkan konteks kalimat secara keseluruhan. Analisis sentimen menggunakan NLP untuk mendeteksi apakah sebuah ulasan produk atau postingan media sosial mengandung nada positif, negatif, atau netral. Puncak perkembangan NLP saat ini diwujudkan oleh Large Language Model seperti GPT dan Claude, yang mampu memahami dan menghasilkan teks dengan kualitas yang sangat mendekati kemampuan manusia sesungguhnya.$$,
  key_points = '[
    "NLP adalah cabang AI yang memungkinkan komputer memahami, menginterpretasikan, dan menghasilkan bahasa manusia secara alami.",
    "Bahasa manusia sangat kompleks karena mengandung konteks, ambiguitas, dan nuansa yang tidak bisa ditangkap dengan pencocokan kata sederhana.",
    "Adopsi deep learning dalam NLP merevolusi kemampuan sistem dalam memahami bahasa langsung dari data teks nyata berskala besar.",
    "Large Language Model adalah puncak perkembangan NLP saat ini yang mampu memahami dan menghasilkan teks dengan kualitas mendekati kemampuan manusia."
  ]'::jsonb,
  sort_order = 3,
  is_published = true
WHERE course_id = 5 AND sort_order = 3;


-- ─── 5. MATERI 4 — AI Agent ───────────────────────────────────────────────
UPDATE materials
SET
  title = 'AI Agent',
  emoji = '🎯',
  duration_label = 'Lanjutan',
  content = $$AI Agent adalah sistem kecerdasan buatan yang tidak hanya mampu menjawab pertanyaan atau menghasilkan output, tetapi juga mampu bertindak secara mandiri untuk mencapai tujuan tertentu dengan merencanakan langkah-langkah, menggunakan berbagai alat, dan beradaptasi terhadap situasi yang berubah. Berbeda dengan AI konvensional yang bersifat pasif dan hanya merespons ketika diminta, AI Agent beroperasi secara proaktif — ia bisa memecah sebuah tujuan besar menjadi tugas-tugas kecil, mengeksekusinya satu per satu, mengevaluasi hasilnya, lalu menyesuaikan rencana berikutnya berdasarkan apa yang telah dipelajari. Konsep ini menandai pergeseran besar dalam cara manusia berinteraksi dengan AI, dari sekadar alat yang menjawab menjadi mitra yang bekerja secara aktif.

Sebuah AI Agent umumnya dibangun di atas fondasi model bahasa yang kuat, namun diperlengkapi dengan kemampuan tambahan seperti akses ke internet, kemampuan menjalankan kode program, membaca dan menulis file, hingga berkomunikasi dengan layanan eksternal. Dalam skenario yang lebih kompleks, beberapa AI Agent bisa bekerja sama dalam sebuah sistem multi-agent, di mana setiap agent memiliki spesialisasi berbeda dan saling berkoordinasi untuk menyelesaikan tugas yang terlalu besar untuk ditangani oleh satu agent saja. Perkembangan AI Agent membuka cakrawala baru yang sangat luas, mulai dari asisten pribadi yang benar-benar otonom, sistem riset ilmiah otomatis, hingga agen bisnis yang mampu mengelola proses kerja yang kompleks tanpa campur tangan manusia secara terus-menerus.$$,
  key_points = '[
    "AI Agent adalah sistem AI yang mampu bertindak secara mandiri dan proaktif untuk mencapai tujuan, bukan sekadar merespons pertanyaan.",
    "AI Agent memecah tujuan besar menjadi tugas-tugas kecil, mengeksekusinya, lalu beradaptasi berdasarkan hasil yang diperoleh secara dinamis.",
    "AI Agent dilengkapi kemampuan tambahan seperti akses internet, eksekusi kode, dan integrasi dengan layanan eksternal untuk memperluas kapabilitasnya.",
    "Sistem multi-agent memungkinkan beberapa AI Agent berkolaborasi dengan spesialisasi berbeda untuk menyelesaikan tugas yang sangat kompleks."
  ]'::jsonb,
  sort_order = 4,
  is_published = true
WHERE course_id = 5 AND sort_order = 4;


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
WHERE course_id = 5
ORDER BY sort_order ASC;

-- Harusnya urutan:
-- 1 | Fundamental AI
-- 2 | Artificial Neural Network (ANN)
-- 3 | Natural Language Processing (NLP)
-- 4 | AI Agent
