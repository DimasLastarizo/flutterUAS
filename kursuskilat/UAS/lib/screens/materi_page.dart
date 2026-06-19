// materi_page.dart
// Berisi: Models, Sample Data, MateriPage, KursusCard, Helper Widgets
// Pasangan: module_detail_page.dart
// ✅ Light/Dark mode via AppTheme (provider)

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/providers/app_data_provider.dart';
import 'dart:math' as math;
import 'app_theme.dart';
import 'module_detail_page.dart'; // ← import ModuleDetailPage

// ── MODELS ───────────────────────────────────────────────────────────────────
enum CourseStatus { ongoing, completed, notStarted }

class SubMateri {
  final String title, duration, content;
  final List<String> keyPoints;
  final String? codeExample;
  bool isDone;
  SubMateri({
    required this.title,
    required this.duration,
    required this.content,
    required this.keyPoints,
    this.codeExample,
    this.isDone = false,
  });
}

class ModulMateri {
  final int? id;
  final String title, emoji, totalDuration, videoTitle, videoDescription;
  final List<SubMateri> subMateri;
  bool isDone, isExpanded;
  ModulMateri({
    this.id,
    required this.title,
    required this.emoji,
    required this.totalDuration,
    required this.videoTitle,
    required this.videoDescription,
    required this.subMateri,
    this.isDone = false,
    this.isExpanded = false,
  });
}

class KursusData {
  final int id;
  final String emoji,
      category,
      title,
      instructor,
      totalDuration,
      rating,
      description,
      totalStudents,
      lastAccessed;
  final int modulesTotal;
  final Color accentStart, accentEnd;
  double progress;
  int modulesDone;
  CourseStatus status;
  bool isFavorite;
  final String introVideoUrl;
  KursusData({
    required this.id,
    required this.emoji,
    required this.category,
    required this.title,
    required this.instructor,
    required this.progress,
    required this.totalDuration,
    required this.modulesTotal,
    required this.modulesDone,
    required this.rating,
    required this.status,
    required this.accentStart,
    required this.accentEnd,
    required this.lastAccessed,
    required this.description,
    required this.totalStudents,
    this.isFavorite = false,
    this.introVideoUrl = '',
  });
}

