import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

// ─── COLOR TOKENS (selaras dengan ProfilePage asli) ───────────────────────

const _bg       = Color(0xFF080810);
const _surface  = Color(0xFF13131F);
const _surfaceB = Color(0xFF1C1C2E);
const _green    = Color(0xFF2ECC71);
const _greenDk  = Color(0xFF1AA355);
const _greenGl  = Color(0xFF5DEBA0);
const _blue     = Color(0xFF4E9DFF);
const _amber    = Color(0xFFFFB347);
const _purple   = Color(0xFFAA88FF);
const _divider  = Color(0xFF1E1E30);
const _textPri  = Color(0xFFF0F0FA);
const _textSec  = Color(0xFF9999BB);
const _textMid  = Color(0xFF666888);

// ─── DATA MODELS ──────────────────────────────────────────────────────────

class BadgeData {
  final String emoji;
  final String title;
  final String desc;
  final Color  color;
  bool unlocked;
  BadgeData({
    required this.emoji,
    required this.title,
    required this.desc,
    required this.color,
    required this.unlocked,
  });
}

class ActivityData {
  final String day;
  double minutes;
  ActivityData(this.day, this.minutes);
}

class QuizQuestion {
  final String       question;
  final List<String> options;
  final int          correctIndex;
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// ─── PENCAPAIAN PAGE ──────────────────────────────────────────────────────

class PencapaianPage extends StatefulWidget {
  const PencapaianPage({super.key});

