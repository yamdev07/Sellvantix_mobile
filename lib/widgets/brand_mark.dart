import 'package:flutter/material.dart';
import '../core/app_theme.dart';

/// Monogramme Sellvantix : « S » orange dans un carré blanc arrondi.
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.3),
        boxShadow: const [
          BoxShadow(color: Color(0x33000000), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Text(
        'S',
        style: fig(size * 0.58, FontWeight.w900, c: AppColors.primary, ls: -1),
      ),
    );
  }
}

/// Cercles décoratifs discrets, en blanc translucide, pour les fonds orange.
class BrandBackdrop extends StatelessWidget {
  const BrandBackdrop({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Stack(
        children: [
          Positioned(top: -120, right: -90, child: _Circle(size: 300, alpha: 0x14)),
          Positioned(top: 60, right: -40, child: _Circle(size: 140, alpha: 0x0F)),
          Positioned(bottom: -80, left: -110, child: _Circle(size: 260, alpha: 0x0F)),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  final double size;
  final int alpha;
  const _Circle({required this.size, required this.alpha});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.fromARGB(alpha, 255, 255, 255),
      ),
    );
  }
}