// ── SAMPLE DATA ───────────────────────────────────────────────────────────────
List<ModulMateri> buildModules(String ct) => [
  ModulMateri(
    title: 'Istilah Dasar',
    emoji: '\u{1F4D8}',
    totalDuration: 'Ringkas',
    videoTitle: 'Istilah inti $ct',
    videoDescription: 'Kumpulan konsep awal yang perlu dipahami.',
    subMateri: [
      SubMateri(
        title: 'Istilah Dasar',
        duration: 'Ringkas',
        content:
            'Bagian ini mengenalkan istilah dasar dalam $ct sebagai bahasa bersama sebelum masuk ke pembahasan yang lebih dalam. Dalam soal pilihan ganda, istilah dasar sering menjadi kunci karena satu kata dapat membedakan jawaban yang benar dan jawaban yang sekadar terdengar mirip.\n\nFokus bacaan ini adalah memahami arti konsep, fungsi konsep, dan hubungan awal antar istilah. User tidak diarahkan untuk mempraktikkan tools tertentu, tetapi diajak mengenali pola pertanyaan yang biasanya muncul dari definisi, karakteristik, dan contoh penerapan konsep.',
        keyPoints: [
          'Definisi konsep utama',
          'Fungsi setiap istilah',
          'Perbedaan istilah yang mirip',
          'Contoh penerapan secara umum',
        ],
      ),
    ],
  ),
  ModulMateri(
    title: 'Konsep Inti',
    emoji: '\u{1F9E0}',
    totalDuration: 'Teori',
    videoTitle: 'Fondasi konsep $ct',
    videoDescription: 'Pembahasan inti yang sering menjadi dasar soal.',
    subMateri: [
      SubMateri(
        title: 'Konsep Inti',
        duration: 'Teori',
        content:
            'Konsep inti menjelaskan prinsip yang membuat $ct bekerja sebagai sebuah bidang ilmu. Bagian ini tidak berfokus pada langkah teknis, melainkan pada alasan mengapa suatu mekanisme digunakan, masalah apa yang diselesaikan, dan batasan apa yang perlu diketahui.\n\nUntuk kebutuhan kuis, materi ini membantu user menjawab soal yang menanyakan hubungan sebab-akibat, pilihan konsep yang paling tepat, serta alasan suatu pendekatan dipakai dalam konteks tertentu.',
        keyPoints: [
          'Prinsip kerja utama',
          'Masalah yang diselesaikan',
          'Kelebihan dan batasan konsep',
          'Hubungan sebab-akibat',
        ],
      ),
    ],
  ),
  ModulMateri(
    title: 'Hubungan Antar Konsep',
    emoji: '\u{1F517}',
    totalDuration: 'Analisis',
    videoTitle: 'Keterkaitan konsep $ct',
    videoDescription: 'Melihat bagaimana konsep saling terhubung.',
    subMateri: [
      SubMateri(
        title: 'Hubungan Antar Konsep',
        duration: 'Analisis',
        content:
            'Dalam satu mata pelajaran, konsep jarang berdiri sendiri. Satu konsep biasanya menjadi syarat bagi konsep lain, atau menjadi pembanding untuk menentukan pendekatan yang paling sesuai. Karena itu, user perlu melihat $ct sebagai rangkaian ide yang saling terhubung.\n\nBagian ini disiapkan untuk soal yang menuntut pemahaman hubungan, bukan hafalan. Contohnya soal yang meminta user memilih konsep paling cocok, membedakan dua mekanisme, atau menentukan akibat dari perubahan pada sebuah sistem.',
        keyPoints: [
          'Konsep prasyarat',
          'Konsep pembanding',
          'Dampak perubahan sistem',
          'Pola hubungan dalam soal',
        ],
      ),
    ],
  ),
  ModulMateri(
    title: 'Pola Soal Kuis',
    emoji: '\u{1F3AF}',
    totalDuration: 'Kuis',
    videoTitle: 'Arah soal pilihan ganda',
    videoDescription: 'Ringkasan konsep yang rawan keluar di kuis.',
    subMateri: [
      SubMateri(
        title: 'Pola Soal Kuis',
        duration: 'Kuis',
        content:
            'Bagian ini merangkum cara konsep $ct biasanya diubah menjadi pertanyaan pilihan ganda. Soal dapat berbentuk definisi langsung, perbandingan dua konsep, studi kasus singkat, atau pertanyaan yang meminta user memilih alasan paling logis.\n\nTujuannya bukan memberi bocoran jawaban, tetapi membiasakan user membaca soal secara konseptual. Dengan begitu, user dapat membedakan jawaban yang benar berdasarkan makna konsep, bukan hanya berdasarkan kata yang terlihat familiar.',
        keyPoints: [
          'Soal definisi',
          'Soal perbandingan konsep',
          'Soal studi kasus singkat',
          'Distraktor jawaban yang mirip',
        ],
      ),
    ],
  ),
];

