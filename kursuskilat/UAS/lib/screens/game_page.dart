import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/models/level_data.dart';
import 'package:kursuskilat/providers/app_data_provider.dart';
import 'app_theme.dart';
import 'materi_page.dart' as materi;
import 'profil_page.dart' as profil;
import 'leaderboard_page.dart' as leaderboard;
import 'package:kursuskilat/screens/ai_assistant_overlay.dart';
import 'quiz_page.dart';

// ── WARNA AKSEN LIGHT (dark memakai AppTheme.iris / AppTheme.green) ──────────
const kBlue = Color(0xFF4E9DFF);
const kIris = Color(0xFF7B9FFF);
const kPurple = Color(0xFF8D5CFF);

// ── ROOT SHELL ────────────────────────────────────────────────────────────────
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _currentIndex = 0;
  int? _pendingCourseId;
  int? _pendingMaterialId;
  int? _pendingCourseIndex;
  int? _pendingModuleIndex;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppDataProvider>().load();
    });
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF13131F),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  void openMaterialForLevel(
    int courseIndex,
    int materialIndex, {
    int? courseId,
    int? materialId,
  }) {
    setState(() {
      _currentIndex = 1;
      _pendingCourseId = courseId;
      _pendingMaterialId = materialId;
      _pendingCourseIndex = courseIndex;
      _pendingModuleIndex = materialIndex;
    });
  }

  void clearPendingModule() {
    setState(() {
      _pendingCourseId = null;
      _pendingMaterialId = null;
      _pendingCourseIndex = null;
      _pendingModuleIndex = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AiAssistantWrapper(
      child: Scaffold(
        backgroundColor: context.watch<AppTheme>().bg,
        body: IndexedStack(
          index: _currentIndex,
          children: [
            const GamePage(),
            MateriPage(
              key: ValueKey(
                '$_pendingCourseId-$_pendingMaterialId-$_pendingCourseIndex-$_pendingModuleIndex',
              ),
              initialCourseId: _pendingCourseId,
              initialMaterialId: _pendingMaterialId,
              initialCourseIndex: _pendingCourseIndex,
              initialModuleIndex: _pendingModuleIndex,
              onModuleConsumed: clearPendingModule,
            ),
            const LeaderboardPage(),
            const ProfilePage(),
          ],
        ),
        bottomNavigationBar: _BottomNav(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
        ),
      ),
    );
  }
}

// ── BOTTOM NAV ────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.divider, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.gamepad,
                label: 'Game',
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
  final int index, current;
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
    final t = context.watch<AppTheme>();
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
                color: active
                    ? AppTheme.green.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                size: 22,
                color: active ? AppTheme.green : t.textMid,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppTheme.green : t.textMid,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GAME PAGE ─────────────────────────────────────────────────────────────────
class GamePage extends StatelessWidget {
  const GamePage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final levels = context.watch<AppDataProvider>().levels;
    final activeLevel = levels.firstWhere(
      (l) => l.status == LevelStatus.aktif,
      orElse: () => levels.first,
    );

    return Scaffold(
      backgroundColor: t.bg,
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
                SliverToBoxAdapter(
                  child: _LevelMap(
                    levels: levels,
                    onLevelTap: (level) => _onLevelTap(context, level),
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

  void _onLevelTap(BuildContext context, LevelData data) {
    final t = context.read<AppTheme>();
    if (data.status == LevelStatus.selesai) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_outline, color: t.textPri, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Level ini sudah selesai.',
                    style: TextStyle(fontSize: 13, color: t.textPri),
                  ),
                ),
              ],
            ),
            backgroundColor: t.surfaceB,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }
    if (data.status == LevelStatus.terkunci) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.lock_rounded, color: t.textPri, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Level ${data.id} masih terkunci. Selesaikan level sebelumnya dulu!',
                    style: TextStyle(fontSize: 13, color: t.textPri),
                  ),
                ),
              ],
            ),
            backgroundColor: t.surfaceB,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            duration: const Duration(seconds: 2),
          ),
        );
      return;
    }

    final rootState = context.findAncestorStateOfType<_RootShellState>();

    showDialog(
      context: context,
      builder: (_) => _LevelStartDialog(
        data: data,
        onReadMaterial: () {
          Navigator.pop(context);
          rootState?.openMaterialForLevel(
            data.courseIndex,
            data.materialIndex,
            courseId: data.courseId,
            materialId: data.materialId,
          );
        },
        onStartQuiz: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => LevelQuizPage(level: data)),
          );
        },
      ),
    );
  }
}

// ── LEVEL START DIALOG ────────────────────────────────────────────────────────
class _LevelStartDialog extends StatelessWidget {
  final LevelData data;
  final VoidCallback onReadMaterial;
  final VoidCallback onStartQuiz;

  static const _moduleEmojis = ['🖥️', '🔢', '💻', '🌐', '🔐'];