  @override
  State<PencapaianPage> createState() => _PencapaianPageState();
}

class _PencapaianPageState extends State<PencapaianPage>
    with TickerProviderStateMixin {

  // ── Animation controllers
  late AnimationController _glowCtrl;
  late Animation<double>   _glowPulse;
  late AnimationController _progressCtrl;
  late Animation<double>   _progressAnim;
  late AnimationController _levelUpCtrl;
  late Animation<double>   _levelUpAnim;

  // ── State
  int    _level       = 12;
  int    _xp          = 1240;
  int    _xpNext      = 1500;
  int    _streak      = 7;
  final int _kursus   = 2;
  int    _jam         = 64;
  int    _kuisSelesai = 21;
  bool   _showLevelUp = false;

  // Quiz state
  int  _quizIndex    = 0;
  int? _selectedOpt;
  bool _quizAnswered = false;

  // Streak days (7 days)
  final List<bool> _streakDone = [true, true, true, true, true, true, true];

  final List<ActivityData> _activity = [
    ActivityData('Sen', 72),
    ActivityData('Sel', 36),
    ActivityData('Rab', 90),
    ActivityData('Kam', 54),
    ActivityData('Jum', 81),
    ActivityData('Sab', 27),
    ActivityData('Min', 63),
  ];

  late List<BadgeData> _badges;

  final List<QuizQuestion> _quizBank = const [
    QuizQuestion(
      question:     'Apa kepanjangan XP dalam gamifikasi?',
      options:      ['Experience Points', 'Extra Power', 'Exam Practice', 'Exercise Plan'],
      correctIndex: 0,
    ),
    QuizQuestion(
      question:     'Berapa hari untuk badge "Streak 7 Hari"?',
      options:      ['3 hari', '5 hari', '7 hari', '10 hari'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question:     'Kamu berada di level berapa sekarang?',
      options:      ['Level 10', 'Level 11', 'Level 12', 'Level 13'],
      correctIndex: 2,
    ),
    QuizQuestion(
      question:     'Berapa XP yang dibutuhkan untuk naik level?',
      options:      ['500 XP', '1.000 XP', '1.500 XP', '2.000 XP'],
      correctIndex: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _badges = [
      BadgeData(emoji: '🔥', title: 'Streak 7 Hari',  desc: 'Belajar 7 hari berturut-turut', color: const Color(0xFFFF6B35), unlocked: true),
      BadgeData(emoji: '⚡', title: 'Cepat Kilat',     desc: 'Selesaikan modul < 30 menit',   color: _green,                  unlocked: true),
      BadgeData(emoji: '🏆', title: 'Juara Kelas',     desc: 'Nilai kuis sempurna 3x',         color: _amber,                  unlocked: true),
      BadgeData(emoji: '🎓', title: 'Lulus Perdana',   desc: 'Selesaikan kursus pertama',      color: _blue,                   unlocked: true),
      BadgeData(emoji: '🌟', title: 'Bintang Rising',  desc: 'Capai top 10% pelajar',          color: _purple,                 unlocked: false),
      BadgeData(emoji: '💎', title: 'Diamond Learner', desc: 'Selesaikan 5 kursus',            color: _greenGl,                unlocked: false),
    ];

    _glowCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowPulse = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _progressCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeOutCubic);

    _levelUpCtrl = AnimationController(
      vsync:    this,
      duration: const Duration(milliseconds: 800),
    );
    _levelUpAnim = CurvedAnimation(parent: _levelUpCtrl, curve: Curves.elasticOut);

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _progressCtrl.dispose();
    _levelUpCtrl.dispose();
    super.dispose();
  }

  // ─── Logic ──────────────────────────────────────────────────────────────

  void _addXp(int amount) {
    setState(() {
      _xp += amount;
      if (_xp >= _xpNext) {
        _xp      -= _xpNext;
        _level++;
        _xpNext   = (_xpNext * 1.3).round();
        _showLevelUp = true;
        HapticFeedback.heavyImpact();
        _levelUpCtrl.forward(from: 0);
      }
      _progressCtrl.forward(from: 0);
    });
  }

  void _checkBadges() {
    bool changed = false;
    if (_streak >= 7 && !_badges[0].unlocked) {
      _badges[0].unlocked = true;
      changed = true;
    }
    if (_kursus >= 5 && !_badges[5].unlocked) {
      _badges[5].unlocked = true;
      changed = true;
    }
    if (changed) setState(() {});
  }

  void _simulateBelajar() {
    final now    = DateTime.now();
    final dayIdx = (now.weekday - 1) % 7;
    if (!_streakDone[dayIdx]) {
      setState(() {
        _streakDone[dayIdx]        = true;
        _activity[dayIdx].minutes  = (_activity[dayIdx].minutes + 30).clamp(0, 90);
        _streak = _streakDone.where((d) => d).length;
        _jam++;
      });
      _addXp(30);
      _checkBadges();
      HapticFeedback.mediumImpact();
    } else {
      _showSnack('Kamu sudah belajar hari ini! 🎉');
    }
  }

  void _resetStreak() {
    setState(() {
      for (int i = 0; i < _streakDone.length; i++) {
        _streakDone[i] = false;
      }
      _streak = 0;
    });
  }

  void _answerQuiz(int optIdx) {
    if (_quizAnswered) return;
    final correct = optIdx == _quizBank[_quizIndex].correctIndex;
    setState(() {
      _selectedOpt  = optIdx;
      _quizAnswered = true;
    });
    if (correct) {
      _kuisSelesai++;
      _addXp(50);
      HapticFeedback.lightImpact();
    }
  }

  void _nextQuiz() {
    setState(() {
      _quizIndex    = (_quizIndex + 1) % _quizBank.length;
      _selectedOpt  = null;
      _quizAnswered = false;
    });
  }

  void _showSnack(String msg, {Color color = _green}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: const TextStyle(color: _textPri, fontWeight: FontWeight.w700)),
        backgroundColor: _surface,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withValues(alpha: 0.4)),
        ),
        margin:   const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _editActivity(int i) {
    final ctrl = TextEditingController(text: _activity[i].minutes.toInt().toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Menit belajar — ${_activity[i].day}',
          style: const TextStyle(color: _textPri, fontSize: 15),
        ),
        content: TextField(
          controller:   ctrl,
          keyboardType: TextInputType.number,
          autofocus:    true,
          style: const TextStyle(color: _textPri),
          decoration: InputDecoration(
            hintText:  'Masukkan menit (0–90)',
            hintStyle: const TextStyle(color: _textMid),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   const BorderSide(color: _divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:   BorderSide(color: _green.withValues(alpha: 0.5)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: _textMid)),
          ),
          TextButton(
            onPressed: () {
              final v = double.tryParse(ctrl.text);
              if (v != null) setState(() => _activity[i].minutes = v.clamp(0, 90));
              Navigator.pop(context);
            },
            child: const Text('Simpan', style: TextStyle(color: _green)),
          ),
        ],
      ),
    );
  }

  void _showBadgeDetail(BadgeData b) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:        _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: b.color.withValues(alpha: b.unlocked ? 0.3 : 0.1)),
            boxShadow: [BoxShadow(color: b.color.withValues(alpha: 0.1), blurRadius: 32)],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(b.unlocked ? b.emoji : '🔒', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              b.title,
              style: const TextStyle(color: _textPri, fontSize: 18, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(b.desc, style: const TextStyle(color: _textSec, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color:        b.unlocked ? b.color.withValues(alpha: 0.15) : _divider,
                borderRadius: BorderRadius.circular(20),
                border:       Border.all(color: b.unlocked ? b.color.withValues(alpha: 0.4) : Colors.transparent),
              ),
              child: Text(
                b.unlocked ? 'Badge Terbuka ✓' : 'Belum Terbuka — ${b.desc}',
                style: TextStyle(
                  color:      b.unlocked ? b.color : _textMid,
                  fontSize:   12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: _surfaceB,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup', style: TextStyle(color: _textSec)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _badges.where((b) => b.unlocked).length;

    return Scaffold(
      backgroundColor: _bg,
      body: Stack(children: [
        // Ambient glow — hijau, sesuai ProfilePage
        AnimatedBuilder(
          animation: _glowPulse,
          builder: (_, _) => Positioned(
            top: -80, left: -80,
            child: Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _green.withValues(alpha: 0.05 + 0.03 * _glowPulse.value),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
        ),
        const Positioned.fill(child: _GridDots()),

        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildAppBar(unlockedCount)),
              SliverToBoxAdapter(child: _buildLevelCard()),
              SliverToBoxAdapter(child: _buildStatsRow()),
              SliverToBoxAdapter(child: _buildStreakSection()),
              SliverToBoxAdapter(child: _buildActivityChart()),
              SliverToBoxAdapter(child: _buildBadgesSection(unlockedCount)),
              SliverToBoxAdapter(child: _buildQuizSection()),
              SliverToBoxAdapter(child: _buildMilestoneSection()),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),

        // Level-up overlay — hijau
        if (_showLevelUp)
          GestureDetector(
            onTap: () => setState(() => _showLevelUp = false),
            child: Container(
              color: Colors.black54,
              child: Center(
                child: AnimatedBuilder(
                  animation: _levelUpAnim,
                  builder: (_, _) => Transform.scale(
                    scale: _levelUpAnim.value,
                    child: Container(
                      margin:  const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color:        _surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _green.withValues(alpha: 0.4)),
                        boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.2), blurRadius: 40)],
                      ),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        const Text('🎉', style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 12),
                        const Text(
                          'Level Up!',
                          style: TextStyle(
                            color: _green, fontSize: 28, fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Selamat! Kamu sekarang Level $_level',
                          style: const TextStyle(color: _textSec, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => setState(() => _showLevelUp = false),
                            child: const Text('Lanjutkan!', style: TextStyle(fontWeight: FontWeight.w800)),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar(int unlockedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text(
            'Pencapaian',
            style: TextStyle(
              color: _textPri, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Level $_level · ${_rankTitle()}',
            style: const TextStyle(color: _textMid, fontSize: 12),
          ),
        ]),
        const Spacer(),
        // Badge chip — hijau, sesuai ProfilePage
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color:        _green.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: _green.withValues(alpha: 0.3)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Text('🏅', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 5),
            Text(
              '$unlockedCount Badge',
              style: const TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ]),
        ),
      ]),
    );
  }

  String _rankTitle() {
    if (_level >= 15) return 'Master Pelajar';
    if (_level >= 12) return 'Pelajar Hebat';
    return 'Pelajar Aktif';
  }

  // ─── Level Card ───────────────────────────────────────────────────────────

  Widget _buildLevelCard() {
    final pct = _xp / _xpNext;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Gradient hijau gelap seperti level badge di ProfilePage
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2A16), _surface],
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green.withValues(alpha: 0.25)),
          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.05), blurRadius: 24)],
        ),
        child: Column(children: [
          Row(children: [
            // Level circle — hijau
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape:  BoxShape.circle,
                color:  _green.withValues(alpha: 0.12),
                border: Border.all(color: _green.withValues(alpha: 0.3), width: 2),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('LVL', style: TextStyle(
                  color: _green, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1,
                )),
                Text('$_level', style: const TextStyle(
                  color: _green, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5,
                )),
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(
                    'Level $_level — ',
                    style: const TextStyle(color: _textPri, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    _rankTitle(),
                    style: const TextStyle(color: _green, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(
                  '$_xp / $_xpNext XP ke Level ${_level + 1}',
                  style: const TextStyle(color: _textMid, fontSize: 11),
                ),
                const SizedBox(height: 8),
                // Progress bar — hijau gradient seperti ProfilePage
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, _) => Stack(children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(color: _divider, borderRadius: BorderRadius.circular(3)),
                    ),
                    FractionallySizedBox(
                      widthFactor: pct * _progressAnim.value,
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_greenDk, _green, _greenGl],
                          ),
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 4)],
                        ),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
          const SizedBox(height: 16),
          const Divider(color: _divider, height: 1),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            _MiniStat(value: '$_xp', label: 'Total XP',   color: _green),
            _VertDivider(),
            _MiniStat(value: '${math.max(1, 100 - _level * 3)}', label: 'Peringkat', color: _blue),
            _VertDivider(),
            _MiniStat(value: 'Top 15%', label: 'Posisi',  color: _greenGl),
          ]),
        ]),
      ),
    );
  }

  // ─── Stats Row ────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(children: [
        _StatCard(value: '$_kursus',      label: 'Kursus\nSelesai',     icon: Icons.check_circle_rounded, color: _blue),
        const SizedBox(width: 10),
        _StatCard(value: '${_jam}h',      label: 'Jam\nBelajar',        icon: Icons.access_time_rounded,  color: _green),
        const SizedBox(width: 10),
        _StatCard(value: '$_kuisSelesai', label: 'Kuis\nDiselesaikan',  icon: Icons.quiz_rounded,         color: _purple),
      ]),
    );
  }

  // ─── Streak Section ───────────────────────────────────────────────────────

  Widget _buildStreakSection() {
    final days  = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
    final fullN = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Gradient hijau gelap — konsisten dengan ProfilePage streak card
          gradient: const LinearGradient(
            colors: [Color(0xFF0D2A16), Color(0xFF13131F)],
            begin:  Alignment.topLeft,
            end:    Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _green.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color:        _green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border:       Border.all(color: _green.withValues(alpha: 0.25)),
              ),
              child: const Center(child: Text('🔥', style: TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(
                  '$_streak Hari Streak!',
                  style: const TextStyle(
                    color: _textPri, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                if (_streak >= 7)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color:        _green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border:       Border.all(color: _green.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Rekor!',
                      style: TextStyle(color: _green, fontSize: 9, fontWeight: FontWeight.w800),
                    ),
                  ),
              ]),
              const SizedBox(height: 3),
              Text(
                _streak >= 7
                    ? 'Luar biasa! Seminggu penuh 🎉'
                    : _streak == 0
                    ? 'Mulai streakmu hari ini!'
                    : 'Terus semangat! $_streak hari berturut.',
                style: const TextStyle(color: _textMid, fontSize: 12),
              ),
            ])),
          ]),
          const SizedBox(height: 14),

          // Day dots — hijau
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final done = _streakDone[i];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _streakDone[i] = !_streakDone[i];
                    _streak = _streakDone.where((d) => d).length;
                  });
                  _checkBadges();
                  HapticFeedback.selectionClick();
                },
                child: Tooltip(
                  message: fullN[i],
                  child: Column(children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 30, height: 30,
                      decoration: BoxDecoration(
                        shape:  BoxShape.circle,
                        color:  done ? _green.withValues(alpha: 0.2) : _divider,
                        border: Border.all(color: done ? _green.withValues(alpha: 0.6) : _divider),
                      ),
                      child: Center(
                        child: done
                            ? const Icon(Icons.check_rounded, color: _green, size: 15)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      days[i],
                      style: TextStyle(
                        color:      done ? _green : _textMid,
                        fontSize:   9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ]),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),

          // Action buttons
          Row(children: [
            _ActionButton(
              label: 'Belajar Hari Ini',
              icon:  Icons.play_circle_rounded,
              color: _green,
              onTap: _simulateBelajar,
            ),
            const SizedBox(width: 8),
            _ActionButton(
              label: 'Reset Streak',
              icon:  Icons.refresh_rounded,
              color: _textMid,
              onTap: _resetStreak,
            ),
          ]),
        ]),
      ),
    );
  }

  // ─── Activity Chart ───────────────────────────────────────────────────────

  Widget _buildActivityChart() {
    final maxMin = _activity.map((a) => a.minutes).reduce(math.max);
    final avg    = (_activity.map((a) => a.minutes).reduce((a, b) => a + b) / 7).round();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text(
            'Aktivitas Minggu Ini',
            style: TextStyle(
              color: _textPri, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text('$avg menit avg', style: const TextStyle(color: _textMid, fontSize: 11)),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        _surface,
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: _divider),
          ),
          child: AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, _) => Row(
              mainAxisAlignment:  MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _activity.asMap().entries.map((e) {
                final i     = e.key;
                final a     = e.value;
                final ratio = maxMin > 0 ? a.minutes / maxMin : 0.0;
                final h     = (80.0 * ratio * _progressAnim.value).clamp(4.0, 80.0);
                final hi    = ratio > 0.7;
                return GestureDetector(
                  onTap: () => _editActivity(i),
                  child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                    Text('${a.minutes.toInt()}m', style: const TextStyle(color: _textMid, fontSize: 9)),
                    const SizedBox(height: 4),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: 28, height: h,
                      decoration: BoxDecoration(
                        // Hijau gradient — sama dengan ProfilePage progress bars
                        gradient: LinearGradient(
                          colors: hi
                              ? [_greenDk, _green, _greenGl]
                              : [_divider, _surfaceB],
                          begin: Alignment.bottomCenter,
                          end:   Alignment.topCenter,
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: hi
                            ? [BoxShadow(color: _green.withValues(alpha: 0.3), blurRadius: 6)]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      a.day,
                      style: TextStyle(
                        color:      hi ? _green : _textMid,
                        fontSize:   10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 6),
        const Text('Ketuk bar untuk edit menit belajar', style: TextStyle(color: _textMid, fontSize: 10)),
      ]),
    );
  }

  // ─── Badges Section ───────────────────────────────────────────────────────

  Widget _buildBadgesSection(int unlockedCount) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text(
            'Badge Saya',
            style: TextStyle(
              color: _textPri, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Text('$unlockedCount / ${_badges.length} terbuka',
              style: const TextStyle(color: _textMid, fontSize: 11)),
        ]),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82,
          ),
          itemCount: _badges.length,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              _showBadgeDetail(_badges[i]);
            },
            child: _BadgeCard(data: _badges[i]),
          ),
        ),
      ]),
    );
  }

  // ─── Quiz Section ─────────────────────────────────────────────────────────

  Widget _buildQuizSection() {
    final q = _quizBank[_quizIndex];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text(
            'Mini Kuis',
            style: TextStyle(
              color: _textPri, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:        _purple.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border:       Border.all(color: _purple.withValues(alpha: 0.3)),
            ),
            child: Text(
              '${(_quizIndex % _quizBank.length) + 1} / ${_quizBank.length}',
              style: const TextStyle(color: _purple, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
        ]),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color:        _surface,
            borderRadius: BorderRadius.circular(20),
            border:       Border.all(color: _divider),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        _green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('+50 XP', style: TextStyle(color: _green, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ]),
            const SizedBox(height: 12),
            Text(
              q.question,
              style: const TextStyle(
                color: _textPri, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            ...q.options.asMap().entries.map((e) {
              final i      = e.key;
              final opt    = e.value;
              final isCorr = i == q.correctIndex;
              final isSel  = _selectedOpt == i;

              Color borderColor = _divider;
              Color bgColor     = _surfaceB;
              Color textColor   = _textSec;
              IconData? trailIcon;

              if (_quizAnswered) {
                if (isCorr) {
                  borderColor = _green.withValues(alpha: 0.6);
                  bgColor     = _green.withValues(alpha: 0.1);
                  textColor   = _green;
                  trailIcon   = Icons.check_circle_rounded;
                } else if (isSel && !isCorr) {
                  borderColor = Colors.red.withValues(alpha: 0.6);
                  bgColor     = Colors.red.withValues(alpha: 0.08);
                  textColor   = Colors.redAccent;
                  trailIcon   = Icons.cancel_rounded;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: () => _answerQuiz(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color:        bgColor,
                      borderRadius: BorderRadius.circular(12),
                      border:       Border.all(color: borderColor),
                    ),
                    child: Row(children: [
                      Expanded(child: Text(opt, style: TextStyle(color: textColor, fontSize: 13))),
                      if (trailIcon != null)
                        Icon(trailIcon, color: isCorr ? _green : Colors.redAccent, size: 18),
                    ]),
                  ),
                ),
              );
            }),
            if (_quizAnswered) ...[
              const SizedBox(height: 4),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                  _selectedOpt == q.correctIndex
                      ? 'Benar! +50 XP diperoleh 🎉'
                      : 'Salah, coba lagi lain kali.',
                  style: TextStyle(
                    color:      _selectedOpt == q.correctIndex ? _green : Colors.redAccent,
                    fontSize:   12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: _nextQuiz,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color:        _green.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                      border:       Border.all(color: _green.withValues(alpha: 0.3)),
                    ),
                    child: const Text(
                      'Berikutnya →',
                      style: TextStyle(color: _green, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ]),
            ],
          ]),
        ),
      ]),
    );
  }

  // ─── Milestone Section ────────────────────────────────────────────────────

  Widget _buildMilestoneSection() {
    final milestones = [
      (done: true,          xp: '100 XP',   label: 'Mulai perjalanan belajar'),
      (done: true,          xp: '300 XP',   label: 'Selesaikan kursus pertama'),
      (done: true,          xp: '600 XP',   label: 'Streak 7 hari berturut'),
      (done: true,          xp: '1.000 XP', label: 'Raih Level 10'),
      (done: _level >= 13,  xp: '1.500 XP', label: 'Capai Level 13'),
      (done: _kursus >= 5,  xp: '2.500 XP', label: 'Selesaikan 5 kursus'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Perjalanan XP',
          style: TextStyle(
            color: _textPri, fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:        _surface,
            borderRadius: BorderRadius.circular(16),
            border:       Border.all(color: _divider),
          ),
          child: Column(
            children: List.generate(milestones.length, (i) {
              final m      = milestones[i];
              final isLast = i == milestones.length - 1;
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Column(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: m.done ? _green.withValues(alpha: 0.15) : _divider,
                      border: Border.all(
                        color: m.done ? _green.withValues(alpha: 0.5) : _textMid.withValues(alpha: 0.2),
                        width: m.done ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: m.done
                          ? const Icon(Icons.check_rounded, color: _green, size: 14)
                          : const Icon(Icons.lock_outline_rounded, color: _textMid, size: 12),
                    ),
                  ),
                  if (!isLast)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: 1.5, height: 28,
                      color: m.done ? _green.withValues(alpha: 0.25) : _divider,
                    ),
                ]),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                    child: Row(children: [
                      Expanded(
                        child: Text(
                          m.label,
                          style: TextStyle(
                            color:      m.done ? _textPri : _textMid,
                            fontSize:   13,
                            fontWeight: m.done ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color:        m.done ? _green.withValues(alpha: 0.12) : _divider,
                          borderRadius: BorderRadius.circular(8),
                          border:       Border.all(
                            color: m.done ? _green.withValues(alpha: 0.3) : Colors.transparent,
                          ),
                        ),
                        child: Text(
                          m.xp,
                          style: TextStyle(
                            color:      m.done ? _green : _textMid,
                            fontSize:   10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ]);
            }),
          ),
        ),
      ]),
    );
  }
}