List<KursusData> buildCourses() => [
  KursusData(
    id: 1,
    emoji: '\u{1F4BB}',
    category: 'PROGRAMMING',
    title: 'Dasar Pemrograman',
    instructor: 'KursusKilat',
    progress: 0.25,
    totalDuration: 'Materi teori',
    modulesTotal: 4,
    modulesDone: 3,
    rating: '-',
    status: CourseStatus.ongoing,
    accentStart: const Color(0xFF1A2A1A),
    accentEnd: const Color(0xFF1A1F1A),
    lastAccessed: '',
    totalStudents: '',
    description:
        'Konsep variabel, tipe data, operator, kondisi, dan alur logika program.',
  ),
  KursusData(
    id: 2,
    emoji: '\u{1F9E9}',
    category: 'ILMU KOMPUTER',
    title: 'Struktur Data & Algoritma',
    instructor: 'KursusKilat',
    progress: 0.10,
    totalDuration: 'Materi teori',
    modulesTotal: 4,
    modulesDone: 1,
    rating: '-',
    status: CourseStatus.ongoing,
    accentStart: const Color(0xFF0D0D2A),
    accentEnd: const Color(0xFF0D0D1F),
    lastAccessed: '',
    totalStudents: '',
    description:
        'Cara data disusun, dicari, dibandingkan, dan diproses secara efisien.',
  ),
  KursusData(
    id: 3,
    emoji: '\u{1F4CA}',
    category: 'DATABASE',
    title: 'Basis Data',
    instructor: 'KursusKilat',
    progress: 1.0,
    totalDuration: 'Materi teori',
    modulesTotal: 4,
    modulesDone: 4,
    rating: '-',
    status: CourseStatus.completed,
    accentStart: const Color(0xFF1A0D2A),
    accentEnd: const Color(0xFF0D0D1F),
    lastAccessed: '',
    totalStudents: '',
    description:
        'Relasi data, kunci, normalisasi, transaksi, dan konsep penyimpanan informasi.',
  ),
  KursusData(
    id: 4,
    emoji: '\u{1F310}',
    category: 'NETWORKING',
    title: 'Jaringan Komputer',
    instructor: 'KursusKilat',
    progress: 0.0,
    totalDuration: 'Materi teori',
    modulesTotal: 4,
    modulesDone: 0,
    rating: '-',
    status: CourseStatus.notStarted,
    accentStart: const Color(0xFF2A0D0D),
    accentEnd: const Color(0xFF1F0D0D),
    lastAccessed: '',
    totalStudents: '',
    description:
        'Protokol, alamat jaringan, model komunikasi, dan keamanan dasar jaringan.',
  ),
  KursusData(
    id: 5,
    emoji: '\u{1F916}',
    category: 'AI & ML',
    title: 'Kecerdasan Buatan',
    instructor: 'KursusKilat',
    progress: 0.0,
    totalDuration: 'Materi teori',
    modulesTotal: 4,
    modulesDone: 0,
    rating: '-',
    status: CourseStatus.notStarted,
    accentStart: const Color(0xFF0D1A2A),
    accentEnd: const Color(0xFF0D1520),
    lastAccessed: '',
    totalStudents: '',
    description:
        'Konsep agen cerdas, pembelajaran mesin, data, model, dan evaluasi AI.',
  ),
];

// ── MATERI PAGE ───────────────────────────────────────────────────────────────
// [SYNC] Menerima initialModuleIndex & onModuleConsumed dari RootShell
class MateriPage extends StatefulWidget {
  final int? initialCourseId;
  final int? initialMaterialId;
  final int? initialCourseIndex;
  final int? initialModuleIndex;
  final VoidCallback? onModuleConsumed;

  const MateriPage({
    super.key,
    this.initialCourseId,
    this.initialMaterialId,
    this.initialCourseIndex,
    this.initialModuleIndex,
    this.onModuleConsumed,
  });

