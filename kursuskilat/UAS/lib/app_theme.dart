import 'package:flutter/material.dart';

class KursusThemeController {
  KursusThemeController._();

  static final ValueNotifier<bool> isLightMode = ValueNotifier<bool>(false);

  static bool get isLight => isLightMode.value;

  static void toggle() {
    isLightMode.value = !isLightMode.value;
  }
}

class KursusPalette {
  final Color bg;
  final Color surface;
  final Color surfaceB;
  final Color divider;
  final Color textPri;
  final Color textSec;
  final Color textMid;

  const KursusPalette({
    required this.bg,
    required this.surface,
    required this.surfaceB,
    required this.divider,
    required this.textPri,
    required this.textSec,
    required this.textMid,
  });

  static const dark = KursusPalette(
    bg: Color(0xFF080810),
    surface: Color(0xFF13131F),
    surfaceB: Color(0xFF1C1C2E),
    divider: Color(0xFF1E1E30),
    textPri: Color(0xFFF0F0FA),
    textSec: Color(0xFF9999BB),
    textMid: Color(0xFF666888),
  );

  static const light = KursusPalette(
    bg: Color(0xFFF4F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceB: Color(0xFFEAF0F6),
    divider: Color(0xFFDDE5EE),
    textPri: Color(0xFF121826),
    textSec: Color(0xFF4B5565),
    textMid: Color(0xFF7B8494),
  );

  static KursusPalette get current =>
      KursusThemeController.isLight ? light : dark;
}
