// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
// FILE: profile_page.dart
// Taruh di lib/pages/profile_page.dart
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
//         home: const ProfilePage(),
//       );
//     }
//   }
//
// DEPENDENCY pubspec.yaml:
//   dependencies:
//     provider: ^6.1.2
// â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:kursuskilat/models/level_data.dart';
import 'package:kursuskilat/providers/app_data_provider.dart';
import 'package:kursuskilat/services/auth_service.dart';
import 'package:kursuskilat/screens/auth_page.dart';
import 'dart:math' as math;
import 'app_theme.dart';

// ─── DATA MODELS ──────────────────────────────────────────────────────────

class _BadgeTier {
  final String emoji, title, desc;
  final int minPoin;
  final int tierIndex;
  const _BadgeTier(
    this.emoji,
    this.title,
    this.desc,
    this.minPoin,
    this.tierIndex,
  );
}

class _ProfileData {
  String name, username, email, bio;
  int avatarIndex;
  DateTime? memberSince;
  _ProfileData({
    required this.name,
    required this.username,
    required this.email,
    required this.bio,
    required this.avatarIndex,
  });
}

// ─── PROFILE PAGE ─────────────────────────────────────────────────────────

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late AnimationController _glowCtrl, _fadeCtrl, _badgeCtrl;
  late Animation<double> _glowPulse, _fadeAnim, _badgeSpin;

  final _profile = _ProfileData(
    name: 'User',
    username: '',
    email: 'user@email.com',
    bio: 'Pelajar yang bersemangat di bidang teknologi 🚀',
    avatarIndex: 0,
  );

  bool _profileSynced = false;

  static const _avatarIcons = <IconData>[
    Icons.computer_rounded,
    Icons.person_rounded,
    Icons.school_rounded,
    Icons.science_rounded,
    Icons.pets_rounded,
    Icons.emoji_emotions_rounded,
    Icons.face_rounded,
    Icons.star_rounded,
  ];

  int get _totalPoin => context.watch<AppDataProvider>().userXp;
  List<LevelData> get _gameLevels => context.watch<AppDataProvider>().levels;

  int get _gameLevel {
    if (_gameLevels.isEmpty) return 1;
    LevelData? active;
    LevelData? highestCompleted;
    for (final level in _gameLevels) {
      if (level.status == LevelStatus.aktif) active = level;
      if (level.status == LevelStatus.selesai &&
          (highestCompleted == null || level.id > highestCompleted.id)) {
        highestCompleted = level;
      }
    }
    if (active != null) return active.id;
    if (highestCompleted != null) return highestCompleted.id;
    return 1;
  }

  String get _gameLevelTitle {
    for (final level in _gameLevels) {
      if (level.id == _gameLevel) return level.title;
    }
    return 'Level $_gameLevel';
  }

  static final List<_BadgeTier> _badgeTiers = [
    _BadgeTier('🌱', 'Pemula', '0–29 XP', 0, 0),
    _BadgeTier('⚡', 'Code Rookie', '30–79 XP', 30, 1),
    _BadgeTier('⚔️', 'Code Warrior', '80–149 XP', 80, 2),
    _BadgeTier('🎯', 'Code Master', '150–249 XP', 150, 3),
    _BadgeTier('👑', 'Kilat Legend', '250+ XP', 250, 4),
  ];

  int get _currentTierIndex {
    var idx = 0;
    for (var i = 0; i < _badgeTiers.length; i++) {
      if (_totalPoin >= _badgeTiers[i].minPoin) idx = i;
    }
    return idx;
  }

  _BadgeTier get _currentTier => _badgeTiers[_currentTierIndex];

  _BadgeTier? get _nextTier =>
      _currentTierIndex < _badgeTiers.length - 1
          ? _badgeTiers[_currentTierIndex + 1]
          : null;

  int _xpToNextRank(_BadgeTier? next) {
    if (next == null) return 0;
    return math.max(0, next.minPoin - _totalPoin);
  }

  double _rankProgress(_BadgeTier tier, _BadgeTier? next) {
    if (next == null) return 1.0;
    final span = next.minPoin - tier.minPoin;
    if (span <= 0) return 1.0;
    return ((_totalPoin - tier.minPoin) / span).clamp(0.0, 1.0);
  }

  Widget _buildAvatarIcon(int index, {required double size, Color? color}) {
    final safeIndex = index.clamp(0, _avatarIcons.length - 1);
    return Icon(
      _avatarIcons[safeIndex],
      size: size,
      color: color ?? AppTheme.green,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_profileSynced) return;
    final user = context.read<UserProvider>().user;
    if (user != null) {
      _profile.name = user.nama;
      _profile.username = user.username;
      _profile.email = user.email;
      _profileSynced = true;
      AuthService.fetchProfile().then((p) {
        if (p != null && mounted) {
          setState(() {
            _profile.username =
                p['username'] as String? ?? _profile.username;
            _profile.memberSince = AuthService.memberSinceFromProfile(p);
          });
        }
      });
    } else {
      AuthService.fetchProfile().then((p) {
        if (p != null && mounted) {
          setState(() {
            _profile.name = p['nama'] as String? ?? _profile.name;
            _profile.username =
                p['username'] as String? ?? _profile.username;
            _profile.email = p['email'] as String? ?? _profile.email;
            _profile.memberSince = AuthService.memberSinceFromProfile(p);
            _profileSynced = true;
          });
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    _glowPulse = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _badgeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _badgeSpin = CurvedAnimation(parent: _badgeCtrl, curve: Curves.linear);
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _fadeCtrl.dispose();
    _badgeCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {Color color = AppTheme.green}) {
    final t = context.read<AppTheme>();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            msg,
            style: TextStyle(color: t.textPri, fontWeight: FontWeight.w700),
          ),
          backgroundColor: t.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: color.withValues(alpha: 0.4)),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }

  void _haptic() => HapticFeedback.lightImpact();

  // ─── BOTTOM SHEETS ─────────────────────────────────────────────────────

  void _openEditProfile() {
    _haptic();
    final t = context.read<AppTheme>();
    final nameCtrl = TextEditingController(text: _profile.name);
    final emailCtrl = TextEditingController(text: _profile.email);
    final bioCtrl = TextEditingController(text: _profile.bio);
    int tempAvatarIndex = _profile.avatarIndex;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => _BottomSheet(
          title: 'Edit Profil',
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  _haptic();
                  setS(
                    () => tempAvatarIndex =
                        (tempAvatarIndex + 1) % _avatarIcons.length,
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
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
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.green.withValues(alpha: 0.3),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Center(
                        child: _buildAvatarIcon(
                          tempAvatarIndex,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: AppTheme.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: t.surface, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.black,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ketuk untuk ganti avatar',
                style: TextStyle(color: t.textMid, fontSize: 11),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(_avatarIcons.length, (i) {
                  final selected = tempAvatarIndex == i;
                  return GestureDetector(
                    onTap: () {
                      _haptic();
                      setS(() => tempAvatarIndex = i);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.green.withValues(alpha: 0.15)
                            : t.surfaceB,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppTheme.green : t.divider,
                          width: selected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Center(
                        child: _buildAvatarIcon(
                          i,
                          size: 24,
                          color: selected ? AppTheme.green : t.textMid,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              _InputField(
                label: 'Nama Lengkap',
                controller: nameCtrl,
                hint: 'Nama lengkap',
              ),
              const SizedBox(height: 14),
              _InputField(
                label: 'Email',
                controller: emailCtrl,
                hint: 'Alamat email',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
              _InputField(
                label: 'Bio',
                controller: bioCtrl,
                hint: 'Ceritakan tentang dirimu...',
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              _GreenBtn(
                label: 'Simpan Perubahan',
                onTap: () {
                  setState(() {
                    _profile.name = nameCtrl.text.trim().isEmpty
                        ? _profile.name
                        : nameCtrl.text.trim();
                    _profile.email = emailCtrl.text.trim().isEmpty
                        ? _profile.email
                        : emailCtrl.text.trim();
                    _profile.bio = bioCtrl.text.trim();
                    _profile.avatarIndex = tempAvatarIndex;
                  });
                  Navigator.pop(context);
                  _showSnack('Profil berhasil diperbarui ✓');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openAbout() {
    _haptic();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: 'Tentang Aplikasi',
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.read<AppTheme>().isDark ? AppTheme.green : null,
                gradient: context.read<AppTheme>().isDark
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
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.green.withValues(alpha: 0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Text('📱', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'KursusKilat',
              style: TextStyle(
                color: context.read<AppTheme>().textPri,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Versi 1.0.0 (Build 42)',
              style: TextStyle(
                color: context.read<AppTheme>().textMid,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            const _InfoRow(label: 'Developer', value: 'KursusKilat Team'),
            const _InfoRow(label: 'Platform', value: 'Flutter 3.x'),
            const _InfoRow(label: 'Rilis', value: 'Januari 2024'),
            const _InfoRow(label: 'Lisensi', value: 'MIT License'),
            const SizedBox(height: 20),
            Text(
              'Made with ❤️ in Indonesia',
              style: TextStyle(
                color: context.read<AppTheme>().textMid,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBadgeDetail() {
    _haptic();
    final tier = _currentTier;
    final next = _nextTier;
    final progress = _rankProgress(tier, next);
    final leaderboardBadges = [_currentTier.emoji];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BottomSheet(
        title: 'Rank Badge',
        child: Builder(
          builder: (ctx) {
            final t = ctx.watch<AppTheme>();
            return Column(
              children: [
                AnimatedBuilder(
                  animation: _glowPulse,
                  builder: (_, _) => Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: t.badgeColorForTier(_currentTierIndex).withValues(alpha: 0.12),
                      border: Border.all(
                        color: t.badgeColorForTier(_currentTierIndex).withValues(alpha: 
                          0.4 + 0.1 * _glowPulse.value,
                        ),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: t.badgeColorForTier(_currentTierIndex).withValues(alpha: 
                            0.3 + 0.1 * _glowPulse.value,
                          ),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        tier.emoji,
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  tier.title,
                  style: TextStyle(
                    color: t.badgeColorForTier(_currentTierIndex),
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_totalPoin XP · Rank berdasarkan XP season',
                  style: TextStyle(color: t.textSec, fontSize: 13),
                ),
                const SizedBox(height: 12),
                if (leaderboardBadges.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.surfaceB,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Badge Aktivitas',
                          style: TextStyle(
                            color: t.textMid,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: leaderboardBadges
                              .map(
                                (b) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: t.surface,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: AppTheme.green.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Text(
                                    b,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                if (next != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.surfaceB,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Menuju ${next.emoji} ${next.title}',
                              style: TextStyle(
                                color: t.textPri,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${next.minPoin} poin',
                              style: TextStyle(color: t.textMid, fontSize: 11),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _ProgressBar(
                          progress: progress.clamp(0.0, 1.0),
                          colorA: t.badgeColorForTier(_currentTierIndex),
                          colorB: t.badgeColorForTier(_currentTierIndex + 1),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_totalPoin - tier.minPoin).clamp(0, next.minPoin - tier.minPoin)} / ${next.minPoin - tier.minPoin} XP',
                          style: TextStyle(color: t.textMid, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Container(
                  decoration: BoxDecoration(
                    color: t.surfaceB,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: t.divider),
                  ),
                  child: Column(
                    children: _badgeTiers.asMap().entries.map((e) {
                      final i = e.key;
                      final tItem = e.value;
                      final achieved = _totalPoin >= tItem.minPoin;
                      final isCurrent = tItem == tier;
                      final isLast = i == _badgeTiers.length - 1;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  achieved ? tItem.emoji : '🔒',
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        tItem.title,
                                        style: TextStyle(
                                          color: achieved
                                              ? t.textPri
                                              : t.textMid,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        tItem.desc,
                                        style: TextStyle(
                                          color: t.textMid,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isCurrent)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: t.badgeColorForTier(i).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      'Sekarang',
                                      style: TextStyle(
                                        color: t.badgeColorForTier(i),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  )
                                else if (achieved)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: AppTheme.green,
                                    size: 18,
                                  )
                                else
                                  Text(
                                    '${tItem.minPoin} poin',
                                    style: TextStyle(
                                      color: t.textMid,
                                      fontSize: 11,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!isLast) Container(height: 1, color: t.divider),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _performLogout() async {
    try {
      await AuthService.logout();
    } catch (_) {
      // Tetap bersihkan sesi lokal meski signOut gagal.
    }
    if (!mounted) return;

    context.read<UserProvider>().logout();
    context.read<AppDataProvider>().reset();

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const AuthPage(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, _, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
      (route) => false,
    );
  }

  void _confirmLogout() {
    _haptic();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _BottomSheet(
        title: '',
        child: Builder(
          builder: (ctx) {
            final t = ctx.watch<AppTheme>();
            return Column(
              children: [
                const Text('🚪', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  'Keluar dari Akun?',
                  style: TextStyle(
                    color: t.textPri,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Kamu perlu login kembali untuk mengakses akunmu.',
                  style: TextStyle(color: t.textMid, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _performLogout();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: t.redBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.redBorder),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: AppTheme.red,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Ya, Keluar',
                          style: TextStyle(
                            color: AppTheme.red,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: t.surfaceB,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: t.divider),
                    ),
                    child: Text(
                      'Batal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: t.textSec,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ─── BUILD ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          if (!t.isDark)
            AnimatedBuilder(
              animation: _glowPulse,
              builder: (_, _) => Positioned(
                top: -80,
                left: -60,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppTheme.green.withValues(
                          alpha: 0.08 + 0.03 * _glowPulse.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned.fill(child: _GridDots()),
          FadeTransition(
            opacity: _fadeAnim,
            child: SafeArea(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildAppBar()),
                  SliverToBoxAdapter(child: _buildProfileCard()),
                  SliverToBoxAdapter(child: _buildSectionHeader('Pengaturan')),
                  SliverToBoxAdapter(child: _buildMenuList()),
                  SliverToBoxAdapter(child: _buildLogoutBtn()),
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Text(
            'Profil',
            style: TextStyle(
              color: t.textPri,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.6,
            ),
          ),
          const Spacer(),
          // ── TOGGLE DARK/LIGHT MODE ─────────────────────────────────────
          _ThemeToggleBtn(),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final t = context.watch<AppTheme>();
    final tier = _currentTier;
    final next = _nextTier;
    final badgeProg = _rankProgress(tier, next);
    final xpToNext = _xpToNextRank(next);
    final leaderBadges = [_currentTier.emoji];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: t.isDark ? t.surface : null,
          gradient: t.isDark
              ? null
              : LinearGradient(
                  colors: [
                    AppTheme.green.withValues(alpha: 0.08),
                    Colors.white,
                    const Color(0xFFF5FBF8),
                  ],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: AppTheme.green.withValues(alpha: t.isDark ? 0.28 : 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: t.isDark
                  ? AppTheme.green.withValues(alpha: 0.08)
                  : t.shadow.withValues(alpha: 0.12),
              blurRadius: 32,
            ),
          ],
        ),
        child: Column(
          children: [
            // SECTION 1: Avatar + Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedBuilder(
                        animation: _glowPulse,
                        builder: (_, _) => GestureDetector(
                          onTap: _openEditProfile,
                          child: Container(
                            width: 74,
                            height: 74,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.green.withValues(alpha: 
                                t.isDark ? 0.1 : 0.08,
                              ),
                              border: Border.all(
                                color: AppTheme.green.withValues(alpha: 
                                  0.35 + 0.1 * _glowPulse.value,
                                ),
                                width: 2.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.green.withValues(alpha: 
                                    t.isDark
                                        ? 0.18 + 0.08 * _glowPulse.value
                                        : 0.12 + 0.05 * _glowPulse.value,
                                  ),
                                  blurRadius: 18 + 6 * _glowPulse.value,
                                ),
                              ],
                            ),
                            child: Center(
                              child: _buildAvatarIcon(
                                _profile.avatarIndex,
                                size: 34,
                                color: AppTheme.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppTheme.green,
                            shape: BoxShape.circle,
                            border: Border.all(color: t.surface, width: 2),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.green.withValues(alpha: 0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _profile.name,
                          style: TextStyle(
                            color: t.textPri,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        if (_profile.username.isNotEmpty) ...[
                          const SizedBox(height: 3),
                          Text(
                            '@${_profile.username}',
                            style: TextStyle(
                              color: t.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        const SizedBox(height: 3),
                        Text(
                          _profile.email,
                          style: TextStyle(color: t.textMid, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        if (_profile.bio.isNotEmpty)
                          Text(
                            _profile.bio,
                            style: TextStyle(
                              color: t.textSec,
                              fontSize: 11,
                              height: 1.4,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        if (leaderBadges.isNotEmpty)
                          Row(
                            children: leaderBadges
                                .take(3)
                                .map(
                                  (b) => Padding(
                                    padding: const EdgeInsets.only(right: 4),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: t.surfaceB,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: t.divider),
                                      ),
                                      child: Text(
                                        b,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        const SizedBox(height: 8),
                        if (_profile.memberSince != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: t.secondary.withValues(alpha:
                                t.isDark ? 0.1 : 0.08,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: t.secondary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: t.secondary,
                                  size: 11,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  AuthService.formatMemberSince(
                                    _profile.memberSince!,
                                  ),
                                  style: TextStyle(
                                    color: t.secondary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
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

            Container(height: 1, color: AppTheme.green.withValues(alpha: 0.12)),

            // SECTION 2: Badge Kuis
            GestureDetector(
              onTap: _openBadgeDetail,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 56,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
                            animation: _badgeSpin,
                            builder: (_, _) => Transform.rotate(
                              angle: _badgeSpin.value * 2 * math.pi,
                              child: CustomPaint(
                                size: const Size(56, 56),
                                painter: _DashedRingPainter(
                                  color: t.badgeColorForTier(_currentTierIndex),
                                ),
                              ),
                            ),
                          ),
                          AnimatedBuilder(
                            animation: _glowPulse,
                            builder: (_, _) => Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: t.badgeColorForTier(_currentTierIndex)
                                    .withValues(alpha: 0.15),
                                boxShadow: [
                                  BoxShadow(
                                    color: t.badgeColorForTier(_currentTierIndex)
                                        .withValues(alpha: 
                                      0.28 + 0.12 * _glowPulse.value,
                                    ),
                                    blurRadius: 14 + 6 * _glowPulse.value,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  tier.emoji,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: t.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: t.secondary.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: Text(
                                  'Rank Badge',
                                  style: TextStyle(
                                    color: t.secondary,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.star_rounded,
                                color: AppTheme.greenGl,
                                size: 11,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '$_totalPoin XP',
                                style: TextStyle(
                                  color: t.textMid,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            tier.title,
                            style: TextStyle(
                              color: t.badgeColorForTier(_currentTierIndex),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 7),
                          if (next != null) ...[
                            _ProgressBar(
                              progress: badgeProg.clamp(0.0, 1.0),
                              colorA: AppTheme.greenDk,
                              colorB: AppTheme.greenGl,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  xpToNext > 0
                                      ? '$_totalPoin / ${next.minPoin} XP · '
                                      : 'Rank berikutnya tercapai · ',
                                  style: TextStyle(
                                    color: t.textMid,
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  xpToNext > 0
                                      ? '$xpToNext XP lagi → ${next.emoji} ${next.title}'
                                      : '${next.emoji} ${next.title}',
                                  style: TextStyle(
                                    color: t.badgeColorForTier(next.tierIndex),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ] else
                            const Row(
                              children: [
                                Icon(
                                  Icons.military_tech_rounded,
                                  color: AppTheme.greenGl,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Badge Tertinggi!',
                                  style: TextStyle(
                                    color: AppTheme.greenGl,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
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

            Container(height: 1, color: AppTheme.green.withValues(alpha: 0.12)),

            // SECTION 3: Level Game
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  AnimatedBuilder(
                    animation: _glowPulse,
                    builder: (_, _) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: t.secondary.withValues(alpha: 
                          t.isDark ? 0.08 : 0.06,
                        ),
                        border: Border.all(
                          color: t.secondary.withValues(alpha: 
                            0.3 + 0.08 * _glowPulse.value,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: t.secondary.withValues(alpha: 
                              t.isDark ? 0.12 + 0.06 * _glowPulse.value : 0.08,
                            ),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LVL',
                            style: TextStyle(
                              color: t.secondary,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                          Text(
                            '$_gameLevel',
                            style: TextStyle(
                              color: t.secondary,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level Game $_gameLevel — $_gameLevelTitle',
                          style: TextStyle(
                            color: t.textPri,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalPoin XP season · Rank ${_currentTier.title}',
                          style: TextStyle(color: t.textMid, fontSize: 11),
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
    );
  }

  Widget _buildSectionHeader(String title) {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
      child: Text(
        title,
        style: TextStyle(
          color: t.textPri,
          fontSize: 16,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
    );
  }

  Widget _buildMenuList() {
    final t = context.watch<AppTheme>();
    final items = [
      _MenuItem(
        Icons.person_outline_rounded,
        'Edit Profil',
        'Ubah nama, foto & bio',
        _openEditProfile,
      ),
      _MenuItem(
        Icons.info_outline_rounded,
        'Tentang Aplikasi',
        'v1.0.0',
        _openAbout,
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.divider),
          boxShadow: t.isDark
              ? []
              : [
                  BoxShadow(
                    color: t.shadow.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          children: items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isLast = i == items.length - 1;
            return Column(
              children: [
                GestureDetector(
                  onTap: item.action,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.green.withValues(alpha: 
                              t.isDark ? 0.08 : 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppTheme.green.withValues(alpha: 
                                t.isDark ? 0.15 : 0.2,
                              ),
                            ),
                          ),
                          child: Icon(
                            item.icon,
                            color: AppTheme.green,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: TextStyle(
                                  color: t.textPri,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (item.sub.isNotEmpty) ...[
                                const SizedBox(height: 1),
                                Text(
                                  item.sub,
                                  style: TextStyle(
                                    color: t.textMid,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: t.textMid,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Container(
                    height: 1,
                    margin: const EdgeInsets.only(left: 66),
                    color: t.divider,
                  ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildLogoutBtn() {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: _confirmLogout,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: t.redBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: t.redBorder),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.red, size: 18),
              SizedBox(width: 8),
              Text(
                'Keluar',
                style: TextStyle(
                  color: AppTheme.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── THEME TOGGLE BUTTON ──────────────────────────────────────────────────

class _ThemeToggleBtn extends StatelessWidget {
  const _ThemeToggleBtn();
  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<AppTheme>().toggle();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: t.isDark ? t.surface : const Color(0xFFFFF8E7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: t.isDark ? t.divider : const Color(0xFFFFD580),
          ),
          boxShadow: t.isDark
              ? []
              : [
                  BoxShadow(
                    color: const Color(0xFFFFD580).withValues(alpha: 0.3),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Center(
          child: Icon(
            t.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: t.isDark ? AppTheme.greenGl : const Color(0xFF9C6A00),
          ),
        ),
      ),
    );
  }
}

// ─── MODELS ───────────────────────────────────────────────────────────────

class _MenuItem {
  final IconData icon;
  final String label, sub;
  final VoidCallback action;
  const _MenuItem(this.icon, this.label, this.sub, this.action);
}

// ─── PROGRESS BAR ─────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final double progress;
  final Color colorA, colorB;
  const _ProgressBar({
    required this.progress,
    required this.colorA,
    required this.colorB,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Stack(
      children: [
        Container(
          height: 5,
          decoration: BoxDecoration(
            color: t.divider,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        FractionallySizedBox(
          widthFactor: progress,
          child: Container(
            height: 5,
            decoration: BoxDecoration(
              color: t.isDark ? colorA : null,
              gradient: t.isDark
                  ? null
                  : LinearGradient(colors: [colorA, colorB]),
              borderRadius: BorderRadius.circular(3),
              boxShadow: [
                BoxShadow(color: colorA.withValues(alpha: 0.5), blurRadius: 4),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── DASHED RING PAINTER ──────────────────────────────────────────────────

class _DashedRingPainter extends CustomPainter {
  final Color color;
  const _DashedRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;
    const dashCount = 16;
    const dashLength = 0.18;
    const gapLength = (2 * math.pi / dashCount) - dashLength;
    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * (dashLength + gapLength);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => old.color != color;
}

// ─── REUSABLE WIDGETS ─────────────────────────────────────────────────────

class _BottomSheet extends StatelessWidget {
  final String title;
  final Widget child;
  const _BottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: t.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (title.isNotEmpty) ...[
              const SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: t.textPri,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: t.surfaceB,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: t.divider),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: t.textMid,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label, hint;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType? keyboardType;
  const _InputField({
    required this.label,
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: t.textSec, fontSize: 12)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: t.textPri, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: t.textMid),
            filled: true,
            fillColor: t.surfaceB,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: t.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppTheme.green.withValues(alpha: 0.5)),
            ),
          ),
        ),
      ],
    );
  }
}

class _GreenBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GreenBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: t.isDark ? AppTheme.green : null,
          gradient: t.isDark
              ? null
              : const LinearGradient(
                  colors: [AppTheme.greenDk, AppTheme.green, AppTheme.greenGl],
                ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: AppTheme.green.withValues(alpha: 0.35), blurRadius: 12),
          ],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<AppTheme>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: t.textMid, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              color: t.textPri,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    const spacing = 30.0, r = 1.0;
    final dotColor = isDark ? const Color(0xFF1E1E30) : const Color(0xFFD0D4E8);
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
          paint..color = dotColor.withValues(alpha: op),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter old) => old.isDark != isDark;
}
