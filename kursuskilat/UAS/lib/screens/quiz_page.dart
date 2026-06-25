import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/models/level_data.dart';
import 'package:kursuskilat/providers/app_data_provider.dart';
import 'package:kursuskilat/services/progress_service.dart';
import 'app_theme.dart';
import 'game_page.dart';

// ── WARNA AKSEN (tidak berubah antar mode) ────────────────────────────────────
const kBlue = Color(0xFF4E9DFF);
const kIris = Color(0xFF7B9FFF);
const _kWrong = Color(0xFFFF5C7A);

// ── QUESTION MODEL ────────────────────────────────────────────────────────────
class QuizQuestion {
  final String category;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const QuizQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });
}

// ── QUESTION BANK ─────────────────────────────────────────────────────────────
const List<QuizQuestion> questionBank = [
  // ── moduleIndex 0: Dasar Komputer ──
  QuizQuestion(
    category: 'Dasar Komputer',
    question:
        'Bagian komputer yang bertugas memproses instruksi utama adalah...',
    options: ['RAM', 'CPU', 'SSD', 'Monitor', 'GPU'],
    answerIndex: 1,
    explanation:
        'CPU (Central Processing Unit) adalah otak komputer yang menjalankan semua instruksi program.',
  ),
  QuizQuestion(
    category: 'Dasar Komputer',
    question:
        'Komponen yang berfungsi sebagai memori jangka pendek (sementara) saat program berjalan adalah...',
    options: ['Hard Disk', 'CPU', 'RAM', 'ROM', 'GPU'],
    answerIndex: 2,
    explanation:
        'RAM (Random Access Memory) menyimpan data sementara yang dibutuhkan program yang sedang aktif.',
  ),
  QuizQuestion(
    category: 'Dasar Komputer',
    question:
        'Satuan kecepatan prosesor yang paling umum digunakan saat ini adalah...',
    options: ['MHz', 'GHz', 'KB/s', 'MB/s', 'Watt'],
    answerIndex: 1,
    explanation:
        'GHz (Gigahertz) adalah satuan frekuensi yang menunjukkan berapa miliar siklus per detik yang dapat dilakukan prosesor.',
  ),
  QuizQuestion(
    category: 'Dasar Komputer',
    question:
        'Perangkat output yang menampilkan hasil kerja komputer secara visual adalah...',
    options: ['Keyboard', 'Mouse', 'Printer', 'Monitor', 'Scanner'],
    answerIndex: 3,
    explanation:
        'Monitor adalah perangkat output utama yang menampilkan informasi visual dari komputer.',
  ),
  QuizQuestion(
    category: 'Dasar Komputer',
    question:
        'Penyimpanan yang tetap menyimpan data meskipun komputer dimatikan disebut...',
    options: ['RAM', 'Cache', 'Register', 'ROM', 'Virtual Memory'],
    answerIndex: 3,
    explanation:
        'ROM (Read-Only Memory) dan storage seperti SSD/HDD menyimpan data secara permanen meski daya dimatikan.',
  ),
  QuizQuestion(
    category: 'Dasar Komputer',
    question: 'Perangkat yang berfungsi sebagai INPUT pada komputer adalah...',
    options: ['Monitor', 'Printer', 'Speaker', 'Scanner', 'Proyektor'],
    answerIndex: 3,
    explanation:
        'Scanner mengubah dokumen fisik menjadi data digital — ini adalah fungsi INPUT ke dalam komputer.',
  ),
  QuizQuestion(
    category: 'Dasar Komputer',
    question: '1 Gigabyte (GB) setara dengan berapa Megabyte (MB)?',
    options: ['100 MB', '512 MB', '1000 MB', '1024 MB', '2048 MB'],
    answerIndex: 3,
    explanation:
        'Dalam sistem biner, 1 GB = 1024 MB. Basis 2 digunakan karena komputer bekerja dengan sistem biner.',
  ),
  QuizQuestion(
    category: 'Dasar Komputer',
    question: 'GPU (Graphics Processing Unit) paling utama digunakan untuk...',
    options: [
      'Menyimpan file permanen',
      'Mengatur koneksi internet',
      'Memproses grafis dan komputasi paralel',
      'Membaca input dari keyboard',
      'Menyimpan instruksi BIOS',
    ],
    answerIndex: 2,
    explanation:
        'GPU dirancang untuk memproses grafis secara paralel dalam jumlah besar, dan kini juga digunakan untuk AI/ML.',
  ),

  // ── moduleIndex 1: Algoritma ──
  QuizQuestion(
    category: 'Algoritma',
    question: 'Dalam pemrograman, algoritma paling tepat diartikan sebagai...',
    options: [
      'Bahasa yang hanya dipakai komputer',
      'Urutan langkah logis untuk menyelesaikan masalah',
      'Tempat menyimpan file program',
      'Aplikasi untuk membuat desain',
      'Kumpulan hardware komputer',
    ],
    answerIndex: 1,
    explanation:
        'Algoritma adalah serangkaian langkah terstruktur dan logis yang dirancang untuk menyelesaikan suatu masalah.',
  ),
  QuizQuestion(
    category: 'Algoritma',
    question:
        'Struktur kontrol yang digunakan untuk mengulang blok kode selama kondisi tertentu terpenuhi disebut...',
    options: ['Kondisional', 'Fungsi', 'Perulangan (Loop)', 'Array', 'Rekursi'],
    answerIndex: 2,
    explanation:
        'Perulangan (loop) seperti for, while, atau do-while digunakan untuk mengeksekusi blok kode berulang kali.',
  ),
  QuizQuestion(
    category: 'Algoritma',
    question:
        'Metode pencarian yang memeriksa setiap elemen satu per satu dari awal hingga akhir disebut...',
    options: [
      'Binary Search',
      'Linear Search',
      'Hash Search',
      'Tree Search',
      'Jump Search',
    ],
    answerIndex: 1,
    explanation:
        'Linear Search memeriksa setiap elemen secara berurutan, cocok untuk data kecil yang tidak terurut.',
  ),
  QuizQuestion(
    category: 'Algoritma',
    question: 'Kompleksitas waktu O(n) artinya...',
    options: [
      'Waktu eksekusi selalu konstan',
      'Waktu eksekusi bertambah seiring jumlah data',
      'Waktu eksekusi berkurang seiring jumlah data',
      'Waktu eksekusi berbanding kuadrat dengan data',
      'Program tidak membutuhkan waktu sama sekali',
    ],
    answerIndex: 1,
    explanation:
        'O(n) berarti waktu eksekusi bertumbuh secara linear seiring bertambahnya jumlah input (n).',
  ),
  QuizQuestion(
    category: 'Algoritma',
    question:
        'Algoritma pengurutan yang bekerja dengan membandingkan dan menukar elemen berdekatan secara berulang disebut...',
    options: [
      'Merge Sort',
      'Quick Sort',
      'Bubble Sort',
      'Selection Sort',
      'Insertion Sort',
    ],
    answerIndex: 2,
    explanation:
        'Bubble Sort membandingkan dua elemen berdekatan dan menukarnya jika urutannya salah, hingga seluruh data terurut.',
  ),
  QuizQuestion(
    category: 'Algoritma',
    question: 'Binary Search hanya dapat digunakan pada data yang...',
    options: [
      'Jumlahnya genap',
      'Tersimpan di database',
      'Sudah terurut (sorted)',
      'Berupa bilangan bulat',
      'Lebih dari 100 elemen',
    ],
    answerIndex: 2,
    explanation:
        'Binary Search membagi data menjadi dua setiap langkah, sehingga hanya bisa bekerja pada data yang sudah terurut.',
  ),
  QuizQuestion(
    category: 'Algoritma',
    question: 'Kompleksitas O(log n) dimiliki oleh algoritma...',
    options: [
      'Bubble Sort',
      'Linear Search',
      'Binary Search',
      'Selection Sort',
      'Insertion Sort',
    ],
    answerIndex: 2,
    explanation:
        'Binary Search memiliki kompleksitas O(log n) karena setiap iterasi memotong setengah ruang pencarian.',
  ),
  QuizQuestion(
    category: 'Algoritma',
    question:
        'Struktur data yang mengikuti prinsip LIFO (Last In, First Out) disebut...',
    options: ['Queue', 'Stack', 'Linked List', 'Tree', 'Graph'],
    answerIndex: 1,
    explanation:
        'Stack bekerja seperti tumpukan piring — elemen yang terakhir dimasukkan adalah yang pertama dikeluarkan (LIFO).',
  ),

  // ── moduleIndex 2: Pemrograman ──
  QuizQuestion(
    category: 'Pemrograman',
    question: 'Apa fungsi variabel dalam program?',
    options: [
      'Menyimpan nilai yang bisa digunakan kembali',
      'Menghapus semua data otomatis',
      'Mengubah komputer menjadi server',
      'Menggambar tampilan aplikasi saja',
      'Mengatur koneksi internet',
    ],
    answerIndex: 0,
    explanation:
        'Variabel adalah wadah bernama untuk menyimpan data seperti angka, teks, atau status yang bisa dipakai berulang.',
  ),
  QuizQuestion(
    category: 'Pemrograman',
    question:
        'Konsep OOP yang memungkinkan kelas mewarisi properti dan metode dari kelas lain disebut...',
    options: [
      'Enkapsulasi',
      'Polimorfisme',
      'Abstraksi',
      'Inheritance',
      'Overloading',
    ],
    answerIndex: 3,
    explanation:
        'Inheritance memungkinkan sebuah class (anak) mewarisi atribut dan metode dari class lain (induk).',
  ),
  QuizQuestion(
    category: 'Pemrograman',
    question:
        'Blok kode yang dapat dipanggil berulang kali dengan nama tertentu disebut...',
    options: ['Variabel', 'Konstanta', 'Fungsi', 'Komentar', 'Tipe Data'],
    answerIndex: 2,
    explanation:
        'Fungsi adalah blok kode yang diberi nama dan dapat dipanggil kapan pun dibutuhkan untuk menghindari pengulangan kode.',
  ),
  QuizQuestion(
    category: 'Pemrograman',
    question:
        'Tipe data yang hanya memiliki dua nilai: true atau false disebut...',
    options: ['Integer', 'String', 'Float', 'Boolean', 'Char'],
    answerIndex: 3,
    explanation:
        'Boolean hanya memiliki dua nilai: true (benar) atau false (salah), sering digunakan dalam kondisi logika.',
  ),
  QuizQuestion(
    category: 'Pemrograman',
    question:
        'Proses mengubah kode sumber menjadi kode yang bisa dijalankan mesin disebut...',
    options: ['Debugging', 'Compiling', 'Refactoring', 'Testing', 'Deploying'],
    answerIndex: 1,
    explanation:
        'Compiling adalah proses penerjemahan kode sumber yang ditulis programmer menjadi kode mesin yang bisa dieksekusi.',
  ),
  QuizQuestion(
    category: 'Pemrograman',
    question:
        'Prinsip OOP yang menyembunyikan detail implementasi dari pengguna disebut...',
    options: [
      'Inheritance',
      'Polimorfisme',
      'Enkapsulasi',
      'Abstraksi',
      'Overriding',
    ],
    answerIndex: 2,
    explanation:
        'Enkapsulasi menyembunyikan data internal dan hanya membuka akses melalui metode publik yang didefinisikan.',
  ),
  QuizQuestion(
    category: 'Pemrograman',
    question: 'Bahasa pemrograman Python termasuk jenis...',
    options: [
      'Compiled language',
      'Machine language',
      'Assembly language',
      'Interpreted language',
      'Binary language',
    ],
    answerIndex: 3,
    explanation:
        'Python adalah interpreted language — kode dijalankan baris per baris oleh interpreter, bukan dikompilasi dulu.',
  ),
  QuizQuestion(
    category: 'Pemrograman',
    question:
        'Pernyataan kondisional yang menjalankan blok kode berbeda berdasarkan nilai suatu ekspresi disebut...',
    options: [
      'For loop',
      'While loop',
      'Switch/match statement',
      'Try-catch',
      'Return statement',
    ],
    answerIndex: 2,
    explanation:
        'Switch (atau match di bahasa modern) mengevaluasi ekspresi dan mengeksekusi blok kode yang sesuai dengan nilainya.',
  ),

  // ── moduleIndex 3: Jaringan Komputer ──
  QuizQuestion(
    category: 'Jaringan Komputer',
    question:
        'Perangkat yang umum dipakai untuk menghubungkan jaringan lokal ke internet adalah...',
    options: ['Switch', 'Hub', 'Router', 'Repeater', 'Bridge'],
    answerIndex: 2,
    explanation:
        'Router bertugas meneruskan paket data antar jaringan yang berbeda, termasuk dari jaringan lokal ke internet.',
  ),
  QuizQuestion(
    category: 'Jaringan Komputer',
    question: 'Protokol yang digunakan untuk mengirim email adalah...',
    options: ['HTTP', 'FTP', 'SMTP', 'SSH', 'DNS'],
    answerIndex: 2,
    explanation:
        'SMTP (Simple Mail Transfer Protocol) adalah protokol standar untuk pengiriman email antar server.',
  ),
  QuizQuestion(
    category: 'Jaringan Komputer',
    question:
        'Alamat unik yang mengidentifikasi setiap perangkat dalam jaringan disebut...',
    options: [
      'MAC Address',
      'IP Address',
      'Domain Name',
      'Port Number',
      'Subnet Mask',
    ],
    answerIndex: 1,
    explanation:
        'IP Address adalah alamat numerik unik yang diberikan ke setiap perangkat agar bisa berkomunikasi dalam jaringan.',
  ),
  QuizQuestion(
    category: 'Jaringan Komputer',
    question:
        'Model referensi jaringan yang terdiri dari 7 lapisan (layer) disebut...',
    options: [
      'TCP/IP Model',
      'OSI Model',
      'HTTP Model',
      'DNS Model',
      'FTP Model',
    ],
    answerIndex: 1,
    explanation:
        'OSI Model (Open Systems Interconnection) membagi komunikasi jaringan menjadi 7 lapisan dari fisik hingga aplikasi.',
  ),
  QuizQuestion(
    category: 'Jaringan Komputer',
    question:
        'Teknologi yang memungkinkan beberapa perangkat berbagi koneksi internet secara nirkabel disebut...',
    options: ['Bluetooth', 'Wi-Fi', 'NFC', 'Infrared', 'Ethernet'],
    answerIndex: 1,
    explanation:
        'Wi-Fi menggunakan gelombang radio untuk menghubungkan perangkat ke jaringan secara nirkabel.',
  ),
  QuizQuestion(
    category: 'Jaringan Komputer',
    question: 'DNS (Domain Name System) berfungsi untuk...',
    options: [
      'Mengenkripsi data yang dikirim',
      'Menerjemahkan nama domain ke IP address',
      'Menyimpan email di server',
      'Mengatur kecepatan koneksi',
      'Membagi jaringan menjadi subnet',
    ],
    answerIndex: 1,
    explanation:
        'DNS menerjemahkan nama domain yang mudah diingat (google.com) menjadi IP address yang digunakan komputer.',
  ),
  QuizQuestion(
    category: 'Jaringan Komputer',
    question: 'Layer OSI yang bertanggung jawab atas pengalamatan IP adalah...',
    options: [
      'Layer 1 Physical',
      'Layer 2 Data Link',
      'Layer 3 Network',
      'Layer 4 Transport',
      'Layer 7 Application',
    ],
    answerIndex: 2,
    explanation:
        'Layer 3 (Network) bertanggung jawab atas pengalamatan logis (IP address) dan routing paket data.',
  ),
  QuizQuestion(
    category: 'Jaringan Komputer',
    question:
        'Protokol yang menjamin pengiriman data secara andal dan berurutan disebut...',
    options: ['UDP', 'TCP', 'ICMP', 'ARP', 'DHCP'],
    answerIndex: 1,
    explanation:
        'TCP (Transmission Control Protocol) memastikan data terkirim secara lengkap, berurutan, dan tanpa error melalui mekanisme acknowledgment.',
  ),

  // ── moduleIndex 4: Keamanan Digital ──
  QuizQuestion(
    category: 'Keamanan Digital',
    question: 'Contoh kebiasaan yang paling aman untuk menjaga akun adalah...',
    options: [
      'Memakai password yang sama di semua aplikasi',
      'Membagikan kode OTP ke teman',
      'Menyimpan password di catatan HP',
      'Mengaktifkan autentikasi dua faktor',
      'Menggunakan nama sendiri sebagai password',
    ],
    answerIndex: 3,
    explanation:
        'Autentikasi dua faktor (2FA) menambah lapisan keamanan ekstra selain password biasa.',
  ),
  QuizQuestion(
    category: 'Keamanan Digital',
    question:
        'Serangan siber yang menipu pengguna agar memberikan informasi sensitif dengan berpura-pura jadi pihak terpercaya disebut...',
    options: ['Malware', 'Ransomware', 'Phishing', 'DDoS', 'Brute Force'],
    answerIndex: 2,
    explanation:
        'Phishing adalah penipuan digital di mana penyerang menyamar sebagai entitas terpercaya untuk mencuri data.',
  ),
  QuizQuestion(
    category: 'Keamanan Digital',
    question:
        'Perangkat lunak berbahaya yang mengenkripsi file korban dan meminta tebusan disebut...',
    options: ['Spyware', 'Adware', 'Ransomware', 'Trojan', 'Worm'],
    answerIndex: 2,
    explanation:
        'Ransomware mengenkripsi file di komputer korban dan meminta pembayaran tebusan untuk mendapatkan kunci dekripsi.',
  ),
  QuizQuestion(
    category: 'Keamanan Digital',
    question:
        'Proses mengubah data menjadi format tidak terbaca tanpa kunci khusus disebut...',
    options: ['Kompresi', 'Enkripsi', 'Dekripsi', 'Hashing', 'Encoding'],
    answerIndex: 1,
    explanation:
        'Enkripsi mengubah data asli menjadi ciphertext menggunakan algoritma dan kunci, sehingga tidak bisa dibaca tanpa dekripsi.',
  ),
  QuizQuestion(
    category: 'Keamanan Digital',
    question:
        'Jaringan privat virtual yang mengamankan koneksi internet pengguna disebut...',
    options: ['Firewall', 'Antivirus', 'VPN', 'Proxy', 'SSL'],
    answerIndex: 2,
    explanation:
        'VPN (Virtual Private Network) mengenkripsi lalu lintas internet dan menyembunyikan identitas pengguna di jaringan.',
  ),
  QuizQuestion(
    category: 'Keamanan Digital',
    question:
        'Malware yang diam-diam memantau aktivitas pengguna dan mencuri data tanpa sepengetahuan korban disebut...',
    options: ['Ransomware', 'Spyware', 'Adware', 'Bootkit', 'Keylogger'],
    answerIndex: 1,
    explanation:
        'Spyware adalah malware yang bekerja secara diam-diam untuk memantau aktivitas, mencuri password, dan data sensitif.',
  ),
  QuizQuestion(
    category: 'Keamanan Digital',
    question: 'Hashing berbeda dari enkripsi karena...',
    options: [
      'Hashing lebih lambat dari enkripsi',
      'Hashing membutuhkan kunci rahasia',
      'Hashing bersifat satu arah — tidak bisa dibalik',
      'Hashing hanya bisa dipakai di jaringan',
      'Hashing menghasilkan file yang lebih besar',
    ],
    answerIndex: 2,
    explanation:
        'Hashing bersifat one-way (satu arah) — tidak bisa di-decrypt. Digunakan untuk menyimpan password secara aman.',
  ),
  QuizQuestion(
    category: 'Keamanan Digital',
    question:
        'Serangan yang membanjiri server dengan permintaan palsu sehingga layanan tidak dapat diakses disebut...',
    options: [
      'Phishing',
      'Man-in-the-Middle',
      'SQL Injection',
      'DDoS',
      'Brute Force',
    ],
    answerIndex: 3,
    explanation:
        'DDoS (Distributed Denial of Service) menggunakan banyak perangkat untuk membanjiri server hingga tidak bisa melayani pengguna sah.',
  ),
];