  @override
  State<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends State<MateriPage> with TickerProviderStateMixin {
  late AnimationController _glow;
  late Animation<double> _glowAnim;
  List<KursusData> _courses = buildCourses();
  bool _coursesSynced = false;
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  final _filters = [
    'Semua',
    'Programming',
    'Ilmu Komputer',
    'Database',
    'Networking',
    'AI & ML',
  ];
  int _fi = 0;
  String _q = '';
  bool _showSearch = false;
  bool _hasHandledDeepLink = false;

  @override
  void initState() {
    super.initState();
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(parent: _glow, curve: Curves.easeInOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenDeepLink());
  }

  void _openDeepLink() {
    var ci = (widget.initialCourseIndex ?? 0).clamp(0, _courses.length - 1);
    if (widget.initialCourseId != null) {
      final byId = _courses.indexWhere((c) => c.id == widget.initialCourseId);
      if (byId != -1) ci = byId;
    }

    final course = _courses[ci];
    var mi = widget.initialModuleIndex ?? 0;
    if (widget.initialMaterialId != null) {
      final modules = context.read<AppDataProvider>().modulesForCourse(course);
      final byId = modules.indexWhere((m) => m.id == widget.initialMaterialId);
      if (byId != -1) mi = byId;
    }

    _openWithModule(course, mi);
    widget.onModuleConsumed?.call();
  }

  bool get _hasPendingDeepLink =>
      widget.initialCourseId != null ||
      widget.initialMaterialId != null ||
      widget.initialModuleIndex != null;

  void _tryOpenDeepLink() {
    if (_hasHandledDeepLink || !_hasPendingDeepLink) return;

    final appData = context.read<AppDataProvider>();
    if (widget.initialMaterialId != null && !appData.isLoaded) return;

    if (appData.isLoaded && appData.courses.isNotEmpty && !_coursesSynced) {
      _courses = List<KursusData>.from(appData.courses);
      _coursesSynced = true;
    }

    _hasHandledDeepLink = true;
    _openDeepLink();
  }

  @override
  void didUpdateWidget(covariant MateriPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasPendingDeepLink &&
        (widget.initialModuleIndex != oldWidget.initialModuleIndex ||
            widget.initialCourseIndex != oldWidget.initialCourseIndex ||
            widget.initialCourseId != oldWidget.initialCourseId ||
            widget.initialMaterialId != oldWidget.initialMaterialId)) {
      _hasHandledDeepLink = false;
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenDeepLink());
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final appData = context.watch<AppDataProvider>();
    if (appData.isLoaded && !_coursesSynced && appData.courses.isNotEmpty) {
      _courses = List<KursusData>.from(appData.courses);
      _coursesSynced = true;
    }
    if (!_hasHandledDeepLink) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _tryOpenDeepLink());
    }
  }

  @override
  void dispose() {
    _glow.dispose();
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  List<KursusData> get _filtered => _courses.where((c) {
    if (_fi != 0 && c.category.toLowerCase() != _filters[_fi].toLowerCase()) {
      return false;
    }
    if (_q.isNotEmpty) {
      final q = _q.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          c.description.toLowerCase().contains(q);
    }
    return true;
  }).toList();

  void _openWithModule(KursusData c, int moduleIndex) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            ModuleDetailPage(course: c, initialModuleIndex: moduleIndex),
      ),
    ).then((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    });
  }

  void _open(KursusData c) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ModuleDetailPage(course: c),
      ),
    ).then((_) {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          // ── Ambient glow ──
          AnimatedBuilder(
            animation: _glowAnim,
            builder: (_, _) => Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.green.withValues(
                        alpha: t.isDark
                            ? (0.05 + 0.025 * _glowAnim.value)
                            : (0.08 + 0.035 * _glowAnim.value),
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: _GridDots(isDark: t.isDark)),
          SafeArea(
            child: Column(
              children: [
                // ── Header ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      Text(
                        'Materi',
                        style: TextStyle(
                          color: t.textPri,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showSearch = !_showSearch;
                            _q = '';
                            _ctrl.clear();
                          });
                          if (_showSearch) {
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              _focus.requestFocus,
                            );
                          }
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: t.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: t.divider),
                          ),
                          child: Icon(
                            _showSearch
                                ? Icons.close_rounded
                                : Icons.search_rounded,
                            color: t.textSec,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Search bar ──
                if (_showSearch)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.green.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search_rounded,
                            color: t.textMid,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _ctrl,
                              focusNode: _focus,
                              onChanged: (v) => setState(() => _q = v),
                              style: TextStyle(color: t.textPri, fontSize: 14),
                              cursorColor: AppTheme.green,
                              decoration: InputDecoration(
                                hintText: 'Cari materi...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(
                                  color: t.textMid,
                                  fontSize: 13,
                                ),
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_q.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() {
                                _q = '';
                                _ctrl.clear();
                              }),
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: t.textMid,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                // ── Filter chips ──
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _filters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final active = _fi == i;
                      return GestureDetector(
                        onTap: () => setState(() => _fi = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: active ? AppTheme.green : t.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: active ? AppTheme.green : t.divider,
                            ),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppTheme.green.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(
                            _filters[i],
                            style: TextStyle(
                              color: active ? t.bg : t.textMid,
                              fontSize: 13,
                              fontWeight: active
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // ── Course list ──
                Expanded(
                  child: _filtered.isEmpty
                      ? _empty(t)
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => _KursusCard(
                            data: _filtered[i],
                            onTap: () => _open(_filtered[i]),
                            onFavorite: () => setState(
                              () => _filtered[i].isFavorite =
                                  !_filtered[i].isFavorite,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _empty(AppTheme t) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: t.surface,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.green.withValues(alpha: 0.2)),
          ),
          child: const Center(
            child: Text('📚', style: TextStyle(fontSize: 32)),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Tidak ada materi',
          style: TextStyle(
            color: t.textPri,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Materi di kategori ini akan muncul di sini.',
          textAlign: TextAlign.center,
          style: TextStyle(color: t.textMid, fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _fi = 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.green.withValues(alpha: 0.3)),
            ),
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                color: AppTheme.green,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

// ── KURSUS CARD ───────────────────────────────────────────────────────────────
class _KursusCard extends StatefulWidget {
  final KursusData data;
  final VoidCallback onTap, onFavorite;
  const _KursusCard({
    required this.data,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  State<_KursusCard> createState() => _KursusCardState();
}

class _KursusCardState extends State<_KursusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final d = widget.data;
    final headerStart = t.isDark ? d.accentStart : _lightAccentStart(d.id);
    final headerEnd = t.isDark ? d.accentEnd : _lightAccentEnd(d.id);
    final headerTitle = t.isDark ? const Color(0xFFF0F0FA) : t.textPri;
    final headerDesc = t.isDark ? const Color(0xFF9999BB) : t.textSec;
    final iconPanel = t.isDark ? Colors.black26 : t.surface;
    final softOverlay = t.isDark
        ? Colors.white.withValues(alpha: 0.03)
        : AppTheme.green.withValues(alpha: 0.06);
    final favoriteBg = t.isDark
        ? Colors.black38
        : t.surface.withValues(alpha: 0.9);
    final favoriteColor = d.isFavorite
        ? AppTheme.green
        : (t.isDark ? Colors.white54 : t.textMid);

    return GestureDetector(
      onTapDown: (_) => _c.reverse(),
      onTapUp: (_) {
        _c.forward();
        widget.onTap();
      },
      onTapCancel: () => _c.forward(),
      child: ScaleTransition(
        scale: _c,
        child: Container(
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: t.divider),
            boxShadow: [
              BoxShadow(
                color: t.isDark
                    ? AppTheme.green.withValues(alpha: 0.05)
                    : t.shadow.withValues(alpha: 0.08),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              // ── Card header with gradient ──
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [headerStart, headerEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      bottom: -20,
                      right: -20,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: softOverlay,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: widget.onFavorite,
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: favoriteBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            d.isFavorite
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: favoriteColor,
                            size: 15,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: iconPanel,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: t.isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : t.divider,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                d.emoji,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.category,
                                  style: const TextStyle(
                                    color: AppTheme.green,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  d.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: headerTitle,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  d.description,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: headerDesc,
                                    fontSize: 11,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Card footer ──
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _chip(
                          t,
                          Icons.menu_book_rounded,
                          '${d.modulesTotal} materi',
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.green,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.green.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                color: t.bg,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Baca Materi',
                                style: TextStyle(
                                  color: t.bg,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip(
    AppTheme t,
    IconData icon,
    String label, {
    bool accent = false,
  }) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: accent ? AppTheme.green : t.textMid),
      const SizedBox(width: 3),
      Text(
        label,
        style: TextStyle(
          color: accent ? t.textSec : t.textMid,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );

  Color _lightAccentStart(int id) {
    switch (id) {
      case 1:
        return const Color(0xFFE9F8EF);
      case 2:
        return const Color(0xFFEDEBFF);
      case 3:
        return const Color(0xFFF2EAFE);
      case 4:
        return const Color(0xFFFFECE8);
      case 5:
        return const Color(0xFFE7F3FF);
      default:
        return const Color(0xFFEFF4F8);
    }
  }

  Color _lightAccentEnd(int id) {
    switch (id) {
      case 1:
        return const Color(0xFFFFFFFF);
      case 2:
        return const Color(0xFFFFFFFF);
      case 3:
        return const Color(0xFFFFFFFF);
      case 4:
        return const Color(0xFFFFF8F6);
      case 5:
        return const Color(0xFFFFFFFF);
      default:
        return const Color(0xFFFFFFFF);
    }
  }
}

// ── HELPERS ───────────────────────────────────────────────────────────────────
class _GridDots extends StatelessWidget {
  final bool isDark;
  const _GridDots({required this.isDark});

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _DotGridPainter(isDark: isDark));
}

class _DotGridPainter extends CustomPainter {
  final bool isDark;
  const _DotGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    final dotColor = isDark ? const Color(0xFF1E1E30) : const Color(0xFFD0D4E8);
    for (double x = 30; x < size.width; x += 30) {
      for (double y = 30; y < size.height; y += 30) {
        final f =
            math.max(
              (x / size.width - 0.5).abs(),
              (y / size.height - 0.5).abs(),
            ) *
            2;
        final op = (1.0 - f * 1.2).clamp(0.0, 1.0);
        if (op < 0.05) continue;
        canvas.drawCircle(
          Offset(x, y),
          1.0,
          p..color = dotColor.withValues(alpha: op),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.isDark != isDark;
}
