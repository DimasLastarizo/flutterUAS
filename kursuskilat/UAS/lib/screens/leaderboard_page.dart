// ═══════════════════════════════════════════════════════════════════════════
// FILE: leaderboard_page.dart
// Taruh di lib/pages/leaderboard_page.dart
//
// SETUP (di main.dart):
//   import 'package:provider/provider.dart';
//   import 'theme/app_theme.dart';
//
//   void main() => runApp(
//     ChangeNotifierProvider(
//       create: (_) => AppTheme(),
//       child: const MyApp(),
//     ),
//   );
//
//   class MyApp extends StatelessWidget {
//     const MyApp({super.key});
//     @override
//     Widget build(BuildContext context) {
//       final theme = context.watch<AppTheme>();
//       return MaterialApp(
//         theme: theme.materialTheme,
//         home: const LeaderboardPage(),
//       );
//     }
//   }
//
// DEPENDENCY pubspec.yaml:
//   dependencies:
//     provider: ^6.1.2
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/providers/app_data_provider.dart';
import 'dart:math' as math;
import 'app_theme.dart';

/// Level game dari baris user_level_progress (aktif → selesai tertinggi → 1).
int gameLevelFromProgressRows(Iterable<Map<String, dynamic>> rows) {
  if (rows.isEmpty) return 1;
  int? active;
  int? highestCompleted;
  for (final row in rows) {
    final n = row['level_number'] as int;
    final status = row['status'] as String;
    if (status == 'aktif') active = n;
    if (status == 'selesai' &&
        (highestCompleted == null || n > highestCompleted)) {
      highestCompleted = n;
    }
  }
  if (active != null) return active;
  if (highestCompleted != null) return highestCompleted;
  return 1;
}

// ─── DATA MODELS ──────────────────────────────────────────────────────────

enum LeaderboardPeriod { minggu, bulan, semua }

class LeaderboardUser {
  final String name;
  final String initials;
  final int xp;
  final int level;
  final List<String> badges;
  final Color avatarBg;
  final Color avatarText;
  final bool isMe;

  const LeaderboardUser({
    required this.name,
    required this.initials,
    required this.xp,
    required this.level,
    required this.badges,
    required this.avatarBg,
    required this.avatarText,
    this.isMe = false,
  });
}

// ─── LEADERBOARD DATASETS ─────────────────────────────────────────────────
// Fallback kosong — jangan tampilkan ranking dummy saat Supabase gagal/kosong.

const Map<LeaderboardPeriod, List<LeaderboardUser>> leaderboardFallback = {
  LeaderboardPeriod.minggu: [],
  LeaderboardPeriod.bulan: [],
  LeaderboardPeriod.semua: [],
};

