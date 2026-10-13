import 'dart:math' show sin, pi;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../widgets/brand_mark.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Entrée : logo puis texte ──────────────────────────────────────────────
  late final AnimationController _introCtrl = AnimationController(
    duration: const Duration(milliseconds: 1100),
    vsync: this,
  );
  late final Animation<double> _logoScale = Tween<double>(begin: 0.6, end: 1).animate(
    CurvedAnimation(parent: _introCtrl, curve: const Interval(0, 0.55, curve: Curves.easeOutBack)),
  );
  late final Animation<double> _logoOpacity = CurvedAnimation(
    parent: _introCtrl,
    curve: const Interval(0, 0.35, curve: Curves.easeOut),
  );
  late final Animation<double> _textOpacity = CurvedAnimation(
    parent: _introCtrl,
    curve: const Interval(0.35, 0.8, curve: Curves.easeOut),
  );
  late final Animation<Offset> _textSlide = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _introCtrl, curve: const Interval(0.35, 0.8, curve: Curves.easeOutCubic)));
  late final Animation<double> _tagOpacity = CurvedAnimation(
    parent: _introCtrl,
    curve: const Interval(0.6, 1, curve: Curves.easeOut),
  );

  // ── Indicateur 3 points (boucle) ──────────────────────────────────────────
  late final AnimationController _dotsCtrl = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  );

  // ── Sortie ────────────────────────────────────────────────────────────────
  late final AnimationController _exitCtrl = AnimationController(
    duration: const Duration(milliseconds: 350),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    _run();
  }

  Future<void> _run() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;
    _introCtrl.forward();
    _dotsCtrl.repeat();
    await Future.delayed(const Duration(milliseconds: 1700));
    if (!mounted) return;
    await _exitCtrl.forward();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, __, ___) => widget.nextScreen,
      transitionDuration: const Duration(milliseconds: 400),
      transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
    ));
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _dotsCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDk],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1, end: 0).animate(_exitCtrl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              const BrandBackdrop(),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FadeTransition(
                      opacity: _logoOpacity,
                      child: ScaleTransition(scale: _logoScale, child: const BrandMark(size: 92)),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _textOpacity,
                      child: SlideTransition(
                        position: _textSlide,
                        child: Text('Sellvantix', style: fig(36, FontWeight.w800, c: Colors.white, ls: -1.2)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    FadeTransition(
                      opacity: _tagOpacity,
                      child: Text(
                        'Votre boutique, simplement.',
                        style: fig(14, FontWeight.w500, c: const Color(0xD9FFFFFF)),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 72,
                child: FadeTransition(opacity: _tagOpacity, child: _Dots(ctrl: _dotsCtrl)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final AnimationController ctrl;
  const _Dots({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: ctrl,
      builder: (_, __) => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (i) {
          // Chaque point pulse avec un décalage de phase.
          final t = (sin((ctrl.value - i * 0.18) * 2 * pi) + 1) / 2;
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.lerp(const Color(0x59FFFFFF), Colors.white, t),
            ),
          );
        }),
      ),
    );
  }
}
