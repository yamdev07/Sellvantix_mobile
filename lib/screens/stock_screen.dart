import 'package:flutter/material.dart';
import '../core/app_theme.dart';

const _kStock = [
  (name: 'Ciment 50kg', cat: 'Ciment', qty: 45, min: 20, emoji: '🏗️', price: 4500),
  (name: 'Fer à béton 12mm', cat: 'Métallerie', qty: 120, min: 30, emoji: '⚙️', price: 2800),
  (name: 'Peinture blanche 20L', cat: 'Peinture', qty: 8, min: 10, emoji: '🎨', price: 22000),
  (name: 'Colle carrelage 25kg', cat: 'Colle', qty: 32, min: 15, emoji: '🔩', price: 8500),
  (name: 'Tuyau PVC 100mm/3m', cat: 'Plomberie', qty: 4, min: 10, emoji: '🚿', price: 3200),
  (name: 'Câble électrique 2.5mm', cat: 'Électricité', qty: 200, min: 50, emoji: '⚡', price: 1800),
  (name: 'Grillage galvanisé 50m', cat: 'Clôture', qty: 0, min: 5, emoji: '🔗', price: 35000),
  (name: 'Silicone étanchéité', cat: 'Divers', qty: 60, min: 20, emoji: '🧴', price: 2500),
];

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});
  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  bool _alertOnly = false;

  List<({String name, String cat, int qty, int min, String emoji, int price})> get _items =>
      _alertOnly ? _kStock.where((p) => p.qty <= p.min).toList() : _kStock.toList();

  int get _alertCount => _kStock.where((p) => p.qty <= p.min).length;
  int get _rupCount => _kStock.where((p) => p.qty == 0).length;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Summary cards
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(children: [
          Expanded(child: _SummaryChip(
            label: 'Total articles', value: '${_kStock.length}', icon: Icons.inventory_2_outlined, color: AppColors.primary,
          )),
          const SizedBox(width: 10),
          Expanded(child: _SummaryChip(
            label: 'En alerte', value: '$_alertCount', icon: Icons.warning_amber_rounded, color: const Color(0xFFF59E0B),
          )),
          const SizedBox(width: 10),
          Expanded(child: _SummaryChip(
            label: 'Rupture', value: '$_rupCount', icon: Icons.remove_circle_outline, color: const Color(0xFFEF4444),
          )),
        ]),
      ),
      // Filter toggle
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 2),
        child: Container(
          height: 44,
          decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
          child: Row(children: [
            _FilterBtn(label: 'Tous (${_kStock.length})', active: !_alertOnly, onTap: () => setState(() => _alertOnly = false)),
            _FilterBtn(label: 'Alertes ($_alertCount)', active: _alertOnly, onTap: () => setState(() => _alertOnly = true)),
          ]),
        ),
      ),
      // List
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
          itemCount: _items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _StockCard(item: _items[i]),
        ),
      ),
    ]);
  }
}

class _SummaryChip extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SummaryChip({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: fig(18, FontWeight.w800, c: color)),
        Text(label, style: fig(10.5, FontWeight.w600, c: AppColors.textGrey), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: active ? const [BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2))] : null,
          ),
          child: Center(child: Text(label, style: fig(13, FontWeight.w700, c: active ? AppColors.ink : AppColors.muted))),
        ),
      ),
    );
  }
}

class _StockCard extends StatelessWidget {
  final ({String name, String cat, int qty, int min, String emoji, int price}) item;
  const _StockCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final pct = item.min == 0 ? 1.0 : (item.qty / (item.min * 3)).clamp(0.0, 1.0);
    final isAlert = item.qty > 0 && item.qty <= item.min;
    final isOut = item.qty == 0;
    final barColor = isOut ? const Color(0xFFEF4444) : isAlert ? const Color(0xFFF59E0B) : AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isOut ? const Color(0x33EF4444) : isAlert ? const Color(0x33F59E0B) : AppColors.border),
      ),
      child: Row(children: [
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
          child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 22))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(item.name, style: fig(14, FontWeight.w700, c: AppColors.ink), overflow: TextOverflow.ellipsis)),
            if (isOut)
              _Badge('Rupture', const Color(0xFFEF4444))
            else if (isAlert)
              _Badge('Alerte', const Color(0xFFF59E0B)),
          ]),
          const SizedBox(height: 2),
          Text(fmtAmount(item.price), style: fig(12, FontWeight.w600, c: AppColors.textGrey)),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: pct, minHeight: 6,
                backgroundColor: AppColors.fill,
                valueColor: AlwaysStoppedAnimation(barColor),
              ),
            )),
            const SizedBox(width: 10),
            Text('${item.qty}/${item.min * 3}', style: fig(12, FontWeight.w700, c: AppColors.textMid)),
          ]),
        ])),
        if (isOut || isAlert) ...[
          const SizedBox(width: 10),
          GestureDetector(
            child: Container(
              height: 32, padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: AppColors.primarySft, borderRadius: BorderRadius.circular(99)),
              child: Center(child: Text('Commander', style: fig(12, FontWeight.w700, c: AppColors.primary))),
            ),
          ),
        ],
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20, padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(99)),
      child: Center(child: Text(text, style: fig(10.5, FontWeight.w700, c: color))),
    );
  }
}