  const _LevelStartDialog({
    required this.data,
    required this.onReadMaterial,
    required this.onStartQuiz,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final emoji = _moduleEmojis[data.moduleIndex % _moduleEmojis.length];
    final statusColor = levelStatusColor(data.status, isDark: t.isDark);
    final sec = t.secondary;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.surfaceB,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sec.withValues(alpha: 0.25)),
          boxShadow: [
            BoxShadow(color: sec.withValues(alpha: 0.1), blurRadius: 30),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: t.isDark
                    ? (data.status == LevelStatus.selesai
                        ? AppTheme.green
                        : AppTheme.iris)
                    : null,
                gradient: t.isDark
                    ? null
                    : LinearGradient(
                        colors: data.status == LevelStatus.selesai
                            ? const [
                                AppTheme.greenDk,
                                AppTheme.green,
                                AppTheme.greenGl,
                              ]
                            : const [kBlue, kIris, kPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.35),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '${data.id}',
                  style: TextStyle(
                    color: t.bg,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Level ${data.id} | ${data.title}',
              style: TextStyle(
                color: t.textPri,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$emoji ${data.topic}',
              style: TextStyle(
                color: sec,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Container(width: double.infinity, height: 1, color: t.divider),
            const SizedBox(height: 16),

            // Baca Materi
            GestureDetector(
              onTap: onReadMaterial,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
                decoration: BoxDecoration(
                  color: sec.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: sec.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu_book_rounded, color: sec, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Baca Materi Dulu',
                      style: TextStyle(
                        color: sec,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Langsung Kerjain
            GestureDetector(
              onTap: onStartQuiz,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 13),
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
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.green.withValues(alpha: 0.35),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: t.bg, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Langsung Kerjain!',
                      style: TextStyle(
                        color: t.bg,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  'Batal',
                  style: TextStyle(
                    color: t.textMid,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

// ── HOME HEADER ───────────────────────────────────────────────────────────────
class _HomeHeader extends StatelessWidget {
  final LevelData activeLevel;
  const _HomeHeader({required this.activeLevel});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppTheme.green.withValues(alpha: 0.35),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.green.withValues(alpha: 0.16),
                  blurRadius: 18,
                ),
              ],
            ),
            child: const Icon(
              Icons.bolt_rounded,
              color: AppTheme.green,
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KursusKilat',
                  style: TextStyle(
                    color: t.textPri,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Peta Belajar',
                  style: TextStyle(
                    color: t.textMid,
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
              color: t.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: t.secondary.withValues(alpha: 0.28)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_rounded, size: 15, color: t.secondary),
                const SizedBox(width: 6),
                Text(
                  'Level ${activeLevel.id}',
                  style: TextStyle(
                    color: t.secondary,
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

// ── LEVEL LEGEND ──────────────────────────────────────────────────────────────
// ── LEVEL MAP ─────────────────────────────────────────────────────────────────
class _LevelMap extends StatelessWidget {
  final List<LevelData> levels;
  final ValueChanged<LevelData> onLevelTap;

  const _LevelMap({required this.levels, required this.onLevelTap});

  static const double _slotWidth = 132;
  static const double _nodeSize = 76;
  static const double _rowHeight = 120;
  static const double _topPadding = 14;
  static const double _botPadding = 34;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final height =
              _topPadding +
              _botPadding +
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
                      dividerColor: t.divider,
                      activeSegmentColor: t.secondary,
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

// ── LEVEL NODE ────────────────────────────────────────────────────────────────
class _LevelNode extends StatelessWidget {
  final LevelData data;
  final double nodeSize;
  final VoidCallback onTap;

  const _LevelNode({
    required this.data,
    required this.nodeSize,
    required this.onTap,
  });

  static const _moduleEmojis = ['🖥️', '🔢', '💻', '🌐', '🔐'];

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final locked = data.status == LevelStatus.terkunci;
    final active = data.status == LevelStatus.aktif;
    final complete = data.status == LevelStatus.selesai;
    final statusColor = levelStatusColor(data.status, isDark: t.isDark);
    final sec = t.secondary;
    final mEmoji = _moduleEmojis[data.moduleIndex % _moduleEmojis.length];

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
              color: locked
                  ? t.surfaceB
                  : (t.isDark
                      ? (complete ? AppTheme.green : AppTheme.iris)
                      : null),
              gradient: locked || t.isDark
                  ? null
                  : LinearGradient(
                      colors: complete
                          ? const [
                              AppTheme.greenDk,
                              AppTheme.green,
                              AppTheme.greenGl,
                            ]
                          : const [kBlue, kIris, kPurple],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: Border.all(
                color: locked ? t.divider : statusColor.withValues(alpha: 0.7),
                width: active ? 2.5 : 2,
              ),
              boxShadow: locked
                  ? null
                  : [
                      BoxShadow(
                        color: statusColor.withValues(
                          alpha: active ? 0.35 : 0.22,
                        ),
                        blurRadius: active ? 26 : 18,
                        spreadRadius: active ? 2 : 0,
                      ),
                    ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (locked)
                  Icon(Icons.lock_rounded, color: t.textMid, size: 28)
                else
                  Text(
                    '${data.id}',
                    style: TextStyle(
                      color: t.bg,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
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
            'Level ${data.id}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: locked ? t.textMid : t.textPri,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            data.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: locked ? t.textMid : statusColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$mEmoji ${data.topic}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: locked ? t.textMid : sec,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
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

// ── STATUS BADGE & STARS ──────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final LevelStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    final icon = levelStatusIcon(status);
    final color = levelStatusColor(status, isDark: t.isDark);
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: status == LevelStatus.terkunci ? t.surface : t.bg,
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
    final t = context.watch<AppTheme>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            child: Icon(
              Icons.star_rounded,
              size: 13,
              color: i < count ? AppTheme.green : t.divider,
            ),
          ),
      ],
    );
  }
}

// ── LEVEL PATH PAINTER ────────────────────────────────────────────────────────
class _LevelPathPainter extends CustomPainter {
  final List<LevelData> levels;
  final double width, slotWidth, nodeSize, rowHeight, topPadding;
  final Color dividerColor;
  final Color activeSegmentColor;

  const _LevelPathPainter({
    required this.levels,
    required this.width,
    required this.slotWidth,
    required this.nodeSize,
    required this.rowHeight,
    required this.topPadding,
    required this.dividerColor,
    required this.activeSegmentColor,
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

      final locked =
          levels[i].status == LevelStatus.terkunci ||
          levels[i + 1].status == LevelStatus.terkunci;
      final segColor = locked
          ? dividerColor
          : levels[i + 1].status == LevelStatus.aktif
          ? activeSegmentColor
          : AppTheme.green;

      final shadowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..color = segColor.withValues(alpha: locked ? 0.08 : 0.12);

      final mainPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = locked ? 5 : 7
        ..strokeCap = StrokeCap.round
        ..color = segColor.withValues(alpha: locked ? 0.55 : 0.95);

      canvas.drawPath(path, shadowPaint);
      locked
          ? _drawDashedPath(canvas, path, mainPaint)
          : canvas.drawPath(path, mainPaint);
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
  bool shouldRepaint(covariant _LevelPathPainter old) =>
      old.levels != levels ||
      old.width != width ||
      old.dividerColor != dividerColor ||
      old.activeSegmentColor != activeSegmentColor;
}

// ── LEVEL GEOMETRY ────────────────────────────────────────────────────────────
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
  }) =>
      slotLeft(index: index, width: width, slotWidth: slotWidth) +
      (slotWidth / 2);
}

// ── BACKDROP / GRID ───────────────────────────────────────────────────────────
class _MapBackdrop extends StatelessWidget {
  const _MapBackdrop();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    if (t.isDark) return const SizedBox.shrink();

    return DecoratedBox(
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
    );
  }
}

class _GridDots extends StatelessWidget {
  const _GridDots();

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return CustomPaint(painter: _DotGridPainter(isDark: t.isDark));
  }
}

class _DotGridPainter extends CustomPainter {
  final bool isDark;
  const _DotGridPainter({required this.isDark});

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
  bool shouldRepaint(covariant _DotGridPainter old) => old.isDark != isDark;
}

// ── STATUS HELPERS ────────────────────────────────────────────────────────────
Color levelStatusColor(LevelStatus s, {required bool isDark}) =>
    s == LevelStatus.selesai
        ? AppTheme.green
        : s == LevelStatus.aktif
        ? (isDark ? AppTheme.iris : kBlue)
        : const Color(0xFF666888);
String levelStatusLabel(LevelStatus s) => s == LevelStatus.selesai
    ? 'Selesai'
    : s == LevelStatus.aktif
    ? 'Aktif'
    : 'Preview';
IconData levelStatusIcon(LevelStatus s) => s == LevelStatus.selesai
    ? Icons.check_rounded
    : s == LevelStatus.aktif
    ? Icons.play_arrow_rounded
    : Icons.lock_rounded;

// ── PLACEHOLDER PAGES ─────────────────────────────────────────────────────────
class MateriPage extends StatelessWidget {
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
  Widget build(BuildContext context) => materi.MateriPage(
    initialCourseId: initialCourseId,
    initialMaterialId: initialMaterialId,
    initialCourseIndex: initialCourseIndex,
    initialModuleIndex: initialModuleIndex,
    onModuleConsumed: onModuleConsumed,
  );
}

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});
  @override
  Widget build(BuildContext context) => const leaderboard.LeaderboardPage();
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) => const profil.ProfilePage();
}
