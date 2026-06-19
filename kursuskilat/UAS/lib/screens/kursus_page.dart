import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

const _bg = Color(0xFF070914);
const _surface = Color(0xFF151624);
const _surfaceB = Color(0xFF10111F);
const _divider = Color(0xFF2A2D40);
const _greenDk = Color(0xFF18B86C);
const _green = Color(0xFF2FDB7F);
const _greenGl = Color(0xFF58F0A4);
const _blue = Color(0xFF5B9DFF);
const _red = Color(0xFFFF5C7A);
const _orange = Color(0xFFFFB84D);
const _amber = Color(0xFFFFD166);
const _textPri = Color(0xFFF4F6FF);
const _textSec = Color(0xFFD4D8EA);
const _textMid = Color(0xFF8D91AA);

enum CourseStatus { ongoing, completed, notStarted }

class KursusData {
  final String category;
  final String title;
  final String instructor;
  final String description;
  final String emoji;
  final String totalDuration;
  final String rating;
  final String totalStudents;
  final int modulesTotal;
  final Color accentStart;
  final Color accentEnd;
  CourseStatus status;
  int modulesDone;
  double progress;
  String lastAccessed;
  bool isFavorite;
  bool isDownloaded;
  int userRating;
  final List<String> notes;

  KursusData({
    required this.category,
    required this.title,
    required this.instructor,
    required this.description,
    required this.emoji,
    required this.totalDuration,
    required this.rating,
    required this.totalStudents,
    required this.modulesTotal,
    required this.accentStart,
    required this.accentEnd,
    required this.status,
    required this.modulesDone,
    required this.progress,
    required this.lastAccessed,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.userRating = 0,
    List<String>? notes,
  }) : notes = notes ?? [];
}

const List<String> _moduleNames = [
  'Pengenalan Materi',
  'Konsep Dasar',
  'Struktur dan Alur Kerja',
  'Praktik Singkat',
  'Latihan Mandiri',
  'Studi Kasus',
  'Debugging dan Evaluasi',
  'Mini Project',
  'Review Materi',
  'Kuis Akhir',
  'Refleksi Belajar',
  'Persiapan Lanjutan',
];

const Map<String, List<Map<String, String>>> _moduleContent = {
  'Pengenalan Materi': [
    {'type': 'heading', 'content': 'Tujuan Modul'},
    {
      'type': 'text',
      'content':
          'Subtopik ini mengenalkan gambaran besar agar kamu paham konteks sebelum masuk ke praktik.',
    },
    {
      'type': 'bullet',
      'content': 'Kenali istilah penting yang sering muncul dalam materi.',
    },
    {
      'type': 'bullet',
      'content': 'Pahami kenapa topik ini berguna dalam dunia komputer.',
    },
    {
      'type': 'tip',
      'content':
          'Baca ringkasannya dulu, lalu coba hubungkan dengan soal level yang sedang kamu kerjakan.',
    },
  ],
  'Konsep Dasar': [
    {'type': 'heading', 'content': 'Konsep Inti'},
    {
      'type': 'text',
      'content':
          'Bagian ini membahas fondasi utama. Fokus pada definisi, fungsi, dan contoh sederhana.',
    },
    {'type': 'code', 'content': 'if (pahamKonsep) {\n  lanjutLatihan();\n}'},
  ],
  'Struktur dan Alur Kerja': [
    {'type': 'heading', 'content': 'Alur Kerja'},
    {
      'type': 'text',
      'content':
          'Setiap materi komputer biasanya punya urutan: input, proses, output, lalu evaluasi.',
    },
    {
      'type': 'bullet',
      'content':
          'Perhatikan hubungan antarbagian, bukan hanya hafalan istilah.',
    },
  ],
  'Praktik Singkat': [
    {'type': 'heading', 'content': 'Praktik'},
    {
      'type': 'text',
      'content':
          'Coba terapkan konsep dalam contoh kecil. Tujuannya bukan langsung sempurna, tapi memahami pola.',
    },
  ],
};

