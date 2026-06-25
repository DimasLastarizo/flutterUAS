import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kursuskilat/services/auth_service.dart';
import 'auth_page.dart';
import 'game_page.dart';

// ─── SPLASH SCREEN ───────────────────────────────────────────────────────────

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Color tokens ────────────────────────────────────────────────────────
  static const _bg       = Color(0xFF080810);
  static const _surface  = Color(0xFF13131F);
  static const _green    = Color(0xFF2ECC71);
  static const _greenDk  = Color(0xFF1AA355);
  static const _greenGl  = Color(0xFF5DEBA0);
  static const _blue     = Color(0xFF4E9DFF);
  static const _divider  = Color(0xFF1E1E30);
  static const _textPri  = Color(0xFFF0F0FA);
  static const _textMid  = Color(0xFF666888);

  // ── Controllers ─────────────────────────────────────────────────────────
  late AnimationController _glowCtrl;
  late AnimationController _orbitCtrl;   // orbiting dot
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _tagCtrl;
  late AnimationController _barCtrl;
  late AnimationController _shimmerCtrl; // shimmer on bar
  late AnimationController _exitCtrl;

  // ── Animations ──────────────────────────────────────────────────────────
  late Animation<double> _glowPulse;
  late Animation<double> _orbitAngle;

  late Animation<double> _ringScale;
  late Animation<double> _ringOpacity;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoY;

  late Animation<double> _textOpacity;
  late Animation<Offset>  _textSlide;

  late Animation<double> _tagOpacity;
  late Animation<double> _tagY;

  late Animation<double> _barProgress;
  late Animation<double> _shimmerPos;

  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor:           Colors.transparent,
      statusBarIconBrightness:  Brightness.light,
      systemNavigationBarColor: Color(0xFF080810),
    ));
    _buildAnimations();
    _runSequence();
  }

  void _buildAnimations() {
    // Ambient glow pulse
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _glowPulse = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);

    // Orbit dot — continuous rotation
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3200))
      ..repeat();
    _orbitAngle = Tween<double>(begin: 0, end: 6.2832)
        .animate(_orbitCtrl); // 0 → 2π

    // Logo entrance
    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _ringScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)));
    _ringOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.1, 1.0, curve: Curves.elasticOut)));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl,
            curve: const Interval(0.0, 0.35, curve: Curves.easeOut)));
    _logoY = Tween<double>(begin: 20.0, end: 0.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutCubic));

    // Brand text
    _textCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 550));
    _textOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOutCubic));

    // Tagline
    _tagCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _tagOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));
    _tagY = Tween<double>(begin: 14.0, end: 0.0)
        .animate(CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOutCubic));

    // Loading bar
    _barCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _barProgress = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut));

    // Shimmer on bar
    _shimmerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
    _shimmerPos = Tween<double>(begin: -1.0, end: 2.0)
        .animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut));

    // Exit — fade + subtle scale down
    _exitCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
    _exitScale = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn));
  }

  Future<void> _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 180));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 360));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 160));
    _tagCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 120));
    _barCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    await _exitCtrl.forward();
    if (!mounted) return;

    final hasSession = await AuthService.hasPersistedSession();
    if (!mounted) return;

    if (hasSession) {
      await syncUserSession(context);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, _, _) => const RootShell(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
      ));
      return;
    }

    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder:        (_, _, _) => const AuthPage(),
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, anim, _, child) => FadeTransition(
        opacity: anim,
        child: child,
      ),
    ));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    _orbitCtrl.dispose();
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _tagCtrl.dispose();
    _barCtrl.dispose();
    _shimmerCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  // ─── BUILD ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnimatedBuilder(
      animation: _exitCtrl,
      builder: (_, child) => FadeTransition(
        opacity: _exitOpacity,
        child: ScaleTransition(
          scale: _exitScale,
          child: child,
        ),
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(children: [

          // ── 1. Deep ambient glows ───────────────────────────────────
          AnimatedBuilder(
            animation: _glowPulse,
            builder: (_, _) => Stack(children: [
              // Primary green — bottom center
              Positioned(
                bottom: -size.height * 0.08,
                left:   size.width * 0.5 - 200,
                child: _GlowCircle(
                  size:    400,
                  color:   _green,
                  opacity: 0.11 + 0.06 * _glowPulse.value,
                ),
              ),
              // Secondary green — center
              Positioned(
                top:  size.height * 0.38,
                left: size.width * 0.5 - 120,
                child: _GlowCircle(
                  size:    240,
                  color:   _greenGl,
                  opacity: 0.05 + 0.03 * _glowPulse.value,
                ),
              ),
              // Blue accent — top right
              Positioned(
                top:   -50,
                right: -70,
                child: _GlowCircle(
                  size:    240,
                  color:   _blue,
                  opacity: 0.06 + 0.03 * _glowPulse.value,
                ),
              ),
            ]),
          ),

          // ── 2. Grid dots ────────────────────────────────────────────
          const Positioned.fill(child: _GridDots()),

          // ── 3. Main content ─────────────────────────────────────────
          SafeArea(
            child: Column(children: [
              const Spacer(flex: 5),

              // Logo
              AnimatedBuilder(
                animation: Listenable.merge([_logoCtrl, _glowPulse, _orbitAngle]),
                builder: (_, _) => Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _logoY.value),
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: _buildLogo(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Brand name
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: _buildBrandText(),
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              AnimatedBuilder(
                animation: _tagCtrl,
                builder: (_, _) => Opacity(
                  opacity: _tagOpacity.value,
                  child: Transform.translate(
                    offset: Offset(0, _tagY.value),
                    child: _buildTagline(),
                  ),
                ),
              ),

              const Spacer(flex: 4),

              // Loading bar
              _buildLoadingBar(),

              const SizedBox(height: 20),

              // Version
              FadeTransition(
                opacity: _tagOpacity,
                child: const Text(
                  'v1.0.0',
                  style: TextStyle(
                    color:       Color(0xFF303048),
                    fontSize:    11,
                    letterSpacing: 1.2,
                    fontWeight:  FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ]),
          ),
        ]),
      ),
    );
  }

  // ─── Logo ─────────────────────────────────────────────────────────────────

  Widget _buildLogo() {
    return SizedBox(
      width:  140,
      height: 140,
      child: Stack(alignment: Alignment.center, children: [

        // Outer glow ring (animated opacity)
        ScaleTransition(
          scale: _ringScale,
          child: FadeTransition(
            opacity: _ringOpacity,
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (_, _) => Container(
                width:  138,
                height: 138,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _green.withValues(alpha: 0.10 + 0.07 * _glowPulse.value),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Middle ring
        ScaleTransition(
          scale: _ringScale,
          child: FadeTransition(
            opacity: _ringOpacity,
            child: AnimatedBuilder(
              animation: _glowPulse,
              builder: (_, _) => Container(
                width:  112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _green.withValues(alpha: 0.18 + 0.10 * _glowPulse.value),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),

        // Orbiting dot
        AnimatedBuilder(
          animation: _orbitAngle,
          builder: (_, _) {
            final angle = _orbitAngle.value;
            const r = 56.0;
            final dx = r * (angle == 0 ? 1.0 : _cos(angle));
            final dy = r * (angle == 0 ? 0.0 : _sin(angle));
            return Transform.translate(
              offset: Offset(dx, dy),
              child: AnimatedBuilder(
                animation: _glowPulse,
                builder: (_, _) => Container(
                  width:  7,
                  height: 7,
                  decoration: BoxDecoration(
                    color:  _green.withValues(alpha: 0.8 + 0.2 * _glowPulse.value),
                    shape:  BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color:      _green.withValues(alpha: 0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        // Core logo circle
        AnimatedBuilder(
          animation: _glowPulse,
          builder: (_, _) => Container(
            width:  88,
            height: 88,
            decoration: BoxDecoration(
              color:  _surface,
              shape:  BoxShape.circle,
              border: Border.all(
                color: _green.withValues(alpha: 0.35 + 0.18 * _glowPulse.value),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color:      _green.withValues(alpha: 0.18 + 0.12 * _glowPulse.value),
                  blurRadius: 32,
                  spreadRadius: 4,
                ),
                BoxShadow(
                  color:      _green.withValues(alpha: 0.08),
                  blurRadius: 60,
                  spreadRadius: 12,
                ),
              ],
            ),
            child: Center(
              child: _LogoIcon(glowValue: _glowPulse.value),
            ),
          ),
        ),
      ]),
    );
  }

  // ─── Brand text ───────────────────────────────────────────────────────────

  Widget _buildBrandText() {
    return Column(children: [
      RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize:     36,
            fontWeight:   FontWeight.w900,
            letterSpacing: -1.0,
            height:       1,
          ),
          children: [
            const TextSpan(
              text:  'Kursus',
              style: TextStyle(color: _textPri),
            ),
            TextSpan(
              text:  'Kilat',
              style: TextStyle(
                color:   _green,
                shadows: [
                  Shadow(color: _green.withValues(alpha: 0.4), blurRadius: 24),
                  Shadow(color: _green.withValues(alpha: 0.2), blurRadius: 48),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 6),
      // Thin separator line
      Container(
        width:  80,
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.transparent,
            _green.withValues(alpha: 0.5),
            Colors.transparent,
          ]),
        ),
      ),
    ]);
  }

  // ─── Tagline ──────────────────────────────────────────────────────────────

  Widget _buildTagline() {
    return Column(children: [
      const Text(
        'Belajar Lebih Cepat, Lebih Cerdas',
        style: TextStyle(
          color:         _textMid,
          fontSize:      13,
          fontWeight:    FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 16),
      // AI pill
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color:        _green.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(24),
          border:       Border.all(color: _green.withValues(alpha: 0.22), width: 1),
          boxShadow: [
            BoxShadow(
              color:      _green.withValues(alpha: 0.08),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width:  8,
            height: 8,
            decoration: BoxDecoration(
              color:  _green,
              shape:  BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _green.withValues(alpha: 0.7), blurRadius: 6),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Didukung I.R.I.S. AI',
            style: TextStyle(
              color:         _green,
              fontSize:      12,
              fontWeight:    FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ]),
      ),
    ]);
  }

  // ─── Loading bar ─────────────────────────────────────────────────────────

  Widget _buildLoadingBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 52),
      child: AnimatedBuilder(
        animation: Listenable.merge([_barCtrl, _shimmerCtrl]),
        builder: (_, _) => Column(children: [
          // Track
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Container(
              height: 3,
              color:  _divider,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _barProgress.value,
                child: Stack(children: [
                  // Bar fill
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_greenDk, _green, _greenGl],
                      ),
                    ),
                  ),
                  // Shimmer sweep
                  if (_barProgress.value > 0.05)
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment(
                          (_shimmerPos.value * 2 - 1).clamp(-1.0, 1.0),
                          0,
                        ),
                        widthFactor: 0.3,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: 0.30),
                              Colors.white.withValues(alpha: 0),
                            ]),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _loadingLabel(_barProgress.value),
                style: const TextStyle(
                  color:         _textMid,
                  fontSize:      11,
                  letterSpacing: 0.4,
                ),
              ),
              Text(
                '${(_barProgress.value * 100).toInt()}%',
                style: TextStyle(
                  color:         _green.withValues(alpha: 0.7),
                  fontSize:      11,
                  fontWeight:    FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  String _loadingLabel(double v) {
    if (v < 0.30) return 'Memuat kursus...';
    if (v < 0.65) return 'Menghubungkan I.R.I.S...';
    if (v < 0.92) return 'Menyiapkan dashboard...';
    return 'Siap! ✓';
  }

  // ─── Math helpers (avoid dart:math import) ───────────────────────────────

  double _cos(double rad) {
    // Taylor series approximation — good enough for orbit
    double r = rad % 6.2832;
    if (r < 0) r += 6.2832;
    double x = 1, t = 1;
    for (int i = 1; i <= 8; i++) {
      t *= -r * r / ((2 * i - 1) * (2 * i));
      x += t;
    }
    return x;
  }

  double _sin(double rad) {
    double r = rad % 6.2832;
    if (r < 0) r += 6.2832;
    double x = r, t = r;
    for (int i = 1; i <= 8; i++) {
      t *= -r * r / ((2 * i) * (2 * i + 1));
      x += t;
    }
    return x;
  }
}

// ─── LOGO ICON ───────────────────────────────────────────────────────────────

class _LogoIcon extends StatelessWidget {
  final double glowValue;
  const _LogoIcon({required this.glowValue});

  @override
  Widget build(BuildContext context) {
    return Stack(alignment: Alignment.center, children: [
      // Book shape
      Container(
        width:  36,
        height: 42,
        decoration: BoxDecoration(
          color:        const Color(0xFF1C2A1C),
          borderRadius: BorderRadius.circular(4),
          border:       Border.all(
            color: const Color(0xFF2ECC71).withValues(alpha: 0.5 + 0.25 * glowValue),
            width: 1.5,
          ),
        ),
      ),
      // Lines on book
      Positioned(
        top:   10,
        left:  20,
        right: 20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookLine(width: double.infinity, glow: glowValue),
            const SizedBox(height: 5),
            _BookLine(width: double.infinity, glow: glowValue),
            const SizedBox(height: 5),
            _BookLine(width: 14, glow: glowValue),
          ],
        ),
      ),
      // Lightning bolt overlay
      Positioned(
        bottom: 8,
        right:  10,
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color:        const Color(0xFF2ECC71),
            borderRadius: BorderRadius.circular(3),
            boxShadow: [
              BoxShadow(
                color:      const Color(0xFF2ECC71).withValues(alpha: 0.6 + 0.2 * glowValue),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Icon(Icons.bolt, size: 12, color: Colors.black),
        ),
      ),
    ]);
  }
}

class _BookLine extends StatelessWidget {
  final double width;
  final double glow;
  const _BookLine({required this.width, required this.glow});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  width,
      height: 2,
      decoration: BoxDecoration(
        color:        const Color(0xFF2ECC71).withValues(alpha: 0.35 + 0.2 * glow),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}

// ─── GLOW CIRCLE HELPER ──────────────────────────────────────────────────────

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color  color;
  final double opacity;
  const _GlowCircle({required this.size, required this.color, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width:  size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [
          color.withValues(alpha: opacity),
          Colors.transparent,
        ]),
      ),
    );
  }
}

// ─── GRID DOTS ───────────────────────────────────────────────────────────────

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
    final paint = Paint()
      ..color = const Color(0xFF1E1E30)
      ..style = PaintingStyle.fill;

    const spacing = 30.0;
    const r       = 1.0;

    for (double x = spacing; x < size.width; x += spacing) {
      for (double y = spacing; y < size.height; y += spacing) {
        // Fade dots near edges
        final edgeFade = _edgeFactor(x, y, size);
        if (edgeFade < 0.05) continue;
        canvas.drawCircle(
          Offset(x, y),
          r,
          paint..color = Color(0xFF1E1E30).withValues(alpha: edgeFade),
        );
      }
    }
  }

  double _edgeFactor(double x, double y, Size s) {
    final fx = (x / s.width  - 0.5).abs() * 2; // 0 center → 1 edge
    final fy = (y / s.height - 0.5).abs() * 2;
    final f  = (fx > fy ? fx : fy);
    return (1.0 - f * 1.2).clamp(0.0, 1.0);
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}