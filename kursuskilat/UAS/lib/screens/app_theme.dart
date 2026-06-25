// ═══════════════════════════════════════════════════════════════════════════
// FILE: app_theme.dart
// Taruh file ini di lib/theme/app_theme.dart
// ═══════════════════════════════════════════════════════════════════════════
//
// CARA PAKAI DI HALAMAN LAIN:
//
//   1. Import provider & theme:
//      import 'package:provider/provider.dart';
//      import '../theme/app_theme.dart';
//
//   2. Ambil instance di dalam build():
//      final t = context.watch<AppTheme>();
//
//   3. Pakai warna dari t (dark = 3 palet: netral + hijau + iris):
//      color: t.bg           → netral gelap (background)
//      color: t.surface      → netral gelap (card/panel)
//      color: t.surfaceB     → netral gelap (item dalam card)
//      color: t.green        → aksen primary (hijau)
//      color: t.secondary    → aksen secondary (iris di dark, cyan di light)
//      color: t.secondaryDk  → secondary gelap
//      color: t.secondaryGl  → secondary terang
//      color: t.cyan         → light mode only (legacy)
//      color: t.purple       → light mode only (legacy)
//      color: t.divider      → garis pemisah
//      color: t.textPri      → teks utama
//      color: t.textSec      → teks sekunder
//      color: t.textMid      → teks tengah/muted
//      color: t.red          → merah (danger)
//      color: t.redBg        → background merah
//      color: t.redBorder    → border merah
//      color: t.shadow       → warna shadow card
//
//   4. Toggle mode dari tombol mana saja:
//      context.read<AppTheme>().toggle();
//
//   5. Cek mode saat ini:
//      t.isDark → bool
//
// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class AppTheme extends ChangeNotifier {
  bool _isDark = true;
  bool get isDark => _isDark;

  void toggle() {
    _isDark = !_isDark;
    notifyListeners();
  }

  void setDark(bool val) {
    _isDark = val;
    notifyListeners();
  }

  // ─── DARK MODE COLORS ────────────────────────────────────────────────
  static const Color _dBg        = Color(0xFF080810);
  static const Color _dSurface   = Color(0xFF13131F);
  static const Color _dSurfaceB  = Color(0xFF1C1C2E);
  static const Color _dDivider   = Color(0xFF1E1E30);
  static const Color _dTextPri   = Color(0xFFF0F0FA);
  static const Color _dTextSec   = Color(0xFF9999BB);
  static const Color _dTextMid   = Color(0xFF666888);
  static const Color _dRedBg     = Color(0xFF1F0D0D);
  static const Color _dRedBorder = Color(0xFF3A1010);
  static const Color _dShadow    = Color(0xFF000000);

  // ─── LIGHT MODE COLORS ───────────────────────────────────────────────
  static const Color _lBg        = Color(0xFFF2F4F8);
  static const Color _lSurface   = Color(0xFFFFFFFF);
  static const Color _lSurfaceB  = Color(0xFFEEF0F6);
  static const Color _lDivider   = Color(0xFFDDE0EA);
  static const Color _lTextPri   = Color(0xFF0D0D1A);
  static const Color _lTextSec   = Color(0xFF4A4A6A);
  static const Color _lTextMid   = Color(0xFF8888AA);
  static const Color _lRedBg     = Color(0xFFFFF0F0);
  static const Color _lRedBorder = Color(0xFFFFCCCC);
  static const Color _lShadow    = Color(0xFFB0B8D0);

  // ─── BRAND PRIMARY (hijau — kedua mode) ─────────────────────────────
  static const Color green     = Color(0xFF2ECC71);
  static const Color greenDk   = Color(0xFF1A9E55);
  static const Color greenGl   = Color(0xFF00E676);

  // ─── SECONDARY — dark: iris | light: cyan (light tidak diubah) ─────
  static const Color iris      = Color(0xFF7B9FFF);
  static const Color irisDk    = Color(0xFF4A6FD4);
  static const Color irisGl    = Color(0xFF9EB5FF);
  static const Color cyan      = Color(0xFF4FC3F7);
  static const Color cyanDk    = Color(0xFF0288D1);
  static const Color cyanGl    = Color(0xFF64B5F6);

  // Legacy shared (light / fallback)
  static const Color purple    = Color(0xFFAA88FF);
  static const Color red       = Color(0xFFFF6B6B);

  // ─── GETTERS DINAMIS ─────────────────────────────────────────────────
  Color get bg        => _isDark ? _dBg        : _lBg;
  Color get surface   => _isDark ? _dSurface   : _lSurface;
  Color get surfaceB  => _isDark ? _dSurfaceB  : _lSurfaceB;
  Color get divider   => _isDark ? _dDivider   : _lDivider;
  Color get textPri   => _isDark ? _dTextPri   : _lTextPri;
  Color get textSec   => _isDark ? _dTextSec   : _lTextSec;
  Color get textMid   => _isDark ? _dTextMid   : _lTextMid;
  Color get redBg     => _isDark ? _dRedBg     : _lRedBg;
  Color get redBorder => _isDark ? _dRedBorder : _lRedBorder;
  Color get shadow    => _isDark ? _dShadow    : _lShadow;

  /// Aksen sekunder: iris (dark) / cyan (light).
  Color get secondary   => _isDark ? iris   : cyan;
  Color get secondaryDk => _isDark ? irisDk : cyanDk;
  Color get secondaryGl => _isDark ? irisGl : cyanGl;

  /// Warna badge rank profil per tier (0–4).
  Color badgeColorForTier(int tierIndex) {
    const light = [greenGl, cyan, green, cyanGl, purple];
    const dark = [greenGl, iris, green, irisGl, irisDk];
    final palette = _isDark ? dark : light;
    return palette[tierIndex.clamp(0, palette.length - 1)];
  }

  // Shorthand agar kode halaman lebih ringkas
  Color get g  => green;
  Color get gd => greenDk;
  Color get gg => greenGl;
  Color get c  => secondary;
  Color get cd => secondaryDk;
  Color get cg => secondaryGl;

  // ─── MaterialApp ThemeData helper ────────────────────────────────────
  ThemeData get materialTheme => ThemeData(
    brightness: _isDark ? Brightness.dark : Brightness.light,
    scaffoldBackgroundColor: bg,
    colorScheme: ColorScheme(
      brightness:    _isDark ? Brightness.dark : Brightness.light,
      primary:       green,
      onPrimary:     Colors.black,
      secondary:     secondary,
      onSecondary:   Colors.black,
      error:         red,
      onError:       Colors.white,
      surface:       surface,
      onSurface:     textPri,
    ),
    fontFamily: 'SF Pro Display',
  );
}