// ─── LEADERBOARD PAGE ─────────────────────────────────────────────────────

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage>
    with TickerProviderStateMixin {
  /// Satu leaderboard season — data Supabase period_type "bulan".
  static const _activePeriod = LeaderboardPeriod.bulan;

  late AnimationController _glowCtrl;
  late Animation<double> _glowPulse;
  late AnimationController _entryCtrl;
  late Animation<double> _entryAnim;
  late AnimationController _podiumCtrl;
  late Animation<double> _podiumAnim;

  // ── Podium config
  static const _podiumOrder = [1, 0, 2]; // display: 2nd, 1st, 3rd
  static const _podiumHeight = [64.0, 96.0, 48.0];

  // Warna podium — dark mode
  static const _podiumBgDark = [
    Color(0xFF1E1535), // 2nd – ungu gelap
    Color(0xFF201A06), // 1st – emas gelap
    Color(0xFF1E1210), // 3rd – tembaga gelap
  ];
  // Warna podium — light mode
  static const _podiumBgLight = [
    Color(0xFFEDE9FF), // 2nd – ungu muda
    Color(0xFFFFF7E0), // 1st – emas muda
    Color(0xFFFFF0EB), // 3rd – tembaga/coral muda
  ];

  static const _podiumText = [
    Color(0xFFAA88FF), // 2nd – ungu terang
    Color(0xFFFFB347), // 1st – amber/emas terang
    Color(0xFFFF7055), // 3rd – coral/tembaga terang
  ];
  // Teks podium di light mode harus lebih gelap agar kontras
  static const _podiumTextLight = [
    Color(0xFF6A3DBF), // 2nd – ungu gelap
    Color(0xFF9C6A00), // 1st – emas gelap
    Color(0xFFB33A1A), // 3rd – coral gelap
  ];
  static const _podiumBorderDark = [
    Color(0xFF3D2A7A), // ungu
    Color(0xFF7A5A12), // emas
    Color(0xFF7A3020), // tembaga
  ];
  static const _podiumBorderLight = [
    Color(0xFFBBA8EE), // ungu muda
    Color(0xFFE5C96A), // emas muda
    Color(0xFFE8A082), // tembaga muda
  ];
  static const _medals = ['🥇', '🥈', '🥉'];

  List<LeaderboardUser> get _currentData =>
      context.watch<AppDataProvider>().leaderboard[_activePeriod] ??
      leaderboardFallback[_activePeriod] ??
      const [];
  bool get _hasData => _currentData.isNotEmpty;

  String? _rankMedal(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }
  int? get _myRank {
    final idx = _currentData.indexWhere((u) => u.isMe);
    return idx >= 0 ? idx + 1 : null;
  }

  LeaderboardUser? get _myUser {
    for (final user in _currentData) {
      if (user.isMe) return user;
    }
    return null;
  }

  String get _totalLabel {
    if (!_hasData) return 'Belum ada data leaderboard';
    final count = _currentData.length;
    return 'Ranking season · $count pelajar';
  }

  @override
  void initState() {
    super.initState();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowPulse = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    _podiumCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _podiumAnim = CurvedAnimation(
      parent: _podiumCtrl,
      curve: Curves.easeOutBack,
    );

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _entryAnim = CurvedAnimation(
      parent: _entryCtrl,
      curve: Curves.easeOutCubic,
    );

    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _podiumCtrl.forward();
        _entryCtrl.forward();
      }
    });
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _podiumCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  String _fmtXp(int xp) {
    if (xp >= 1000) {
      final v = xp / 1000;
      return '${v == v.roundToDouble() ? v.toInt() : v.toStringAsFixed(1)} rb';
    }
    return xp.toString();
  }

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          // Ambient glow — adaptif terhadap mode
          AnimatedBuilder(
            animation: _glowPulse,
            builder: (_, _) => Positioned(
              top: -100,
              left: -60,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.green.withValues(alpha: 
                        t.isDark
                            ? 0.05 + 0.03 * _glowPulse.value
                            : 0.08 + 0.04 * _glowPulse.value,
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _glowPulse,
            builder: (_, _) => Positioned(
              top: 180,
              right: -80,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.purple.withValues(alpha: 
                        t.isDark
                            ? 0.04 + 0.02 * (1 - _glowPulse.value)
                            : 0.06 + 0.03 * (1 - _glowPulse.value),
                      ),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(child: _GridDots()),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildAppBar()),
                if (!_hasData) ...[
                  SliverToBoxAdapter(child: _buildEmptyState()),
                ] else ...[
                  SliverToBoxAdapter(child: _buildPodium()),
                  SliverToBoxAdapter(child: _buildDivider()),
                  SliverToBoxAdapter(child: _buildListHeader()),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _buildListRow(i + 3, _currentData[i + 3], i),
                      childCount: math.max(0, _currentData.length - 3),
                    ),
                  ),
                  if (_myUser != null)
                    SliverToBoxAdapter(child: _buildMyPositionBanner()),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── App Bar ──────────────────────────────────────────────────────────────

  Widget _buildAppBar() {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Leaderboard',
                style: TextStyle(
                  color: t.textPri,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _totalLabel,
                style: TextStyle(color: t.textMid, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          // ── TOGGLE DARK/LIGHT MODE ──────────────────────────────────────
        ],
      ),
    );
  }

  // ─── Podium ───────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 56, 20, 56),
      child: Column(
        children: [
          Icon(
            Icons.leaderboard_outlined,
            size: 48,
            color: t.textMid.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data leaderboard',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.textPri,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Peringkat akan muncul setelah data tersedia dari server.',
            textAlign: TextAlign.center,
            style: TextStyle(color: t.textMid, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ─── Podium ───────────────────────────────────────────────────────────────

  Widget _buildPodium() {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: AnimatedBuilder(
        animation: _podiumAnim,
        builder: (_, _) => Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (col) {
            final dataIdx = _podiumOrder[col];
            if (dataIdx >= _currentData.length) return const SizedBox.shrink();
            final user = _currentData[dataIdx];
            final h = _podiumHeight[col] * _podiumAnim.value;

            final podiumBg = t.isDark
                ? _podiumBgDark[col]
                : _podiumBgLight[col];
            final podiumBorder = t.isDark
                ? _podiumBorderDark[col]
                : _podiumBorderLight[col];
            final podiumTxt = t.isDark
                ? _podiumText[col]
                : _podiumTextLight[col];
            final borderColor = t.isDark
                ? user.avatarText.withValues(alpha: 0.5)
                : user.avatarText.withValues(alpha: 0.7);

            // Avatar background adaptif
            final avatarBg = t.isDark
                ? user.avatarBg
                : user.avatarText.withValues(alpha: 0.12);

            return Expanded(
              child: Column(
                children: [
                  Text(_medals[col], style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 6),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: avatarBg,
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: user.avatarText.withValues(alpha: 
                            t.isDark ? 0.2 : 0.15,
                          ),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        user.initials,
                        style: TextStyle(
                          color: user.avatarText,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: user.isMe ? AppTheme.green : t.textPri,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_fmtXp(user.xp)} XP',
                    style: TextStyle(color: t.textMid, fontSize: 10),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    height: h.clamp(12.0, _podiumHeight[col]),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: podiumBg,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                      border: Border.all(
                        color: podiumBorder.withValues(alpha: 0.6),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: podiumTxt.withValues(alpha: t.isDark ? 0.15 : 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, -2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Lv${user.level}',
                        style: TextStyle(
                          color: podiumTxt,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ─── Divider ──────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(child: Divider(color: t.divider, height: 1, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Peringkat lainnya',
              style: TextStyle(color: t.textMid, fontSize: 10),
            ),
          ),
          Expanded(child: Divider(color: t.divider, height: 1, thickness: 1)),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          const SizedBox(width: 22),
          const SizedBox(width: 10),
          const SizedBox(width: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pelajar',
              style: TextStyle(color: t.textMid, fontSize: 11),
            ),
          ),
          Text('Medali', style: TextStyle(color: t.textMid, fontSize: 11)),
          const SizedBox(width: 16),
          Text('XP', style: TextStyle(color: t.textMid, fontSize: 11)),
        ],
      ),
    );
  }

  // ─── List Row ─────────────────────────────────────────────────────────────

  Widget _buildListRow(int rank, LeaderboardUser user, int animIdx) {
    final t = context.watch<AppTheme>();
    final delay = animIdx * 0.06;

    // Avatar background adaptif untuk mode terang
    final avatarBg = t.isDark
        ? user.avatarBg
        : user.avatarText.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _entryAnim,
      builder: (_, child) {
        final progress = ((_entryAnim.value - delay) / (1.0 - delay)).clamp(
          0.0,
          1.0,
        );
        return Transform.translate(
          offset: Offset(0, 20 * (1 - progress)),
          child: Opacity(opacity: progress.clamp(0.0, 1.0), child: child),
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: user.isMe
                ? AppTheme.cyan.withValues(alpha: t.isDark ? 0.08 : 0.07)
                : t.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: user.isMe
                  ? AppTheme.cyan.withValues(alpha: t.isDark ? 0.35 : 0.45)
                  : t.divider,
              width: user.isMe ? 1.2 : 1,
            ),
            boxShadow: t.isDark
                ? []
                : [
                    BoxShadow(
                      color: t.shadow.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: user.isMe ? AppTheme.cyan : t.textMid,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarBg,
                  border: Border.all(
                    color: user.isMe
                        ? AppTheme.cyan.withValues(alpha: 0.5)
                        : user.avatarText.withValues(alpha: t.isDark ? 0.25 : 0.4),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    user.initials,
                    style: TextStyle(
                      color: user.avatarText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user.name,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: t.textPri,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (user.isMe) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.cyan.withValues(alpha: 
                                t.isDark ? 0.15 : 0.12,
                              ),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: AppTheme.cyan.withValues(alpha: 
                                  t.isDark ? 0.4 : 0.5,
                                ),
                              ),
                            ),
                            child: Text(
                              'Kamu',
                              style: TextStyle(
                                color: AppTheme.cyan,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Level ${user.level}',
                      style: TextStyle(color: t.textMid, fontSize: 11),
                    ),
                  ],
                ),
              ),
              if (_rankMedal(rank) != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: t.surfaceB,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: t.divider),
                  ),
                  child: Text(
                    _rankMedal(rank)!,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 10),
              ] else
                const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _fmtXp(user.xp),
                    style: TextStyle(
                      color: user.isMe ? AppTheme.cyan : t.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text('XP', style: TextStyle(color: t.textMid, fontSize: 9)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── My Position Banner ───────────────────────────────────────────────────

  Widget _buildMyPositionBanner() {
    final t = context.watch<AppTheme>();
    final me = _myUser;
    if (me == null || _myRank == null) return const SizedBox.shrink();

    final avatarBg = t.isDark ? me.avatarBg : me.avatarText.withValues(alpha: 0.12);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: t.isDark
                ? [AppTheme.green.withValues(alpha: 0.08), t.surfaceB]
                : [AppTheme.green.withValues(alpha: 0.06), t.surface],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.green.withValues(alpha: t.isDark ? 0.25 : 0.3),
          ),
          boxShadow: t.isDark
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.green.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarBg,
                border: Border.all(
                  color: AppTheme.green.withValues(alpha: 0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.green.withValues(alpha: t.isDark ? 0.15 : 0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  me.initials,
                  style: TextStyle(
                    color: me.avatarText,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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
                    'Posisimu saat ini',
                    style: TextStyle(color: t.textMid, fontSize: 11),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '#$_myRank · ${_fmtXp(me.xp)} XP · Lv ${me.level}',
                    style: TextStyle(
                      color: t.textPri,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.green.withValues(alpha: t.isDark ? 0.12 : 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.green.withValues(alpha: t.isDark ? 0.3 : 0.4),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'LVL',
                    style: TextStyle(
                      color: AppTheme.green,
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '${me.level}',
                    style: const TextStyle(
                      color: AppTheme.green,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GRID DOTS ────────────────────────────────────────────────────────────

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
    const r = 1.0;
    // Warna titik: lebih terlihat di light mode, lebih subtil di dark mode
    final dotColor = isDark ? const Color(0xFF1E1E30) : const Color(0xFFC8CCE0);

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        final fx = (x / size.width - 0.5).abs() * 2;
        final fy = (y / size.height - 0.5).abs() * 2;
        final f = math.max(fx, fy);
        final opacity = (1.0 - f * 1.2).clamp(0.0, 1.0);
        if (opacity < 0.05) continue;
        canvas.drawCircle(
          Offset(x, y),
          r,
          paint..color = dotColor.withValues(alpha: opacity),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.isDark != isDark;
}
