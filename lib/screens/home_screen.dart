import 'dart:math' show pi;
import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: const [
        _SalesCard(),
        SizedBox(height: 16),
        _Row2(),
        SizedBox(height: 16),
        _AiTip(),
        SizedBox(height: 16),
        _TodoCard(),
      ],
    );
  }
}

// ── Hero sales card ────────────────────────────────────────────────────────────
class _SalesCard extends StatelessWidget {
  const _SalesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDk],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(color: Color(0x55E8590C), blurRadius: 24, offset: Offset(0, 10)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Aujourd\'hui', style: fig(13, FontWeight.w600, c: Colors.white70)),
          const Spacer(),
          Container(
            height: 28, padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
            child: Center(child: Text('Mer 24', style: fig(12, FontWeight.w700, c: Colors.white))),
          ),
        ]),
        const SizedBox(height: 6),
        Text(fmtAmount(184500), style: fig(40, FontWeight.w800, c: Colors.white, ls: -1)),
        const SizedBox(height: 2),
        Text('Chiffre d\'affaires du jour', style: fig(13, FontWeight.w500, c: Colors.white70)),
        const SizedBox(height: 18),
        Row(children: [
          _StatChip(label: '12 Ventes', icon: Icons.receipt_outlined),
          const SizedBox(width: 10),
          _StatChip(label: '8 Articles', icon: Icons.inventory_2_outlined),
          const SizedBox(width: 10),
          _StatChip(label: '+18%', icon: Icons.trending_up_rounded),
        ]),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  const _StatChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32, padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 5),
        Text(label, style: fig(12, FontWeight.w700, c: Colors.white)),
      ]),
    );
  }
}

// ── Row 2: health ring + top products ─────────────────────────────────────────
class _Row2 extends StatelessWidget {
  const _Row2();

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _HealthCard()),
      const SizedBox(width: 12),
      Expanded(child: _TopProducts()),
    ]);
  }
}

class _HealthCard extends StatelessWidget {
  const _HealthCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Text('Santé stock', style: fig(13, FontWeight.w700, c: AppColors.ink)),
        const SizedBox(height: 14),
        SizedBox(
          width: 80, height: 80,
          child: CustomPaint(painter: _RingPainter(0.72), child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('72%', style: fig(17, FontWeight.w800, c: AppColors.ink)),
              Text('OK', style: fig(11, FontWeight.w600, c: AppColors.textGrey)),
            ]),
          )),
        ),
        const SizedBox(height: 14),
        _RingLegend(color: AppColors.primary, label: 'Normal', value: '18'),
        const SizedBox(height: 6),
        _RingLegend(color: const Color(0xFFF59E0B), label: 'Alerte', value: '5'),
        const SizedBox(height: 6),
        _RingLegend(color: const Color(0xFFEF4444), label: 'Rupture', value: '2'),
      ]),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  const _RingPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2, r = size.width / 2 - 7;
    final bg = Paint()
      ..color = AppColors.fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(Offset(cx, cy), r, bg);
    final fg = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2, 2 * pi * progress, false, fg,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RingLegend extends StatelessWidget {
  final Color color;
  final String label;
  final String value;
  const _RingLegend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Expanded(child: Text(label, style: fig(12, FontWeight.w600, c: AppColors.textMid))),
      Text(value, style: fig(12, FontWeight.w700, c: AppColors.ink)),
    ]);
  }
}

class _TopProducts extends StatelessWidget {
  const _TopProducts();
  static const _items = [
    ('Ciment 50kg', '45 000 F', '8'),
    ('Fer 12mm', '28 500 F', '5'),
    ('Peinture 20L', '22 000 F', '3'),
    ('Colle carrelage', '8 500 F', '12'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Top produits', style: fig(13, FontWeight.w700, c: AppColors.ink)),
        const SizedBox(height: 14),
        for (int i = 0; i < _items.length; i++) ...[
          if (i > 0) const Divider(height: 14, thickness: 1, color: AppColors.listBdr),
          _TopRow(rank: i + 1, name: _items[i].$1, price: _items[i].$2, qty: _items[i].$3),
        ],
      ]),
    );
  }
}

class _TopRow extends StatelessWidget {
  final int rank;
  final String name, price, qty;
  const _TopRow({required this.rank, required this.name, required this.price, required this.qty});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: rank == 1 ? AppColors.primarySft : AppColors.listBdr,
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(
          '$rank',
          style: fig(10, FontWeight.w800, c: rank == 1 ? AppColors.primary : AppColors.textGrey),
        )),
      ),
      const SizedBox(width: 8),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: fig(12, FontWeight.w700, c: AppColors.ink), overflow: TextOverflow.ellipsis),
        Text(price, style: fig(11, FontWeight.w600, c: AppColors.textGrey)),
      ])),
      Text('×$qty', style: fig(12, FontWeight.w700, c: AppColors.primary)),
    ]);
  }
}

// ── AI Tip card ────────────────────────────────────────────────────────────────
class _AiTip extends StatelessWidget {
  const _AiTip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFFD4BB)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 38, height: 38,
          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Conseil IA', style: fig(12, FontWeight.w700, c: AppColors.primary)),
          const SizedBox(height: 4),
          Text(
            'Le stock de Ciment 50kg sera épuisé dans ~4 jours. Commandez 20 sacs pour éviter la rupture en fin de semaine.',
            style: fig(13, FontWeight.w500, c: AppColors.ink),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            child: Container(
              height: 32, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(99)),
              child: Center(child: Text('Commander maintenant', style: fig(12, FontWeight.w700, c: Colors.white))),
            ),
          ),
        ])),
      ]),
    );
  }
}

// ── Todo card ──────────────────────────────────────────────────────────────────
class _TodoCard extends StatelessWidget {
  const _TodoCard();
  static const _todos = [
    (true, 'Valider la livraison du matin'),
    (true, 'Mettre à jour le prix du fer'),
    (false, 'Appeler fournisseur Ciment'),
    (false, 'Préparer facture client Koné'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('À faire', style: fig(15, FontWeight.w700, c: AppColors.ink)),
          const Spacer(),
          Text('2/4', style: fig(13, FontWeight.w600, c: AppColors.textGrey)),
        ]),
        const SizedBox(height: 14),
        for (int i = 0; i < _todos.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _TodoRow(done: _todos[i].$1, text: _todos[i].$2),
        ],
      ]),
    );
  }
}

class _TodoRow extends StatelessWidget {
  final bool done;
  final String text;
  const _TodoRow({required this.done, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: done ? AppColors.primary : Colors.transparent,
          border: Border.all(color: done ? AppColors.primary : AppColors.disabled, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 13) : null,
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(
        text,
        style: fig(14, FontWeight.w500, c: done ? AppColors.muted : AppColors.ink),
      )),
    ]);
  }
}
