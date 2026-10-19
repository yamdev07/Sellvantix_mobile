import 'dart:math' show pi;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/dashboard_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DashboardProvider>().fetch());
  }

  @override
  Widget build(BuildContext context) {
    final db = context.watch<DashboardProvider>();

    if (db.loading && db.data == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => context.read<DashboardProvider>().fetch(),
      child: ColoredBox(
        color: context.sc,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            _SalesCard(db: db),
            const SizedBox(height: 16),
            _Row2(db: db),
            const SizedBox(height: 16),
            _AiTip(db: db),
            const SizedBox(height: 16),
            _RecentSales(db: db),
          ],
        ),
      ),
    );
  }
}

// ── Hero sales card ────────────────────────────────────────────────────────────
class _SalesCard extends StatelessWidget {
  final DashboardProvider db;
  const _SalesCard({required this.db});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final dayLabel = '${days[now.weekday - 1]} ${now.day}';

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
            child: Center(child: Text(dayLabel, style: fig(12, FontWeight.w700, c: Colors.white))),
          ),
        ]),
        const SizedBox(height: 6),
        Text(fmtAmount(db.todayRevenue.round()), style: fig(40, FontWeight.w800, c: Colors.white, ls: -1)),
        const SizedBox(height: 2),
        Text('Chiffre d\'affaires du jour', style: fig(13, FontWeight.w500, c: Colors.white70)),
        const SizedBox(height: 18),
        Row(children: [
          _StatChip(label: '${db.todaySales} Ventes', icon: Icons.receipt_outlined),
          const SizedBox(width: 10),
          _StatChip(label: '${db.totalProducts} Produits', icon: Icons.inventory_2_outlined),
          if (db.outOfStock > 0) ...[
            const SizedBox(width: 10),
            _StatChip(label: '${db.outOfStock} Ruptures', icon: Icons.warning_amber_rounded, red: true),
          ],
        ]),
      ]),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool red;
  const _StatChip({required this.label, required this.icon, this.red = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32, padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: red ? Colors.red.withOpacity(0.25) : Colors.white24,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white, size: 14),
        const SizedBox(width: 5),
        Text(label, style: fig(12, FontWeight.w700, c: Colors.white)),
      ]),
    );
  }
}

// ── Row 2: stock health + top produits ────────────────────────────────────────
class _Row2 extends StatelessWidget {
  final DashboardProvider db;
  const _Row2({required this.db});

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: _HealthCard(db: db)),
      const SizedBox(width: 12),
      Expanded(child: _LowStockCard(db: db)),
    ]);
  }
}

class _HealthCard extends StatelessWidget {
  final DashboardProvider db;
  const _HealthCard({required this.db});

  @override
  Widget build(BuildContext context) {
    final total   = db.totalProducts;
    final rupture = db.outOfStock;
    final alerte  = db.lowStock.length;
    final normal  = (total - rupture - alerte).clamp(0, total);
    final pct     = total > 0 ? (normal / total) : 1.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderC),
      ),
      child: Column(children: [
        Text('Santé stock', style: fig(13, FontWeight.w700, c: context.ink)),
        const SizedBox(height: 14),
        SizedBox(
          width: 80, height: 80,
          child: CustomPaint(painter: _RingPainter(pct), child: Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text('${(pct * 100).round()}%', style: fig(17, FontWeight.w800, c: context.ink)),
              Text('OK', style: fig(11, FontWeight.w600, c: context.textGr)),
            ]),
          )),
        ),
        const SizedBox(height: 14),
        _RingLegend(color: AppColors.primary,         label: 'Normal',  value: '$normal'),
        const SizedBox(height: 6),
        _RingLegend(color: const Color(0xFFF59E0B), label: 'Alerte',  value: '$alerte'),
        const SizedBox(height: 6),
        _RingLegend(color: const Color(0xFFEF4444), label: 'Rupture', value: '$rupture'),
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
    canvas.drawCircle(Offset(cx, cy), r, Paint()
      ..color = AppColors.fill
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2, 2 * pi * progress, false,
      Paint()
        ..color = AppColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RingLegend extends StatelessWidget {
  final Color color;
  final String label, value;
  const _RingLegend({required this.color, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Expanded(child: Text(label, style: fig(12, FontWeight.w600, c: context.textMd))),
      Text(value, style: fig(12, FontWeight.w700, c: context.ink)),
    ]);
  }
}

class _LowStockCard extends StatelessWidget {
  final DashboardProvider db;
  const _LowStockCard({required this.db});

  @override
  Widget build(BuildContext context) {
    final items = db.lowStock;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderC),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Stock critique', style: fig(13, FontWeight.w700, c: context.ink)),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text('Tout est OK ✓', style: fig(13, FontWeight.w600, c: AppColors.success)),
          ))
        else
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 14, thickness: 1, color: context.listBdrC),
            Row(children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(
                '${items[i]['name']}',
                style: fig(12, FontWeight.w700, c: context.ink),
                overflow: TextOverflow.ellipsis,
              )),
              Text('${items[i]['stock']}', style: fig(12, FontWeight.w700, c: const Color(0xFFEF4444))),
            ]),
          ],
      ]),
    );
  }
}

// ── AI Tip card ────────────────────────────────────────────────────────────────
class _AiTip extends StatelessWidget {
  final DashboardProvider db;
  const _AiTip({required this.db});

  @override
  Widget build(BuildContext context) {
    final urgence = db.conseilUrgence;
    final bgColor = urgence == 'high'
        ? const Color(0xFFFFF1F0)
        : AppColors.primarySft;
    final borderColor = urgence == 'high'
        ? const Color(0xFFFFCDD2)
        : const Color(0xFFFFD4BB);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
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
          Text(db.conseilMessage, style: fig(13, FontWeight.w500, c: AppColors.ink)),
          if (db.conseilAction != null) ...[
            const SizedBox(height: 10),
            Container(
              height: 32, padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(99)),
              child: Center(child: Text(db.conseilAction!, style: fig(12, FontWeight.w700, c: Colors.white))),
            ),
          ],
        ])),
      ]),
    );
  }
}

// ── Ventes récentes ────────────────────────────────────────────────────────────
class _RecentSales extends StatelessWidget {
  final DashboardProvider db;
  const _RecentSales({required this.db});

  @override
  Widget build(BuildContext context) {
    final sales = db.recentSales;
    if (sales.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.borderC),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('Ventes récentes', style: fig(15, FontWeight.w700, c: context.ink)),
          const Spacer(),
          Text('${sales.length} dernières', style: fig(12, FontWeight.w500, c: context.textGr)),
        ]),
        const SizedBox(height: 14),
        for (int i = 0; i < sales.length; i++) ...[
          if (i > 0) Divider(height: 14, color: context.listBdrC),
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: context.fillC, borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.receipt_outlined, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${sales[i]['client']}', style: fig(13, FontWeight.w700, c: context.ink), overflow: TextOverflow.ellipsis),
              Text('${sales[i]['date']}', style: fig(11, FontWeight.w500, c: context.textGr)),
            ])),
            Text(fmtAmount((sales[i]['total'] as num).round()), style: fig(14, FontWeight.w700, c: AppColors.primary)),
          ]),
        ],
      ]),
    );
  }
}