List<KursusData> _buildCourses() => [
  KursusData(
    category: 'PEMROGRAMAN',
    title: 'Dasar Logika Pemrograman',
    instructor: 'Materi pendukung Level 1',
    description:
        'Pahami cara komputer membaca instruksi melalui variabel, percabangan, perulangan, dan alur berpikir algoritmis.',
    emoji: '{}',
    totalDuration: '8 menit baca',
    rating: 'Pemula',
    totalStudents: 'Level 1',
    modulesTotal: 5,
    modulesDone: 5,
    progress: 1,
    status: CourseStatus.completed,
    lastAccessed: 'Selesai dibaca',
    accentStart: Color(0xFF123B24),
    accentEnd: Color(0xFF101624),
    isFavorite: true,
  ),
  KursusData(
    category: 'ALGORITMA',
    title: 'Algoritma dan Flowchart',
    instructor: 'Materi pendukung Level 2',
    description:
        'Kenali cara menyusun langkah penyelesaian masalah sebelum ditulis menjadi kode program.',
    emoji: 'ALG',
    totalDuration: '10 menit baca',
    rating: 'Pemula',
    totalStudents: 'Level 2',
    modulesTotal: 6,
    modulesDone: 3,
    progress: 3 / 6,
    status: CourseStatus.ongoing,
    lastAccessed: 'Sedang dibaca',
    accentStart: Color(0xFF17133D),
    accentEnd: Color(0xFF10111F),
  ),
  KursusData(
    category: 'DATABASE',
    title: 'Konsep Database Relasional',
    instructor: 'Materi pendukung Level 3',
    description:
        'Pelajari tabel, kolom, primary key, foreign key, relasi, dan alasan data perlu disusun rapi.',
    emoji: 'DB',
    totalDuration: '9 menit baca',
    rating: 'Dasar',
    totalStudents: 'Level 3',
    modulesTotal: 5,
    modulesDone: 5,
    progress: 1,
    status: CourseStatus.completed,
    lastAccessed: 'Selesai dibaca',
    accentStart: Color(0xFF1C285C),
    accentEnd: Color(0xFF111827),
  ),
  KursusData(
    category: 'JARINGAN',
    title: 'Dasar Jaringan Komputer',
    instructor: 'Materi pendukung Level 4',
    description:
        'Pahami IP address, client-server, paket data, DNS, dan cara perangkat saling terhubung.',
    emoji: 'NET',
    totalDuration: '12 menit baca',
    rating: 'Dasar',
    totalStudents: 'Level 4',
    modulesTotal: 6,
    modulesDone: 0,
    progress: 0,
    status: CourseStatus.notStarted,
    lastAccessed: 'Belum dibaca',
    accentStart: Color(0xFF3D3510),
    accentEnd: Color(0xFF151624),
  ),
  KursusData(
    category: 'WEB',
    title: 'HTML, CSS, dan JavaScript',
    instructor: 'Materi pendukung Level 5',
    description:
        'Ringkasan pondasi web: struktur halaman dengan HTML, tampilan dengan CSS, dan interaksi dengan JavaScript.',
    emoji: 'WEB',
    totalDuration: '11 menit baca',
    rating: 'Dasar',
    totalStudents: 'Level 5',
    modulesTotal: 6,
    modulesDone: 0,
    progress: 0,
    status: CourseStatus.notStarted,
    lastAccessed: 'Belum dibaca',
    accentStart: Color(0xFF132E42),
    accentEnd: Color(0xFF111827),
  ),
  KursusData(
    category: 'KEAMANAN',
    title: 'Keamanan Data dan Password',
    instructor: 'Materi pendukung Level 6',
    description:
        'Kenali enkripsi dasar, password kuat, phishing, autentikasi, dan kebiasaan aman saat memakai aplikasi.',
    emoji: 'SEC',
    totalDuration: '13 menit baca',
    rating: 'Menengah',
    totalStudents: 'Level 6',
    modulesTotal: 7,
    modulesDone: 0,
    progress: 0,
    status: CourseStatus.notStarted,
    lastAccessed: 'Belum dibaca',
    accentStart: Color(0xFF35184E),
    accentEnd: Color(0xFF10111F),
  ),
];

class KursusPage extends StatefulWidget {
  const KursusPage({super.key});

  @override
  State<KursusPage> createState() => _KursusPageState();
}