// ── SOAL PER MODUL ────────────────────────────────────────────────────────────
const _moduleOffsets = [0, 8, 16, 24, 32];
const _moduleSize = 8;

QuizQuestion questionForLevelFallback(LevelData level, int index) {
  final offset = _moduleOffsets[level.moduleIndex % _moduleOffsets.length];
  final questionIndex = offset + (index % _moduleSize);
  return questionBank[questionIndex.clamp(0, questionBank.length - 1)];
}

// ── LEVEL QUIZ PAGE ───────────────────────────────────────────────────────────
class LevelQuizPage extends StatefulWidget {
  final LevelData level;
  const LevelQuizPage({super.key, required this.level});

  @override
  State<LevelQuizPage> createState() => _LevelQuizPageState();
}

class _LevelQuizPageState extends State<LevelQuizPage> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _checked = false;
  int _correctCount = 0;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final totalQuestions = widget.level.questions;
    final question = context.watch<AppDataProvider>().questionForLevel(
      widget.level,
      _currentIndex,
    );
    final progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(child: _QuizDotGrid(isDark: t.isDark)),
          if (!t.isDark)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      kIris.withValues(alpha: 0.05),
                      Colors.transparent,
                      AppTheme.green.withValues(alpha: 0.06),
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          SafeArea(
            child: Column(
              children: [
                _QuizTopBar(level: widget.level, question: question),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuizProgressCard(
                          level: widget.level,
                          question: question,
                          questionNumber: _currentIndex + 1,
                          totalQuestions: totalQuestions,
                          progress: progress,
                        ),
                        const SizedBox(height: 16),
                        _QuestionCard(question: question),
                        const SizedBox(height: 14),
                        for (var i = 0; i < question.options.length; i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AnswerOption(
                              index: i,
                              text: question.options[i],
                              selected: _selectedIndex == i,
                              checked: _checked,
                              correct: question.answerIndex == i,
                              onTap: () {
                                if (_checked) return;
                                setState(() => _selectedIndex = i);
                              },
                            ),
                          ),
                        if (_checked) ...[
                          const SizedBox(height: 4),
                          _AnswerFeedback(
                            correct: _selectedIndex == question.answerIndex,
                            explanation: question.explanation,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                _QuizBottomActions(
                  hasSelected: _selectedIndex != null,
                  checked: _checked,
                  isLastQuestion: _currentIndex == totalQuestions - 1,
                  onCheck: _checkAnswer,
                  onNext: _nextQuestion,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _checkAnswer() {
    if (_selectedIndex == null) return;
    setState(() => _checked = true);
  }

  void _nextQuestion() {
    if (!_checked) {
      _checkAnswer();
      return;
    }

    final question = context.read<AppDataProvider>().questionForLevel(
      widget.level,
      _currentIndex,
    );
    if (_selectedIndex == question.answerIndex) {
      _correctCount++;
    }

    if (_currentIndex == widget.level.questions - 1) {
      _finishQuiz();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _checked = false;
    });
  }

  Future<void> _finishQuiz() async {
    if (_submitting) return;
    _submitting = true;
    final t = context.read<AppTheme>();
    final appData = context.read<AppDataProvider>();

    if (_correctCount == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Skor 0 — minimal 1 jawaban benar untuk menyelesaikan level.',
              style: TextStyle(color: t.textPri, fontWeight: FontWeight.w700),
            ),
            backgroundColor: t.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppTheme.red.withValues(alpha: 0.4)),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          ),
        );
      Navigator.of(context).pop();
      return;
    }

    try {
      final result = await ProgressService.submitLevelResult(
        levelNumber: widget.level.id,
        correctCount: _correctCount,
      );
      await appData.refreshAfterQuiz();
      if (!mounted) return;
      final xpMsg = result != null && result.xpDelta > 0
          ? ' | +${result.xpDelta} XP'
          : result != null
              ? ' | ${result.totalXp} XP total'
              : '';
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Level selesai! $_correctCount/${widget.level.questions} benar$xpMsg',
              style: TextStyle(color: t.textPri, fontWeight: FontWeight.w700),
            ),
            backgroundColor: t.surface,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppTheme.green.withValues(alpha: 0.4)),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          ),
        );
      Navigator.of(context).pop();
      return;
    } catch (e) {
      if (mounted) {
        debugPrint('submit_level_result: $e');
      }
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Level selesai! $_correctCount/${widget.level.questions} benar (offline)',
            style: TextStyle(color: t.textPri, fontWeight: FontWeight.w700),
          ),
          backgroundColor: t.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: AppTheme.green.withValues(alpha: 0.4)),
          ),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        ),
      );
    Navigator.of(context).pop();
  }
}