// ─── ACTION BUTTON ────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color:        color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}

// ─── BADGE CARD ───────────────────────────────────────────────────────────

class _BadgeCard extends StatelessWidget {
  final BadgeData data;
  const _BadgeCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: data.unlocked ? data.color.withValues(alpha: 0.25) : _divider),
        boxShadow: data.unlocked
            ? [BoxShadow(color: data.color.withValues(alpha: 0.08), blurRadius: 12)]
            : null,
      ),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(alignment: Alignment.center, children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:  data.unlocked ? data.color.withValues(alpha: 0.12) : _divider,
              border: Border.all(color: data.unlocked ? data.color.withValues(alpha: 0.3) : Colors.transparent),
            ),
          ),
          data.unlocked
              ? Text(data.emoji, style: const TextStyle(fontSize: 22))
              : const Icon(Icons.lock_rounded, color: _textMid, size: 20),
        ]),
        const SizedBox(height: 8),
        Text(
          data.title,
          textAlign: TextAlign.center,
          maxLines:  2,
          style: TextStyle(
            color:      data.unlocked ? _textPri : _textMid,
            fontSize:   10,
            fontWeight: FontWeight.w700,
            height:     1.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          data.unlocked ? 'Terbuka' : 'Terkunci',
          style: TextStyle(
            color:      data.unlocked ? data.color : _textMid,
            fontSize:   9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ]),
    );
  }
}

// ─── HELPER WIDGETS ───────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String   value;
  final String   label;
  final IconData icon;
  final Color    color;

  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color:        _surface,
          borderRadius: BorderRadius.circular(14),
          border:       Border.all(color: _divider),
        ),
        child: Column(children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: color, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _textMid, fontSize: 9, height: 1.3),
          ),
        ]),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String value;
  final String label;
  final Color  color;
  const _MiniStat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: _textMid, fontSize: 10)),
    ]);
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 32, color: _divider);
}

// ─── GRID DOTS ────────────────────────────────────────────────────────────

class _GridDots extends StatelessWidget {
  const _GridDots();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _DotGridPainter());
}

class _DotGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    const spacing = 30.0;
    const r = 1.0;
    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final fx      = (x / size.width  - 0.5).abs() * 2;
        final fy      = (y / size.height - 0.5).abs() * 2;
        final f       = math.max(fx, fy);
        final opacity = (1.0 - f * 1.2).clamp(0.0, 1.0);
        if (opacity < 0.05) continue;
        canvas.drawCircle(
          Offset(x, y), r,
          paint..color = const Color(0xFF1E1E30).withValues(alpha: opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ─── ENTRY POINT ──────────────────────────────────────────────────────────

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PencapaianPage(),
  ));
}