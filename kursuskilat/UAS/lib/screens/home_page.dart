import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kursus_page.dart' as kursus;
import 'profil_page.dart' as profil;
import 'pencapaian_page.dart' as pencapaian;
import 'package:kursuskilat/screens/ai_assistant_overlay.dart';

// Color tokens
const _bg = Color(0xFF080810);
const _surface = Color(0xFF13131F);
const _surfaceB = Color(0xFF1C1C2E);
const _green = Color(0xFF2ECC71);
const _greenDk = Color(0xFF1AA355);
const _greenGl = Color(0xFF5DEBA0);
const _blue = Color(0xFF4E9DFF);
const _divider = Color(0xFF1E1E30);
const _textPri = Color(0xFFF0F0FA);
const _textSec = Color(0xFF9999BB);
const _textMid = Color(0xFF666888);
const _iris = Color(0xFF7B9FFF);
const _purple = Color(0xFF8D5CFF);

// Root shell
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;

  void goToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _pages = const [
    HomePage(),
    MyCoursesPage(),
    PencapaianPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF13131F),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AiAssistantWrapper(
      child: Scaffold(
        backgroundColor: _bg,
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

// Bottom navigation
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _surface,
        border: Border(top: BorderSide(color: _divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                index: 0,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: 'Materi',
                index: 1,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.leaderboard_rounded,
                label: 'Leaderboard',
                index: 2,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profil',
                index: 3,
                current: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: active ? _green.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 22, color: active ? _green : _textMid),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? _green : _textMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home page
enum _LevelStatus { selesai, aktif, terkunci }

class _LevelData {
  final int level;
  final String title;
  final String topic;
  final _LevelStatus status;
  final int questions;
  final int stars;

  const _LevelData({
    required this.level,
    required this.title,
    required this.topic,
    required this.status,
    required this.questions,
    required this.stars,
  });
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const List<_LevelData> _levels = [
    _LevelData(
      level: 1,
      title: 'Pemanasan',
      topic: 'Dasar belajar',
      status: _LevelStatus.selesai,
      questions: 5,
      stars: 3,
    ),
    _LevelData(
      level: 2,
      title: 'Konsep Inti',
      topic: 'Materi ringkas',
      status: _LevelStatus.selesai,
      questions: 6,
      stars: 3,
    ),
    _LevelData(
      level: 3,
      title: 'Latihan Cepat',
      topic: 'Review konsep',
      status: _LevelStatus.selesai,
      questions: 7,
      stars: 2,
    ),
    _LevelData(
      level: 4,
      title: 'Misi Aktif',
      topic: 'Pilihan ganda',
      status: _LevelStatus.aktif,
      questions: 8,
      stars: 0,
    ),
    _LevelData(
      level: 5,
      title: 'Tantangan Baru',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 8,
      stars: 0,
    ),
    _LevelData(
      level: 6,
      title: 'Combo Soal',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 9,
      stars: 0,
    ),
    _LevelData(
      level: 7,
      title: 'Mode Fokus',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 9,
      stars: 0,
    ),
    _LevelData(
      level: 8,
      title: 'Boss Quiz',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 10,
      stars: 0,
    ),
    _LevelData(
      level: 9,
      title: 'Speed Run',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 10,
      stars: 0,
    ),
    _LevelData(
      level: 10,
      title: 'Final Stage',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 12,
      stars: 0,
    ),
    _LevelData(
      level: 11,
      title: 'Bonus Map',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 12,
      stars: 0,
    ),
    _LevelData(
      level: 12,
      title: 'Master Quiz',
      topic: 'Kunci berikutnya',
      status: _LevelStatus.terkunci,
      questions: 15,
      stars: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final activeLevel = _levels.firstWhere(
      (level) => level.status == _LevelStatus.aktif,
      orElse: () => _levels.first,
    );

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _GridDots()),
          const Positioned.fill(child: _MapBackdrop()),
          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _HomeHeader(activeLevel: activeLevel),
                ),
                const SliverToBoxAdapter(child: _LevelLegend()),
                SliverToBoxAdapter(
                  child: _LevelMap(
                    levels: _levels,
                    onLevelTap: (level) => _openLevel(context, level),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openLevel(BuildContext context, _LevelData data) {
    final rootState = context.findAncestorStateOfType<_RootShellState>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _LevelQuizPage(
          level: data,
          onOpenMaterialTab: () {
            rootState?.goToTab(1);
          },
        ),
      ),
    );
  }
}

class _QuizQuestion {
  final String category;
  final String question;
  final List<String> options;
  final int answerIndex;
  final String explanation;

  const _QuizQuestion({
    required this.category,
    required this.question,
    required this.options,
    required this.answerIndex,
    required this.explanation,
  });
}

const List<_QuizQuestion> _questionBank = [
  _QuizQuestion(
    category: 'Dasar Komputer',
    question:
        'Bagian komputer yang bertugas memproses instruksi utama adalah...',
    options: ['RAM', 'CPU', 'SSD', 'Monitor'],
    answerIndex: 1,
    explanation:
        'CPU adalah pusat pemrosesan utama yang menjalankan instruksi program.',
  ),
  _QuizQuestion(
    category: 'Algoritma',
    question: 'Dalam pemrograman, algoritma paling tepat diartikan sebagai...',
    options: [
      'Bahasa yang hanya dipakai komputer',
      'Urutan langkah logis untuk menyelesaikan masalah',
      'Tempat menyimpan file program',
      'Aplikasi untuk membuat desain',
    ],
    answerIndex: 1,
    explanation:
        'Algoritma adalah langkah-langkah terstruktur yang dibuat untuk mencapai solusi.',
  ),
  _QuizQuestion(
    category: 'Pemrograman',
    question: 'Apa fungsi variabel dalam program?',
    options: [
      'Menyimpan nilai yang bisa digunakan kembali',
      'Menghapus semua data otomatis',
      'Mengubah komputer menjadi server',
      'Menggambar tampilan aplikasi saja',
    ],
    answerIndex: 0,
    explanation:
        'Variabel dipakai untuk menyimpan data seperti angka, teks, atau status.',
  ),
  _QuizQuestion(
    category: 'Jaringan Komputer',
    question:
        'Perangkat yang umum dipakai untuk menghubungkan jaringan lokal ke internet adalah...',
    options: ['Router', 'Keyboard', 'Speaker', 'Printer'],
    answerIndex: 0,
    explanation:
        'Router mengatur lalu lintas data antarjaringan, termasuk koneksi ke internet.',
  ),
  _QuizQuestion(
    category: 'Keamanan Digital',
    question: 'Contoh kebiasaan yang paling aman untuk menjaga akun adalah...',
    options: [
      'Memakai password yang sama di semua aplikasi',
      'Membagikan kode OTP ke teman',
      'Mengaktifkan autentikasi dua faktor',
      'Menyimpan password di status media sosial',
    ],
    answerIndex: 2,
    explanation:
        'Autentikasi dua faktor menambah lapisan keamanan selain password.',
  ),
];

_QuizQuestion _questionForLevel(_LevelData level, int index) {
  final questionIndex = (level.level + index - 1) % _questionBank.length;
  return _questionBank[questionIndex];
}

class _LevelQuizPage extends StatefulWidget {
  final _LevelData level;
  final VoidCallback onOpenMaterialTab;

  const _LevelQuizPage({required this.level, required this.onOpenMaterialTab});

  @override
  State<_LevelQuizPage> createState() => _LevelQuizPageState();
}

class _LevelQuizPageState extends State<_LevelQuizPage> {
  int _currentIndex = 0;
  int? _selectedIndex;
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.level.questions;
    final question = _questionForLevel(widget.level, _currentIndex);
    final progress = (_currentIndex + 1) / totalQuestions;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          const Positioned.fill(child: _GridDots()),
          const Positioned.fill(child: _MapBackdrop()),
          SafeArea(
            child: Column(
              children: [
                _QuizTopBar(
                  level: widget.level,
                  question: question,
                  onOpenMaterial: _openMaterial,
                ),
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
                                setState(() {
                                  _selectedIndex = i;
                                  _checked = false;
                                });
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
                  onOpenMaterial: _openMaterial,
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

  void _openMaterial() {
    Navigator.of(context).pop();
    widget.onOpenMaterialTab();
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

    if (_currentIndex == widget.level.questions - 1) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('Level selesai versi tampilan statis.'),
            backgroundColor: _greenDk,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          ),
        );
      return;
    }

    setState(() {
      _currentIndex++;
      _selectedIndex = null;
      _checked = false;
    });
  }
}

class _QuizTopBar extends StatelessWidget {
  final _LevelData level;
  final _QuizQuestion question;
  final VoidCallback onOpenMaterial;

  const _QuizTopBar({
    required this.level,
    required this.question,
    required this.onOpenMaterial,
  });

  @override
  Widget build(BuildContext context) {
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
                  'Level ${level.level}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textPri,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  question.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _textMid,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onOpenMaterial,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _iris.withValues(alpha: 0.28)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.menu_book_rounded, color: _iris, size: 16),
                  SizedBox(width: 6),
                  Text(
                    'Lihat Materi',
                    style: TextStyle(
                      color: _iris,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuizProgressCard extends StatelessWidget {
  final _LevelData level;
  final _QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _InfoChip(
                icon: Icons.quiz_rounded,
                label: 'Soal $questionNumber/$totalQuestions',
                color: _green,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: _statusIcon(level.status),
                label: _statusLabel(level.status),
                color: _statusColor(level.status),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            level.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _textPri,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Topik: ${question.category}',
            style: const TextStyle(
              color: _textMid,
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
              backgroundColor: _surfaceB,
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final _QuizQuestion question;

  const _QuestionCard({required this.question});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.24)),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.08),
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
              gradient: const LinearGradient(
                colors: [_greenDk, _green, _greenGl],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.psychology_rounded, color: _bg, size: 22),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: const TextStyle(
              color: _textPri,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.35,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  final int index;
  final String text;
  final bool selected;
  final bool checked;
  final bool correct;
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
    final wrong = checked && selected && !correct;
    final color = checked && correct
        ? _green
        : wrong
        ? const Color(0xFFFF5C7A)
        : selected
        ? _blue
        : _divider;
    final label = String.fromCharCode(65 + index);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 
            selected || (checked && correct) ? 0.12 : 0.04,
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
                    color: color == _divider ? _textMid : color,
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
                style: const TextStyle(
                  color: _textPri,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
            if (checked && correct)
              const Icon(Icons.check_circle_rounded, color: _green, size: 20)
            else if (wrong)
              const Icon(
                Icons.cancel_rounded,
                color: Color(0xFFFF5C7A),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

class _AnswerFeedback extends StatelessWidget {
  final bool correct;
  final String explanation;

  const _AnswerFeedback({required this.correct, required this.explanation});

  @override
  Widget build(BuildContext context) {
    final color = correct ? _green : const Color(0xFFFF5C7A);
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
                  style: const TextStyle(
                    color: _textSec,
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

class _QuizBottomActions extends StatelessWidget {
  final bool hasSelected;
  final bool checked;
  final bool isLastQuestion;
  final VoidCallback onOpenMaterial;
  final VoidCallback onCheck;
  final VoidCallback onNext;

  const _QuizBottomActions({
    required this.hasSelected,
    required this.checked,
    required this.isLastQuestion,
    required this.onOpenMaterial,
    required this.onCheck,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        decoration: const BoxDecoration(
          color: _surface,
          border: Border(top: BorderSide(color: _divider, width: 1)),
        ),
        child: Row(
          children: [
            _SecondaryActionButton(
              icon: Icons.menu_book_rounded,
              label: 'Lihat Materi',
              onTap: onOpenMaterial,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: hasSelected ? (checked ? onNext : onCheck) : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _green,
                  disabledBackgroundColor: _surfaceB,
                  foregroundColor: _bg,
                  disabledForegroundColor: _textMid,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  checked
                      ? isLastQuestion
                            ? 'Selesai'
                            : 'Lanjut'
                      : 'Cek Jawaban',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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

class _SecondaryActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _surfaceB,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _iris.withValues(alpha: 0.28)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: _iris, size: 18),
            const SizedBox(width: 7),
            Text(
              label,
              style: const TextStyle(
                color: _iris,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _divider),
        ),
        child: Icon(icon, color: _textSec, size: 21),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final _LevelData activeLevel;

  const _HomeHeader({required this.activeLevel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _green.withValues(alpha: 0.35), width: 1.4),
              boxShadow: [
                BoxShadow(color: _green.withValues(alpha: 0.16), blurRadius: 18),
              ],
            ),
            child: const Icon(Icons.bolt_rounded, color: _green, size: 22),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KursusKilat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _textPri,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Peta Belajar',
                  style: TextStyle(
                    color: _textMid,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: _surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _iris.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_circle_rounded, size: 15, color: _iris),
                const SizedBox(width: 6),
                Text(
                  'Level ${activeLevel.level}',
                  style: const TextStyle(
                    color: _iris,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
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

class _LevelLegend extends StatelessWidget {
  const _LevelLegend();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Peta Level',
            style: TextStyle(
              color: _textPri,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _LegendPill(
                  icon: Icons.check_rounded,
                  label: 'Selesai',
                  color: _green,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _LegendPill(
                  icon: Icons.play_arrow_rounded,
                  label: 'Aktif',
                  color: _blue,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: _LegendPill(
                  icon: Icons.lock_rounded,
                  label: 'Terkunci',
                  color: _textMid,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelMap extends StatelessWidget {
  final List<_LevelData> levels;
  final ValueChanged<_LevelData> onLevelTap;

  const _LevelMap({required this.levels, required this.onLevelTap});

  static const double _slotWidth = 132;
  static const double _nodeSize = 76;
  static const double _rowHeight = 120;
  static const double _topPadding = 14;
  static const double _bottomPadding = 34;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height =
              _topPadding +
              _bottomPadding +
              _nodeSize +
              ((levels.length - 1) * _rowHeight);

          return SizedBox(
            height: height,
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _LevelPathPainter(
                      levels: levels,
                      width: width,
                      slotWidth: _slotWidth,
                      nodeSize: _nodeSize,
                      rowHeight: _rowHeight,
                      topPadding: _topPadding,
                    ),
                  ),
                ),
                for (var i = 0; i < levels.length; i++)
                  Positioned(
                    top: _topPadding + (i * _rowHeight),
                    left: _LevelGeometry.slotLeft(
                      index: i,
                      width: width,
                      slotWidth: _slotWidth,
                    ),
                    child: SizedBox(
                      width: _slotWidth,
                      child: _LevelNode(
                        data: levels[i],
                        nodeSize: _nodeSize,
                        onTap: () => onLevelTap(levels[i]),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _LevelNode extends StatelessWidget {
  final _LevelData data;
  final double nodeSize;
  final VoidCallback onTap;

  const _LevelNode({
    required this.data,
    required this.nodeSize,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final locked = data.status == _LevelStatus.terkunci;
    final active = data.status == _LevelStatus.aktif;
    final complete = data.status == _LevelStatus.selesai;
    final statusColor = _statusColor(data.status);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: locked
                  ? null
                  : LinearGradient(
                      colors: complete
                          ? const [_greenDk, _green, _greenGl]
                          : const [_blue, _iris, _purple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              color: locked ? _surfaceB : null,
              border: Border.all(
                color: locked ? _divider : statusColor.withValues(alpha: 0.7),
                width: active ? 2.5 : 2,
              ),
              boxShadow: locked
                  ? null
                  : [
                      BoxShadow(
                        color: statusColor.withValues(alpha: active ? 0.35 : 0.22),
                        blurRadius: active ? 26 : 18,
                        spreadRadius: active ? 2 : 0,
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (locked)
                  const Icon(Icons.lock_rounded, color: _textMid, size: 28)
                else
                  Text(
                    '${data.level}',
                    style: const TextStyle(
                      color: _bg,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: _StatusBadge(status: data.status),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level ${data.level}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: locked ? _textMid : _textPri,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: locked ? _textMid : statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.quiz_rounded,
                size: 11,
                color: locked ? _textMid : _textSec,
              ),
              const SizedBox(width: 4),
              Text(
                '${data.questions} soal',
                style: TextStyle(
                  color: locked ? _textMid : _textSec,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (complete) ...[
            const SizedBox(height: 4),
            _Stars(count: data.stars),
          ],
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final _LevelStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final icon = _statusIcon(status);
    final color = _statusColor(status);

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: status == _LevelStatus.terkunci ? _surface : _bg,
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.75), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 14),
    );
  }
}

class _Stars extends StatelessWidget {
  final int count;

  const _Stars({required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              Icons.star_rounded,
              size: 13,
              color: i < count ? _green : _divider,
            ),
          ),
      ],
    );
  }
}

class _LevelPathPainter extends CustomPainter {
  final List<_LevelData> levels;
  final double width;
  final double slotWidth;
  final double nodeSize;
  final double rowHeight;
  final double topPadding;

  const _LevelPathPainter({
    required this.levels,
    required this.width,
    required this.slotWidth,
    required this.nodeSize,
    required this.rowHeight,
    required this.topPadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (levels.length < 2) return;

    for (var i = 0; i < levels.length - 1; i++) {
      final start = Offset(
        _LevelGeometry.centerX(index: i, width: width, slotWidth: slotWidth),
        topPadding + (i * rowHeight) + (nodeSize / 2),
      );
      final end = Offset(
        _LevelGeometry.centerX(
          index: i + 1,
          width: width,
          slotWidth: slotWidth,
        ),
        topPadding + ((i + 1) * rowHeight) + (nodeSize / 2),
      );

      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(start.dx, start.dy + 48, end.dx, end.dy - 48, end.dx, end.dy);

      final current = levels[i].status;
      final next = levels[i + 1].status;
      final lockedSegment =
          current == _LevelStatus.terkunci || next == _LevelStatus.terkunci;
      final segmentColor = lockedSegment
          ? _divider
          : next == _LevelStatus.aktif
          ? _iris
          : _green;

      final shadowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = segmentColor.withValues(alpha: lockedSegment ? 0.08 : 0.12);

      final mainPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = lockedSegment ? 5 : 7
        ..strokeCap = StrokeCap.round
        ..color = segmentColor.withValues(alpha: lockedSegment ? 0.55 : 0.95);

      canvas.drawPath(path, shadowPaint);
      if (lockedSegment) {
        _drawDashedPath(canvas, path, mainPaint);
      } else {
        canvas.drawPath(path, mainPaint);
      }
    }
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 12.0;
    const gapLength = 10.0;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LevelPathPainter oldDelegate) {
    return oldDelegate.levels != levels ||
        oldDelegate.width != width ||
        oldDelegate.slotWidth != slotWidth ||
        oldDelegate.nodeSize != nodeSize ||
        oldDelegate.rowHeight != rowHeight ||
        oldDelegate.topPadding != topPadding;
  }
}

class _LevelGeometry {
  static const List<double> _anchors = [0.24, 0.58, 0.76, 0.40];

  static double slotLeft({
    required int index,
    required double width,
    required double slotWidth,
  }) {
    final anchor = _anchors[index % _anchors.length];
    final rawLeft = (width * anchor) - (slotWidth / 2);
    final maxLeft = math.max(12.0, width - slotWidth - 12.0);
    return rawLeft.clamp(12.0, maxLeft).toDouble();
  }

  static double centerX({
    required int index,
    required double width,
    required double slotWidth,
  }) {
    return slotLeft(index: index, width: width, slotWidth: slotWidth) +
        (slotWidth / 2);
  }
}

Color _statusColor(_LevelStatus status) {
  if (status == _LevelStatus.selesai) return _green;
  if (status == _LevelStatus.aktif) return _blue;
  return _textMid;
}

String _statusLabel(_LevelStatus status) {
  if (status == _LevelStatus.selesai) return 'Selesai';
  if (status == _LevelStatus.aktif) return 'Aktif';
  return 'Preview';
}

IconData _statusIcon(_LevelStatus status) {
  if (status == _LevelStatus.selesai) return Icons.check_rounded;
  if (status == _LevelStatus.aktif) return Icons.play_arrow_rounded;
  return Icons.lock_rounded;
}

class _MapBackdrop extends StatelessWidget {
  const _MapBackdrop();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _iris.withValues(alpha: 0.08),
            Colors.transparent,
            _green.withValues(alpha: 0.04),
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
      ),
    );
  }
}

class _GridDots extends StatelessWidget {
  const _GridDots();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DotGridPainter());
  }
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const spacing = 30.0;
    const radius = 1.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final fx = (x / size.width - 0.5).abs() * 2;
        final fy = (y / size.height - 0.5).abs() * 2;
        final fade = math.max(fx, fy);
        final opacity = (1.0 - fade * 1.2).clamp(0.0, 1.0);
        if (opacity < 0.05) continue;
        paint.color = _divider.withValues(alpha: opacity);
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Placeholder pages
class PencapaianPage extends StatelessWidget {
  const PencapaianPage({super.key});

  @override
  Widget build(BuildContext context) => const pencapaian.PencapaianPage();
}

class MyCoursesPage extends StatelessWidget {
  const MyCoursesPage({super.key});

  @override
  Widget build(BuildContext context) => const kursus.KursusPage();
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) => const profil.ProfilePage();
}