// ── QUIZ TOP BAR ──────────────────────────────────────────────────────────────
class _QuizTopBar extends StatelessWidget {
  final LevelData level;
  final QuizQuestion question;

  const _QuizTopBar({required this.level, required this.question});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level ${level.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textPri,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  question.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: t.textMid,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── QUIZ PROGRESS CARD ────────────────────────────────────────────────────────
class _QuizProgressCard extends StatelessWidget {
  final LevelData level;
  final QuizQuestion question;
  final int questionNumber, totalQuestions;
  final double progress;

  const _QuizProgressCard({
    required this.level,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _InfoChip(
                icon: Icons.quiz_rounded,
                label: 'Soal $questionNumber/$totalQuestions',
                color: AppTheme.green,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: levelStatusIcon(level.status),
                label: levelStatusLabel(level.status),
                color: levelStatusColor(level.status, isDark: t.isDark),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: t.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: t.secondary.withValues(alpha: 0.2)),
                ),
                child: Text(
                  'Modul ${level.moduleIndex + 1}',
                  style: TextStyle(
                    color: t.secondary,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            level.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: t.textPri,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Topik: ${question.category}',
            style: TextStyle(
              color: t.textMid,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: t.surfaceB,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.green),
            ),
          ),
        ],
      ),
    );
  }
}

