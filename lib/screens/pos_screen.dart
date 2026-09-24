import 'package:flutter/material.dart';
import '../core/app_theme.dart';

const _kProducts = [
  (id: 1, name: 'Ciment 50kg', cat: 'Ciment', price: 4500, stock: 45, emoji: '🏗️'),
  (id: 2, name: 'Fer à béton 12mm', cat: 'Métallerie', price: 2800, stock: 120, emoji: '⚙️'),
  (id: 3, name: 'Peinture blanche 20L', cat: 'Peinture', price: 22000, stock: 8, emoji: '🎨'),
  (id: 4, name: 'Colle carrelage 25kg', cat: 'Colle', price: 8500, stock: 32, emoji: '🔩'),
  (id: 5, name: 'Tuyau PVC 100mm/3m', cat: 'Plomberie', price: 3200, stock: 25, emoji: '🚿'),
  (id: 6, name: 'Câble électrique 2.5mm', cat: 'Électricité', price: 1800, stock: 200, emoji: '⚡'),
  (id: 7, name: 'Grillage galvanisé 50m', cat: 'Clôture', price: 35000, stock: 12, emoji: '🔗'),
  (id: 8, name: 'Silicone étanchéité', cat: 'Divers', price: 2500, stock: 60, emoji: '🧴'),
];

const _kCats = ['Tous', 'Ciment', 'Métallerie', 'Peinture', 'Plomberie', 'Électricité'];

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final Map<int, int> _cart = {};
  String _cat = 'Tous';
  String _q = '';
  final _ctrl = TextEditingController();

  List<({int id, String name, String cat, int price, int stock, String emoji})> get _filtered =>
      _kProducts.where((p) {
        final catOk = _cat == 'Tous' || p.cat == _cat;
        final qOk = _q.isEmpty || p.name.toLowerCase().contains(_q.toLowerCase());
        return catOk && qOk;
      }).toList();

  int get _totalQty => _cart.values.fold(0, (a, b) => a + b);
  int get _totalPrice => _cart.entries.fold(0, (acc, e) {
    final p = _kProducts.firstWhere((p) => p.id == e.key);
    return acc + p.price * e.value;
  });

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        // Search
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Container(
            height: 46,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.inputBdr)),
            child: Row(children: [
              const SizedBox(width: 12),
              const Icon(Icons.search, color: AppColors.muted, size: 20),
              const SizedBox(width: 8),
              Expanded(child: TextField(
                controller: _ctrl,
                onChanged: (v) => setState(() => _q = v),
                style: fig(14, FontWeight.w500, c: AppColors.ink),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Rechercher un produit…',
                  hintStyle: fig(14, FontWeight.w400, c: AppColors.muted),
                  isDense: true,
                ),
              )),
              if (_q.isNotEmpty) GestureDetector(
                onTap: () { _ctrl.clear(); setState(() => _q = ''); },
                child: const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.close, size: 18, color: AppColors.muted)),
              ),
            ]),
          ),
        ),
        // Category chips
        SizedBox(
          height: 48,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            scrollDirection: Axis.horizontal,
            itemCount: _kCats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final active = _cat == _kCats[i];
              return GestureDetector(
                onTap: () => setState(() => _cat = _kCats[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(99),
                    border: Border.all(color: active ? AppColors.primary : AppColors.border),
                  ),
                  child: Center(child: Text(_kCats[i], style: fig(12, FontWeight.w700, c: active ? Colors.white : AppColors.textGrey))),
                ),
              );
            },
          ),
        ),
        // Grid
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.fromLTRB(20, 4, 20, _cart.isNotEmpty ? 86 : 20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.82,
            ),
            itemCount: _filtered.length,
            itemBuilder: (_, i) => _ProductCard(
              product: _filtered[i],
              qty: _cart[_filtered[i].id] ?? 0,
              onAdd: () => setState(() => _cart[_filtered[i].id] = (_cart[_filtered[i].id] ?? 0) + 1),
              onRemove: () => setState(() {
                final q = (_cart[_filtered[i].id] ?? 0) - 1;
                if (q <= 0) _cart.remove(_filtered[i].id); else _cart[_filtered[i].id] = q;
              }),
            ),
          ),
        ),
      ]),
      // Cart bar
      if (_cart.isNotEmpty)
        Positioned(
          bottom: 20, left: 20, right: 20,
          child: GestureDetector(
            onTap: () => _showPaySheet(context),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Color(0x55E8590C), blurRadius: 20, offset: Offset(0, 8))],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Row(children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                    child: Center(child: Text('$_totalQty', style: fig(13, FontWeight.w800, c: Colors.white))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Panier', style: fig(15, FontWeight.w700, c: Colors.white))),
                  Text(fmtAmount(_totalPrice), style: fig(16, FontWeight.w800, c: Colors.white)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ]),
              ),
            ),
          ),
        ),
    ]);
  }

  void _showPaySheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PaySheet(cart: _cart, total: _totalPrice, onPaid: () {
        setState(() => _cart.clear());
        Navigator.pop(ctx);
      }),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ({int id, String name, String cat, int price, int stock, String emoji}) product;
  final int qty;
  final VoidCallback onAdd, onRemove;
  const _ProductCard({required this.product, required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: qty > 0 ? AppColors.primary : AppColors.border, width: qty > 0 ? 2 : 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(12)),
            child: Center(child: Text(product.emoji, style: const TextStyle(fontSize: 22))),
          ),
          const SizedBox(height: 10),
          Text(product.name, style: fig(13, FontWeight.w700, c: AppColors.ink), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(fmtAmount(product.price), style: fig(14, FontWeight.w800, c: AppColors.primary)),
          const Spacer(),
          Row(children: [
            Text('Stock: ${product.stock}', style: fig(11, FontWeight.w500, c: AppColors.muted)),
            const Spacer(),
            if (qty == 0)
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 30, height: 30,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              )
            else
              Row(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(onTap: onRemove, child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.remove, size: 14, color: AppColors.primaryDk),
                )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Text('$qty', style: fig(14, FontWeight.w800, c: AppColors.primary)),
                ),
                GestureDetector(onTap: onAdd, child: Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                  child: const Icon(Icons.add, size: 14, color: Colors.white),
                )),
              ]),
          ]),
        ]),
      ),
    );
  }
}

