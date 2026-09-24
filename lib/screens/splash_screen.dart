import 'dart:math';
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Logo ──────────────────────────────────────────────────────────────────
  late final AnimationController _logoCtrl = AnimationController(
    duration: const Duration(milliseconds: 900),
    vsync: this,
  );
  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _logoCtrl,
    curve: Curves.elasticOut,
  );
  late final Animation<double> _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _logoCtrl, curve: const Interval(0, 0.3)),
  );
  late final Animation<double> _glowOpacity = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.2, 0.6)),
  );

  // ── Anneaux ────────────────────────────────────────────────────────────────
  late final AnimationController _ring1 = AnimationController(
    duration: const Duration(milliseconds: 1400),
    vsync: this,
  );
  late final AnimationController _ring2 = AnimationController(
    duration: const Duration(milliseconds: 1600),
    vsync: this,
  );
  late final AnimationController _ring3 = AnimationController(
    duration: const Duration(milliseconds: 1800),
    vsync: this,
  );

  // ── Texte ──────────────────────────────────────────────────────────────────
  late final AnimationController _textCtrl = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );
  late final Animation<double> _textOpacity = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _textCtrl, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.4),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));
  late final Animation<double> _tagOpacity = Tween<double>(begin: 0, end: 1).animate(
    CurvedAnimation(parent: _textCtrl, curve: const Interval(0.5, 1)),
  );

  // ── Barre de chargement ───────────────────────────────────────────────────
  late final AnimationController _barCtrl = AnimationController(
    duration: const Duration(milliseconds: 1800),
    vsync: this,
  );

  // ── Sortie ────────────────────────────────────────────────────────────────
  late final AnimationController _exitCtrl = AnimationController(
    duration: const Duration(milliseconds: 500),
    vsync: this,
  );
  late final Animation<double> _exitOpacity = Tween<double>(begin: 1, end: 0).animate(
    CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
  );
  late final Animation<double> _exitScale = Tween<double>(begin: 1, end: 1.08).animate(
    CurvedAnimation(parent: _exitCtrl, curve: Curves.easeIn),
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _ring1.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _ring2.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _ring3.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _textCtrl.forward();
    _barCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1600));
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget.nextScreen,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _ring1.dispose();
    _ring2.dispose();
    _ring3.dispose();
    _barCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  Widget _ring(AnimationController ctrl, double size, double strokeW, double opacity) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Transform.scale(
        scale: Tween<double>(begin: 0.4, end: 2.8).evaluate(
          CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
        ),
        child: Opacity(
          opacity: Tween<double>(begin: opacity, end: 0).evaluate(
            CurvedAnimation(parent: ctrl, curve: Curves.easeOut),
          ).clamp(0, 1),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primary, width: strokeW),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A16),
      body: AnimatedBuilder(
        animation: Listenable.merge([_exitCtrl]),
        builder: (_, child) => Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(scale: _exitScale.value, child: child),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ── Fond dégradé radial ──────────────────────────────────────
            AnimatedBuilder(
              animation: _glowOpacity,
              builder: (_, __) => Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.1),
                    radius: 1.2,
                    colors: [
                      AppTheme.primary.withOpacity(0.18 * _glowOpacity.value),
                      const Color(0xFF0A0A16),
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
              ),
            ),

            // ── Anneaux concentriques ────────────────────────────────────
            Center(child: _ring(_ring1, 130, 2.0, 0.7)),
            Center(child: _ring(_ring2, 130, 1.5, 0.5)),
            Center(child: _ring(_ring3, 130, 1.0, 0.3)),

            // ── Points décoratifs ────────────────────────────────────────
            ..._decorDots(),

            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo ────────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoCtrl]),
                    builder: (_, __) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Glow
                            AnimatedBuilder(
                              animation: _glowOpacity,
                              builder: (_, __) => Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.primary.withOpacity(0.55 * _glowOpacity.value),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Icône
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary.withOpacity(0.4),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 52),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Nom ─────────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _textCtrl,
                    builder: (_, __) => SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textOpacity,
                        child: const Text(
                          'Sellvantix',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // ── Tagline ──────────────────────────────────────────────
                  AnimatedBuilder(
                    animation: _tagOpacity,
                    builder: (_, __) => Opacity(
                      opacity: _tagOpacity.value,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(width: 20, height: 1.5, color: AppTheme.primary),
                          const SizedBox(width: 8),
                          const Text(
                            'Gérez votre commerce intelligemment',
                            style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13, letterSpacing: 0.3),
                          ),
                          const SizedBox(width: 8),
                          Container(width: 20, height: 1.5, color: AppTheme.primary),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Barre de progression en bas ──────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 60,
              child: Column(children: [
                AnimatedBuilder(
                  animation: _barCtrl,
                  builder: (_, __) {
                    final v = CurvedAnimation(parent: _barCtrl, curve: Curves.easeInOut).value;
                    return Column(children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 80),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: v,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                            minHeight: 3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        v < 0.3 ? 'Initialisation…'
                            : v < 0.7 ? 'Chargement de vos données…'
                            : 'Prêt !',
                        style: const TextStyle(color: Color(0xFF6B7280), fontSize: 11),
                      ),
                    ]);
                  },
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _decorDots() {
    final rng = Random(42);
    return List.generate(14, (i) {
      final x = rng.nextDouble() * 2 - 1;
      final y = rng.nextDouble() * 2 - 1;
      final size = 2.0 + rng.nextDouble() * 3;
      return Align(
        alignment: Alignment(x, y),
        child: AnimatedBuilder(
          animation: _glowOpacity,
          builder: (_, __) => Opacity(
            opacity: (0.1 + rng.nextDouble() * 0.2) * _glowOpacity.value,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: i % 3 == 0 ? AppTheme.primary : Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      );
    });
  }
}