// ── QUESTION CARD ─────────────────────────────────────────────────────────────
class _QuestionCard extends StatelessWidget {
  final QuizQuestion question;
  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.green.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.green.withValues(alpha: t.isDark ? 0.08 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: t.isDark ? AppTheme.green : null,
              gradient: t.isDark
                  ? null
                  : const LinearGradient(
                      colors: [
                        AppTheme.greenDk,
                        AppTheme.green,
                        AppTheme.greenGl,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.psychology_rounded, color: t.bg, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: TextStyle(
              color: t.textPri,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ANSWER OPTION ─────────────────────────────────────────────────────────────
class _AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final bool selected, checked, correct;
  final VoidCallback onTap;

  const _AnswerOption({
    required this.index,
    required this.text,
    required this.selected,
    required this.checked,
    required this.correct,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final wrong = checked && selected && !correct;
    final color = checked && correct
        ? AppTheme.green
        : wrong
        ? _kWrong
        : selected
        ? (t.isDark ? t.secondary : kBlue)
        : t.divider;
    final label = String.fromCharCode(65 + index);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(
            alpha: selected || (checked && correct) ? 0.12 : 0.04,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: selected ? 1.6 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.7)),
              ),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color == t.divider ? t.textMid : color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: t.textPri,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            if (checked && correct)
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.green,
                size: 20,
              )
            else if (wrong)
              const Icon(Icons.cancel_rounded, color: _kWrong, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── ANSWER FEEDBACK ───────────────────────────────────────────────────────────
class _AnswerFeedback extends StatelessWidget {
  final bool correct;
  final String explanation;
  const _AnswerFeedback({required this.correct, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final color = correct ? AppTheme.green : _kWrong;
    final title = correct ? 'Jawaban benar' : 'Belum tepat';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            correct ? Icons.check_circle_rounded : Icons.info_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  explanation,
                  style: TextStyle(
                    color: t.textSec,
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── QUIZ BOTTOM ACTIONS ───────────────────────────────────────────────────────
class _QuizBottomActions extends StatelessWidget {
  final bool hasSelected, checked, isLastQuestion;
  final VoidCallback onCheck, onNext;

  const _QuizBottomActions({
    required this.hasSelected,
    required this.checked,
    required this.isLastQuestion,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border(top: BorderSide(color: t.divider, width: 1)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasSelected ? (checked ? onNext : onCheck) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.green,
              disabledBackgroundColor: t.surfaceB,
              foregroundColor: t.bg,
              disabledForegroundColor: t.textMid,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              checked ? (isLastQuestion ? 'Selesai' : 'Lanjut') : 'Cek Jawaban',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ),
    );
  }
}

// ── SHARED SMALL WIDGETS ──────────────────────────────────────────────────────
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: t.divider),
        ),
        child: Icon(icon, color: t.textSec, size: 21),
      ),
    );
  }
}

// ── DOT GRID ──────────────────────────────────────────────────────────────────
class _QuizDotGrid extends StatelessWidget {
  final bool isDark;
  const _QuizDotGrid({required this.isDark});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _QuizDotGridPainter(isDark: isDark));
}

class _QuizDotGridPainter extends CustomPainter {
  final bool isDark;
  const _QuizDotGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const spacing = 30.0;
    const radius = 1.0;
    final dotColor = isDark ? const Color(0xFF1E1E30) : const Color(0xFFD0D4E8);

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final fx = (x / size.width - 0.5).abs() * 2;
        final fy = (y / size.height - 0.5).abs() * 2;
        final fade = math.max(fx, fy);
        final op = (1.0 - fade * 1.2).clamp(0.0, 1.0);
        if (op < 0.05) continue;
        paint.color = dotColor.withValues(alpha: op);
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QuizDotGridPainter old) => old.isDark != isDark;
}