// ── Payment bottom sheet ───────────────────────────────────────────────────────
class _PaySheet extends StatefulWidget {
  final Map<int, int> cart;
  final int total;
  final VoidCallback onPaid;
  const _PaySheet({required this.cart, required this.total, required this.onPaid});

  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  String _mode = 'cash';
  bool _paying = false;

  static const _modes = [
    (id: 'cash', label: 'Espèces', icon: Icons.payments_outlined),
    (id: 'momo', label: 'MoMo', icon: Icons.phone_android_outlined),
    (id: 'wave', label: 'Wave', icon: Icons.waves_outlined),
    (id: 'credit', label: 'Crédit', icon: Icons.account_balance_wallet_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 16),
          Expanded(child: ListView(controller: ctl, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            Text('Paiement', style: fig(20, FontWeight.w800, c: AppColors.ink)),
            const SizedBox(height: 16),
            // Cart items
            for (final e in widget.cart.entries) ...[
              _CartRow(productId: e.key, qty: e.value),
              const SizedBox(height: 8),
            ],
            const Divider(color: AppColors.listBdr, height: 24),
            Row(children: [
              Text('Total', style: fig(16, FontWeight.w700, c: AppColors.ink)),
              const Spacer(),
              Text(fmtAmount(widget.total), style: fig(20, FontWeight.w800, c: AppColors.primary)),
            ]),
            const SizedBox(height: 20),
            Text('Mode de paiement', style: fig(14, FontWeight.w700, c: AppColors.ink)),
            const SizedBox(height: 12),
            Row(children: _modes.map((m) {
              final act = _mode == m.id;
              return Expanded(child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _mode = m.id),
                  child: Container(
                    height: 62,
                    decoration: BoxDecoration(
                      color: act ? AppColors.primarySft : AppColors.fill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: act ? AppColors.primary : Colors.transparent, width: 2),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(m.icon, size: 20, color: act ? AppColors.primary : AppColors.textGrey),
                      const SizedBox(height: 4),
                      Text(m.label, style: fig(11, FontWeight.w700, c: act ? AppColors.primary : AppColors.textGrey)),
                    ]),
                  ),
                ),
              ));
            }).toList()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _paying ? null : () async {
                setState(() => _paying = true);
                await Future.delayed(const Duration(milliseconds: 800));
                widget.onPaid();
              },
              child: _paying
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('Encaisser ${fmtAmount(widget.total)}'),
            ),
            const SizedBox(height: 24),
          ])),
        ]),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final int productId, qty;
  const _CartRow({required this.productId, required this.qty});

  @override
  Widget build(BuildContext context) {
    final p = _kProducts.firstWhere((p) => p.id == productId);
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(p.emoji, style: const TextStyle(fontSize: 18))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: fig(13, FontWeight.w700, c: AppColors.ink), overflow: TextOverflow.ellipsis),
        Text('×$qty', style: fig(12, FontWeight.w500, c: AppColors.textGrey)),
      ])),
      Text(fmtAmount(p.price * qty), style: fig(14, FontWeight.w700, c: AppColors.ink)),
    ]);
  }
}