class _KursusPageState extends State<KursusPage> with TickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowPulse;
  final List<KursusData> _courses = _buildCourses();
  final List<String> _filters = const [
    'Semua',
    'Pemrograman',
    'Algoritma',
    'Database',
    'Jaringan',
    'Web',
    'Keamanan',
  ];
  final TextEditingController _searchCtrl = TextEditingController();
  int _selectedFilter = 0;
  String _searchQuery = '';
  OverlayEntry? _toastOverlay;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowPulse = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _toastOverlay?.remove();
    _searchCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  List<KursusData> get _filteredCourses {
    return _courses.where((c) {
      if (_selectedFilter != 0 &&
          c.category.toLowerCase() != _filters[_selectedFilter].toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return c.title.toLowerCase().contains(q) ||
            c.category.toLowerCase().contains(q) ||
            c.description.toLowerCase().contains(q) ||
            c.instructor.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  void _handleAction(KursusData course) {
    HapticFeedback.lightImpact();
    setState(() {
      if (course.status == CourseStatus.notStarted) {
        course.status = CourseStatus.ongoing;
        course.lastAccessed = 'Baru dibaca';
        course.modulesDone = 1;
        course.progress = 1 / course.modulesTotal;
      } else if (course.status == CourseStatus.ongoing) {
        course.lastAccessed = 'Baru saja dibaca';
        if (course.modulesDone < course.modulesTotal) {
          course.modulesDone++;
          course.progress = course.modulesDone / course.modulesTotal;
        }
        if (course.modulesDone >= course.modulesTotal) {
          course.status = CourseStatus.completed;
          course.lastAccessed = 'Selesai dibaca';
        }
      } else {
        course.lastAccessed = 'Dibaca ulang';
      }
    });
    _showToast(
      course.status == CourseStatus.completed
          ? 'Materi selesai dibaca'
          : 'Progress baca diperbarui',
    );
  }

  void _toggleFavorite(KursusData course) {
    HapticFeedback.selectionClick();
    setState(() => course.isFavorite = !course.isFavorite);
    _showToast(course.isFavorite ? 'Materi dibookmark' : 'Bookmark dihapus');
  }

  void _toggleDownload(KursusData course) {
    HapticFeedback.mediumImpact();
    setState(() => course.isDownloaded = !course.isDownloaded);
    _showToast(
      course.isDownloaded ? 'Materi disimpan offline' : 'Unduhan dihapus',
    );
  }

  void _resetCourse(KursusData course) {
    showDialog(
      context: context,
      builder: (_) => _ConfirmDialog(
        title: 'Reset Materi?',
        body: 'Progress baca materi ini akan direset ke awal.',
        confirm: 'Reset',
        onConfirm: () {
          HapticFeedback.heavyImpact();
          setState(() {
            course.status = CourseStatus.notStarted;
            course.modulesDone = 0;
            course.progress = 0;
            course.lastAccessed = 'Belum dibaca';
          });
          _showToast('Materi direset');
        },
      ),
    );
  }

  void _rateCourse(KursusData course) {
    showDialog(
      context: context,
      builder: (_) => _RateDialog(
        course: course,
        onRate: (stars) {
          setState(() => course.userRating = stars);
          _showToast('Penilaian disimpan');
        },
      ),
    );
  }

  void _addNote(KursusData course) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => _NoteDialog(
        ctrl: ctrl,
        onSave: (text) {
          if (text.trim().isEmpty) return;
          setState(() => course.notes.add(text.trim()));
          _showToast('Catatan disimpan');
        },
      ),
    );
  }

  void _showToast(String message) {
    _toastOverlay?.remove();
    _toastOverlay = OverlayEntry(
      builder: (_) => _ToastWidget(
        message: message,
        onDone: () {
          _toastOverlay?.remove();
          _toastOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_toastOverlay!);
  }

  void _openDetail(KursusData course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: false,
      backgroundColor: Colors.transparent,
      builder: (_) => _DetailSheet(
        course: course,
        onAction: _handleAction,
        onFavorite: _toggleFavorite,
        onDownload: _toggleDownload,
        onReset: _resetCourse,
        onRate: _rateCourse,
        onNote: _addNote,
        onUpdate: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _glowPulse,
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
                      _green.withValues(alpha: 0.05 + 0.025 * _glowPulse.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Positioned.fill(child: _GridDots()),
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildSearchBar(),
                _buildFilterChips(),
                Expanded(
                  child: _filteredCourses.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          physics: const BouncingScrollPhysics(),
                          itemCount: _filteredCourses.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 14),
                          itemBuilder: (_, i) => _KursusCard(
                            data: _filteredCourses[i],
                            onTap: () => _openDetail(_filteredCourses[i]),
                            onAction: () => _openDetail(_filteredCourses[i]),
                            onFavorite: () =>
                                _toggleFavorite(_filteredCourses[i]),
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

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Materi',
                style: TextStyle(
                  color: _textPri,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${_courses.length} materi komputer siap dibaca',
                style: const TextStyle(color: _textMid, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _divider),
          boxShadow: [
            BoxShadow(
              color: _green.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (value) => setState(() => _searchQuery = value.trim()),
          style: const TextStyle(color: _textPri, fontSize: 13),
          cursorColor: _green,
          decoration: InputDecoration(
            hintText: 'Cari materi: algoritma, database, jaringan...',
            hintStyle: const TextStyle(color: _textMid, fontSize: 12),
            border: InputBorder.none,
            prefixIcon: const Icon(
              Icons.search_rounded,
              color: _green,
              size: 20,
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : GestureDetector(
                    onTap: () {
                      _searchCtrl.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(
                      Icons.close_rounded,
                      color: _textMid,
                      size: 18,
                    ),
                  ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = _selectedFilter == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: active ? _green : _surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? _green : _divider),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: _green.withValues(alpha: 0.3),
                          blurRadius: 10,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  color: active ? _bg : _textMid,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _surface,
              shape: BoxShape.circle,
              border: Border.all(color: _green.withValues(alpha: 0.2)),
            ),
            child: const Center(
              child: Icon(Icons.menu_book_rounded, color: _green, size: 32),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Tidak ada materi',
            style: TextStyle(
              color: _textPri,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Coba ganti kata kunci atau\npilih kategori materi lain.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _textMid, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () {
              _searchCtrl.clear();
              setState(() {
                _selectedFilter = 0;
                _searchQuery = '';
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _green.withValues(alpha: 0.1),
                border: Border.all(color: _green.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  color: _green,
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
}

// --- MATERI CARD ??????????????????????????????????????????????????????????????
class _KursusCard extends StatefulWidget {
  final KursusData data;
  final VoidCallback onTap;
  final VoidCallback onAction;
  final VoidCallback onFavorite;
  const _KursusCard({
    required this.data,
    required this.onTap,
    required this.onAction,
    required this.onFavorite,
  });

  @override
  State<_KursusCard> createState() => _KursusCardState();
}

class _KursusCardState extends State<_KursusCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.96,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final pct = (d.progress * 100).round();
    final isDone = d.status == CourseStatus.completed;
    final isNew = d.status == CourseStatus.notStarted;

    return GestureDetector(
      onTapDown: (_) => _ctrl.reverse(),
      onTapUp: (_) {
        _ctrl.forward();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.forward(),
      child: ScaleTransition(
        scale: _ctrl,
        child: Container(
          decoration: BoxDecoration(
            color: _surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _divider),
            boxShadow: [
              BoxShadow(
                color: (isDone ? _blue : _green).withValues(alpha: 0.05),
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 112,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [d.accentStart, d.accentEnd],
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
                          color: Colors.white.withValues(alpha: 0.03),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -10,
                      left: -10,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.02),
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
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            d.isFavorite
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: d.isFavorite ? _green : _textMid,
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
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.08),
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
                                    color: _green,
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
                                  style: const TextStyle(
                                    color: _textPri,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  d.instructor,
                                  style: const TextStyle(
                                    color: _textMid,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _StatusBadge(status: d.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip(
                          icon: Icons.access_time_rounded,
                          label: d.totalDuration,
                        ),
                        _MetaChip(
                          icon: Icons.topic_rounded,
                          label: '${d.modulesTotal} subtopik',
                        ),
                        _MetaChip(
                          icon: Icons.extension_rounded,
                          label: d.rating,
                          isAccent: true,
                        ),
                        _MetaChip(
                          icon: Icons.sports_esports_rounded,
                          label: d.totalStudents,
                        ),
                        if (d.isDownloaded)
                          const _MetaChip(
                            icon: Icons.download_done_rounded,
                            label: 'Tersimpan',
                            isAccent: true,
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      d.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _textMid,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    isNew
                                        ? 'Belum dibaca'
                                        : 'Progress baca $pct%',
                                    style: TextStyle(
                                      color: isNew
                                          ? _textMid
                                          : isDone
                                          ? _blue
                                          : _green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (isDone) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      Icons.check_circle_rounded,
                                      color: _blue,
                                      size: 13,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 6),
                              Stack(
                                children: [
                                  Container(
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: _divider,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  if (!isNew)
                                    AnimatedFractionallySizedBox(
                                      duration: const Duration(
                                        milliseconds: 400,
                                      ),
                                      curve: Curves.easeOut,
                                      widthFactor: d.progress,
                                      child: Container(
                                        height: 5,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isDone
                                                ? [
                                                    _blue,
                                                    const Color(0xFF7EC8FF),
                                                  ]
                                                : [_greenDk, _green, _greenGl],
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: (isDone ? _blue : _green)
                                                  .withValues(alpha: 0.5),
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: widget.onAction,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              color: isDone
                                  ? _blue.withValues(alpha: 0.12)
                                  : isNew
                                  ? _green.withValues(alpha: 0.1)
                                  : _green,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isDone
                                    ? _blue.withValues(alpha: 0.3)
                                    : isNew
                                    ? _green.withValues(alpha: 0.3)
                                    : Colors.transparent,
                              ),
                              boxShadow: (!isDone && !isNew)
                                  ? [
                                      BoxShadow(
                                        color: _green.withValues(alpha: 0.35),
                                        blurRadius: 10,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isDone
                                      ? Icons.replay_rounded
                                      : Icons.menu_book_rounded,
                                  color: isDone
                                      ? _blue
                                      : isNew
                                      ? _green
                                      : _bg,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isDone
                                      ? 'Baca Lagi'
                                      : isNew
                                      ? 'Baca'
                                      : 'Lanjut',
                                  style: TextStyle(
                                    color: isDone
                                        ? _blue
                                        : isNew
                                        ? _green
                                        : _bg,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ??? DETAIL BOTTOM SHEET ??????????????????????????????????????????????????????
class _DetailSheet extends StatefulWidget {
  final KursusData course;
  final void Function(KursusData) onAction;
  final void Function(KursusData) onFavorite;
  final void Function(KursusData) onDownload;
  final void Function(KursusData) onReset;
  final void Function(KursusData) onRate;
  final void Function(KursusData) onNote;
  final VoidCallback onUpdate;

  const _DetailSheet({
    required this.course,
    required this.onAction,
    required this.onFavorite,
    required this.onDownload,
    required this.onReset,
    required this.onRate,
    required this.onNote,
    required this.onUpdate,
  });

  @override
  State<_DetailSheet> createState() => _DetailSheetState();
}

class _DetailSheetState extends State<_DetailSheet> {
  KursusData get c => widget.course;

  void _act(VoidCallback fn) {
    fn();
    if (mounted) setState(() {});
    widget.onUpdate();
  }

  @override
  Widget build(BuildContext context) {
    final isDone = c.status == CourseStatus.completed;
    final isNew = c.status == CourseStatus.notStarted;
    final pct = (c.progress * 100).round();
    final mods = _moduleNames.take(c.modulesTotal).toList();

    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 1,
      maxChildSize: 1,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(color: _surface),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: ListView(
                  controller: scrollCtrl,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    // Hero
                    Stack(
                      children: [
                        Container(
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [c.accentStart, c.accentEnd],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: _textSec,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => _act(() => widget.onFavorite(c)),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                c.isFavorite
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                color: c.isFavorite ? _green : _textSec,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          child: Row(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    c.emoji,
                                    style: const TextStyle(fontSize: 32),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      c.category,
                                      style: const TextStyle(
                                        color: _green,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c.title,
                                      style: const TextStyle(
                                        color: _textPri,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.4,
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      c.instructor,
                                      style: const TextStyle(
                                        color: _textMid,
                                        fontSize: 12,
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

                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick actions
                          Row(
                            children: [
                              _QuickActionBtn(
                                icon: c.isFavorite
                                    ? Icons.bookmark_rounded
                                    : Icons.bookmark_border_rounded,
                                label: c.isFavorite ? 'Disimpan' : 'Bookmark',
                                color: c.isFavorite ? _green : _textSec,
                                onTap: () => _act(() => widget.onFavorite(c)),
                              ),
                              const SizedBox(width: 10),
                              _QuickActionBtn(
                                icon: c.isDownloaded
                                    ? Icons.download_done_rounded
                                    : Icons.download_rounded,
                                label: c.isDownloaded ? 'Offline' : 'Simpan',
                                color: c.isDownloaded ? _green : _textSec,
                                onTap: () => _act(() => widget.onDownload(c)),
                              ),
                              const SizedBox(width: 10),
                              _QuickActionBtn(
                                icon: Icons.star_rounded,
                                label: c.userRating > 0
                                    ? '${c.userRating}/5'
                                    : 'Tandai',
                                color: c.userRating > 0 ? _orange : _textSec,
                                onTap: () => widget.onRate(c),
                              ),
                              const SizedBox(width: 10),
                              _QuickActionBtn(
                                icon: Icons.note_add_rounded,
                                label: 'Catatan',
                                color: _textSec,
                                onTap: () => widget.onNote(c),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Stat grid
                          Row(
                            children: [
                              _StatBox(
                                icon: '?',
                                label: 'Durasi',
                                value: c.totalDuration,
                              ),
                              const SizedBox(width: 10),
                              _StatBox(
                                icon: '??',
                                label: 'Subtopik',
                                value: '${c.modulesTotal}',
                              ),
                              const SizedBox(width: 10),
                              _StatBox(
                                icon: '?',
                                label: 'Tingkat',
                                value: c.rating,
                              ),
                              const SizedBox(width: 10),
                              _StatBox(
                                icon: '??',
                                label: 'Level',
                                value: c.totalStudents,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          _SectionBox(
                            title: 'TENTANG MATERI',
                            child: Text(
                              c.description,
                              style: const TextStyle(
                                color: _textMid,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          if (c.notes.isNotEmpty) ...[
                            _SectionBox(
                              title: 'CATATAN SAYA',
                              trailing: GestureDetector(
                                onTap: () => widget.onNote(c),
                                child: const Text(
                                  '+ Tambah',
                                  style: TextStyle(
                                    color: _green,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              child: Column(
                                children: c.notes
                                    .asMap()
                                    .entries
                                    .map(
                                      (e) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              '?  ',
                                              style: TextStyle(
                                                color: _green,
                                                fontSize: 13,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                e.value,
                                                style: const TextStyle(
                                                  color: _textSec,
                                                  fontSize: 12,
                                                  height: 1.5,
                                                ),
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                setState(
                                                  () => c.notes.removeAt(e.key),
                                                );
                                                widget.onUpdate();
                                              },
                                              child: const Icon(
                                                Icons.close_rounded,
                                                color: _textMid,
                                                size: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          _SectionBox(
                            title: 'PROGRESS',
                            trailing: Text(
                              '$pct%',
                              style: TextStyle(
                                color: isNew
                                    ? _textMid
                                    : isDone
                                    ? _blue
                                    : _green,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      height: 6,
                                      decoration: BoxDecoration(
                                        color: _divider,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    if (!isNew)
                                      AnimatedFractionallySizedBox(
                                        duration: const Duration(
                                          milliseconds: 500,
                                        ),
                                        curve: Curves.easeOut,
                                        widthFactor: c.progress,
                                        child: Container(
                                          height: 6,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: isDone
                                                  ? [
                                                      _blue,
                                                      const Color(0xFF7EC8FF),
                                                    ]
                                                  : [
                                                      _greenDk,
                                                      _green,
                                                      _greenGl,
                                                    ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: (isDone ? _blue : _green)
                                                    .withValues(alpha: 0.5),
                                                blurRadius: 6,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${c.modulesDone} dari ${c.modulesTotal} subtopik dibaca',
                                  style: const TextStyle(
                                    color: _textMid,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              const Text(
                                'DAFTAR SUBTOPIK',
                                style: TextStyle(
                                  color: _textSec,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const Spacer(),
                              if (!isDone && !isNew)
                                GestureDetector(
                                  onTap: () => _act(() => widget.onAction(c)),
                                  child: const Text(
                                    '+ Tandai Subtopik',
                                    style: TextStyle(
                                      color: _green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          ...mods.asMap().entries.map((e) {
                            final i = e.key;
                            final mod = e.value;
                            final done = i < c.modulesDone;
                            final active = i == c.modulesDone && !isDone;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => _ModuleDetailSheet(
                                      moduleName: mod,
                                      moduleNumber: i + 1,
                                      isDone: done,
                                      isActive: active,
                                      onComplete: active
                                          ? () => _act(() => widget.onAction(c))
                                          : null,
                                    ),
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: active
                                        ? _green.withValues(alpha: 0.06)
                                        : _surfaceB,
                                    border: Border.all(
                                      color: active
                                          ? _green.withValues(alpha: 0.3)
                                          : _divider,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: done
                                              ? _green
                                              : active
                                              ? _green.withValues(alpha: 0.15)
                                              : _divider,
                                        ),
                                        child: Center(
                                          child: done
                                              ? const Icon(
                                                  Icons.check_rounded,
                                                  color: _bg,
                                                  size: 13,
                                                )
                                              : Text(
                                                  '${i + 1}',
                                                  style: TextStyle(
                                                    color: active
                                                        ? _green
                                                        : _textMid,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          mod,
                                          style: TextStyle(
                                            color: done
                                                ? _textSec
                                                : active
                                                ? _textPri
                                                : _textMid,
                                            fontSize: 13,
                                            fontWeight: active
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (active)
                                        const Text(
                                          'BACA',
                                          style: TextStyle(
                                            color: _green,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      if (done)
                                        const Text(
                                          'Selesai',
                                          style: TextStyle(
                                            color: _textMid,
                                            fontSize: 10,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 20),

                          // Main action
                          GestureDetector(
                            onTap: () {
                              _act(() => widget.onAction(c));
                              Navigator.pop(context);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              decoration: BoxDecoration(
                                gradient: isDone
                                    ? null
                                    : const LinearGradient(
                                        colors: [_greenDk, _green, _greenGl],
                                      ),
                                color: isDone
                                    ? _blue.withValues(alpha: 0.12)
                                    : null,
                                border: Border.all(
                                  color: isDone
                                      ? _blue.withValues(alpha: 0.3)
                                      : Colors.transparent,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: isDone
                                    ? null
                                    : [
                                        BoxShadow(
                                          color: _green.withValues(alpha: 0.35),
                                          blurRadius: 16,
                                        ),
                                      ],
                              ),
                              child: Center(
                                child: Text(
                                  isDone
                                      ? 'Baca Ulang'
                                      : isNew
                                      ? 'Mulai Baca'
                                      : 'Lanjut Baca',
                                  style: TextStyle(
                                    color: isDone ? _blue : _bg,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Reset
                          const SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () => widget.onReset(c),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                border: Border.all(
                                  color: _red.withValues(alpha: 0.2),
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restart_alt_rounded,
                                    color: _red.withValues(alpha: 0.7),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Reset Progress',
                                    style: TextStyle(
                                      color: _red.withValues(alpha: 0.7),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
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
}

// ??? MODULE DETAIL SHEET ??????????????????????????????????????????????????????
class _ModuleDetailSheet extends StatelessWidget {
  final String moduleName;
  final int moduleNumber;
  final bool isDone;
  final bool isActive;
  final VoidCallback? onComplete;

  const _ModuleDetailSheet({
    required this.moduleName,
    required this.moduleNumber,
    required this.isDone,
    required this.isActive,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    // FIX 2 (continued): Now accesses top-level _moduleContent correctly
    final content =
        _moduleContent[moduleName] ??
        [
          {'type': 'text', 'content': 'Konten subtopik ini sedang disiapkan.'},
        ];

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (_, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 4),

            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: _divider)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: isDone
                          ? const LinearGradient(
                              colors: [Color(0xFF4E9DFF), Color(0xFF7EC8FF)],
                            )
                          : isActive
                          ? const LinearGradient(colors: [_greenDk, _green])
                          : null,
                      color: isDone || isActive ? null : _surfaceB,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDone
                            ? _blue.withValues(alpha: 0.4)
                            : isActive
                            ? _green.withValues(alpha: 0.4)
                            : _divider,
                      ),
                    ),
                    child: Center(
                      child: isDone
                          ? const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 18,
                            )
                          : Text(
                              '$moduleNumber',
                              style: TextStyle(
                                color: isActive ? _bg : _textMid,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Subtopik $moduleNumber',
                          style: const TextStyle(
                            color: _textMid,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          moduleName,
                          style: const TextStyle(
                            color: _textPri,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _surfaceB,
                        shape: BoxShape.circle,
                        border: Border.all(color: _divider),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: _textSec,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (isDone || isActive)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                color: (isDone ? _blue : _green).withValues(alpha: 0.06),
                child: Row(
                  children: [
                    Icon(
                      isDone
                          ? Icons.check_circle_rounded
                          : Icons.play_circle_rounded,
                      color: isDone ? _blue : _green,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isDone
                          ? 'Subtopik ini sudah kamu selesaikan'
                          : 'Subtopik aktif untuk dibaca',
                      style: TextStyle(
                        color: isDone ? _blue : _green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: ListView.builder(
                controller: scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                itemCount: content.length + 1,
                itemBuilder: (_, i) {
                  if (i == content.length) {
                    if (!isActive && !isDone) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: isDone
                          ? Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: _blue.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _blue.withValues(alpha: 0.25),
                                ),
                              ),
                              child: const Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_rounded,
                                      color: _blue,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Subtopik Selesai',
                                      style: TextStyle(
                                        color: _blue,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                onComplete?.call();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [_greenDk, _green, _greenGl],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _green.withValues(alpha: 0.35),
                                      blurRadius: 16,
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Text(
                                    '?  Tandai Selesai',
                                    style: TextStyle(
                                      color: _bg,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    );
                  }

                  final item = content[i];
                  final type = item['type'] ?? 'text';
                  final text = item['content'] ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: switch (type) {
                      'heading' => Text(
                        text,
                        style: const TextStyle(
                          color: _textPri,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      'bullet' => Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 7),
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: _green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              text,
                              style: const TextStyle(
                                color: _textSec,
                                fontSize: 13,
                                height: 1.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      'code' => Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D0D18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _green.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'CODE',
                                style: TextStyle(
                                  color: _green,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              text,
                              style: const TextStyle(
                                color: _amber, // FIX 1: now resolves correctly
                                fontSize: 12,
                                fontFamily: 'monospace',
                                height: 1.7,
                              ),
                            ),
                          ],
                        ),
                      ),
                      'tip' => Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: _green.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _green.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _green.withValues(alpha: 0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Text(
                          text,
                          style: const TextStyle(
                            color: _textSec,
                            fontSize: 13,
                            height: 1.6,
                          ),
                        ),
                      ),
                      _ => Text(
                        text,
                        style: const TextStyle(
                          color: _textMid,
                          fontSize: 13,
                          height: 1.7,
                        ),
                      ),
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ??? CONFIRM DIALOG ??????????????????????????????????????????????????????????
class _ConfirmDialog extends StatelessWidget {
  final String title, body, confirm;
  final VoidCallback onConfirm;
  const _ConfirmDialog({
    required this.title,
    required this.body,
    required this.confirm,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _textPri,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _textMid,
                fontSize: 13,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _surfaceB,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _divider),
                      ),
                      child: const Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: _textSec,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onConfirm();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _red.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _red.withValues(alpha: 0.3)),
                      ),
                      child: Center(
                        child: Text(
                          confirm,
                          style: const TextStyle(
                            color: _red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ??? RATE DIALOG ?????????????????????????????????????????????????????????????
class _RateDialog extends StatefulWidget {
  final KursusData course;
  final void Function(int stars) onRate;
  const _RateDialog({required this.course, required this.onRate});

  @override
  State<_RateDialog> createState() => _RateDialogState();
}

class _RateDialogState extends State<_RateDialog> {
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _selected = widget.course.userRating;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Beri Penilaian',
              style: TextStyle(
                color: _textPri,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.course.title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: _textMid, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final filled = i < _selected;
                return GestureDetector(
                  onTap: () => setState(() => _selected = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_border_rounded,
                      color: filled ? _orange : _textMid,
                      size: 36,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _selected == 0
                  ? 'Pilih bintang'
                  : _selected == 1
                  ? 'Kurang ??'
                  : _selected == 2
                  ? 'Cukup ??'
                  : _selected == 3
                  ? 'Baik ??'
                  : _selected == 4
                  ? 'Sangat Baik ??'
                  : 'Luar Biasa! ??',
              style: TextStyle(
                color: _selected > 0 ? _orange : _textMid,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _surfaceB,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _divider),
                      ),
                      child: const Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: _textSec,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: _selected == 0
                        ? null
                        : () {
                            Navigator.pop(context);
                            widget.onRate(_selected);
                          },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _selected > 0
                            ? _orange.withValues(alpha: 0.12)
                            : _divider,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selected > 0
                              ? _orange.withValues(alpha: 0.4)
                              : Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Kirim',
                          style: TextStyle(
                            color: _selected > 0 ? _orange : _textMid,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ??? NOTE DIALOG ?????????????????????????????????????????????????????????????
class _NoteDialog extends StatelessWidget {
  final TextEditingController ctrl;
  final void Function(String) onSave;
  const _NoteDialog({required this.ctrl, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _divider),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Tambah Catatan',
              style: TextStyle(
                color: _textPri,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: _surfaceB,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _green.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: ctrl,
                style: const TextStyle(color: _textPri, fontSize: 14),
                cursorColor: _green,
                maxLines: 4,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Tulis catatan belajarmu...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: _textMid, fontSize: 13),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _surfaceB,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _divider),
                      ),
                      child: const Center(
                        child: Text(
                          'Batal',
                          style: TextStyle(
                            color: _textSec,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onSave(ctrl.text);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [_greenDk, _green],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: _green.withValues(alpha: 0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Simpan',
                          style: TextStyle(
                            color: _bg,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ??? QUICK ACTION BTN ?????????????????????????????????????????????????????????
class _QuickActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: _surfaceB,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _divider),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 5),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ??? SMALL WIDGETS ????????????????????????????????????????????????????????????
class _StatBox extends StatelessWidget {
  final String icon, label, value;
  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: _surfaceB,
        border: Border.all(color: _divider),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: _textPri,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(label, style: const TextStyle(color: _textMid, fontSize: 9)),
        ],
      ),
    ),
  );
}

class _SectionBox extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;
  const _SectionBox({required this.title, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _surfaceB,
      border: Border.all(color: _divider),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                color: _textSec,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
            const Spacer(),
            ?trailing,
          ],
        ),
        const SizedBox(height: 10),
        child,
      ],
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final CourseStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color, icon) = switch (status) {
      CourseStatus.ongoing => ('Dibaca', _green, Icons.auto_stories_rounded),
      CourseStatus.completed => ('Selesai', _blue, Icons.check_rounded),
      CourseStatus.notStarted => ('Baru', _textMid, Icons.bookmark_add_rounded),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 10),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isAccent;
  const _MetaChip({
    required this.icon,
    required this.label,
    this.isAccent = false,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: isAccent ? _green : _textMid),
      const SizedBox(width: 3),
      Text(
        label,
        style: TextStyle(
          color: isAccent ? _textSec : _textMid,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}

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
        final fx = (x / size.width - 0.5).abs() * 2;
        final fy = (y / size.height - 0.5).abs() * 2;
        final f = math.max(fx, fy);
        final op = (1.0 - f * 1.2).clamp(0.0, 1.0);
        if (op < 0.05) continue;
        canvas.drawCircle(
          Offset(x, y),
          r,
          paint..color = const Color(0xFF1E1E30).withValues(alpha: op),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// ??? TOAST ????????????????????????????????????????????????????????????????????
class _ToastWidget extends StatefulWidget {
  final String message;
  final VoidCallback onDone;
  const _ToastWidget({required this.message, required this.onDone});

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Positioned(
    bottom: 32,
    left: 0,
    right: 0,
    child: AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, 20 * (1 - _anim.value)),
        child: Opacity(opacity: _anim.value, child: child),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(color: _green.withValues(alpha: 0.4), blurRadius: 16),
            ],
          ),
          child: Text(
            widget.message,
            style: const TextStyle(
              color: _bg,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
          ),
        ),
      ),
    ),
  );
}
