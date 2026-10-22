import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../services/sound_service.dart';

// ── Model léger pour le POS ───────────────────────────────────────────────────
class _PosProduct {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String? barcode;
  final String? unit;
  final String initials;

  const _PosProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    this.barcode,
    this.unit,
    required this.initials,
  });

  factory _PosProduct.fromJson(Map<String, dynamic> j) => _PosProduct(
    id:       j['id'] as int,
    name:     j['name'] as String,
    price:    (j['price'] as num).toDouble(),
    stock:    (j['stock'] as num).toInt(),
    barcode:  j['barcode'] as String?,
    unit:     j['unit'] as String?,
    initials: (j['initials'] as String?) ?? (j['name'] as String)[0].toUpperCase(),
  );
}

// ── Screen principal ──────────────────────────────────────────────────────────
class PosScreen extends StatefulWidget {
  const PosScreen({super.key});
  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<_PosProduct> _products = [];
  bool _loading = true;
  String _q = '';
  final _ctrl = TextEditingController();

  // Panier : productId → {qty, product}
  final Map<int, ({int qty, _PosProduct product})> _cart = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _load({String q = ''}) async {
    setState(() => _loading = true);
    try {
      final path = q.isEmpty ? '/products' : '/products?q=${Uri.encodeComponent(q)}';
      final res  = await ApiClient.get(path) as List;
      setState(() {
        _products = res.map((j) => _PosProduct.fromJson(j as Map<String, dynamic>)).toList();
        _loading  = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  List<_PosProduct> get _filtered => _q.isEmpty
      ? _products
      : _products.where((p) =>
          p.name.toLowerCase().contains(_q.toLowerCase()) ||
          (p.barcode?.contains(_q) ?? false)).toList();

  int get _totalQty => _cart.values.fold(0, (a, b) => a + b.qty);
  double get _totalPrice => _cart.values.fold(0.0, (a, b) => a + b.product.price * b.qty);

  void _add(_PosProduct p) {
    setState(() {
      final cur = _cart[p.id];
      _cart[p.id] = (qty: (cur?.qty ?? 0) + 1, product: p);
    });
  }

  void _remove(int id) {
    setState(() {
      final cur = _cart[id];
      if (cur == null) return;
      if (cur.qty <= 1) { _cart.remove(id); } else { _cart[id] = (qty: cur.qty - 1, product: cur.product); }
    });
  }

  // ── Scan barcode ─────────────────────────────────────────────────────────────
  Future<void> _openScanner() async {
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const _ScannerPage()),
    );
    if (code == null || !mounted) return;
    await _handleBarcode(code);
  }

  Future<void> _handleBarcode(String code) async {
    // 1. Cherche dans les produits déjà chargés
    final local = _products.where((p) => p.barcode == code).firstOrNull;
    if (local != null) { _add(local); return; }

    // 2. Appel API
    try {
      final res = await ApiClient.get('/products/barcode/${Uri.encodeComponent(code)}');
      final p   = _PosProduct.fromJson(res as Map<String, dynamic>);
      if (!_products.any((x) => x.id == p.id)) {
        setState(() => _products.insert(0, p));
      }
      _add(p);
    } on ApiException catch (e) {
      if (e.statusCode == 404 && mounted) {
        _showCreateProduct(barcode: code);
      }
    } catch (_) {
      if (mounted) _showCreateProduct(barcode: code);
    }
  }

  void _showCreateProduct({String? barcode}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CreateProductSheet(
        barcode: barcode,
        onCreated: (p) {
          setState(() => _products.insert(0, p));
          _add(p);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Column(children: [
        // Search + scan
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Row(children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: context.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderC),
                ),
                child: Row(children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: context.textGr, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: TextField(
                    controller: _ctrl,
                    onChanged: (v) { setState(() => _q = v); if (v.isEmpty) _load(); },
                    onSubmitted: (v) => _load(q: v),
                    style: fig(14, FontWeight.w500, c: context.ink),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Rechercher un produit…',
                      hintStyle: fig(14, FontWeight.w400, c: context.textGr),
                      isDense: true,
                    ),
                  )),
                  if (_q.isNotEmpty)
                    GestureDetector(
                      onTap: () { _ctrl.clear(); setState(() => _q = ''); _load(); },
                      child: Padding(padding: const EdgeInsets.all(10), child: Icon(Icons.close, size: 18, color: context.textGr)),
                    ),
                ]),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _openScanner,
              child: Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 24),
              ),
            ),
          ]),
        ),

        const SizedBox(height: 10),

        if (_loading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_filtered.isEmpty)
          Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: context.textGr),
            const SizedBox(height: 12),
            Text('Aucun produit', style: fig(15, FontWeight.w600, c: context.textGr)),
            if (_q.isNotEmpty) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _showCreateProduct(barcode: _q.length > 6 ? _q : null),
                icon: const Icon(Icons.add_circle_outline, size: 18),
                label: const Text('Créer ce produit'),
              ),
            ],
          ])))
        else
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.fromLTRB(16, 4, 16, _cart.isNotEmpty ? 90 : 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 0.82,
              ),
              itemCount: _filtered.length,
              itemBuilder: (_, i) {
                final p = _filtered[i];
                final qty = _cart[p.id]?.qty ?? 0;
                return _ProductCard(
                  product: p, qty: qty,
                  onAdd: () => _add(p),
                  onRemove: () => _remove(p.id),
                );
              },
            ),
          ),
      ]),

      // Cart bar
      if (_cart.isNotEmpty)
        Positioned(
          bottom: 20, left: 16, right: 16,
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
                  Text(fmtAmount(_totalPrice.toInt()), style: fig(16, FontWeight.w800, c: Colors.white)),
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
      builder: (_) => _PaySheet(
        cart: _cart,
        total: _totalPrice,
        onPaid: () {
          setState(() => _cart.clear());
          Navigator.pop(ctx);
          _load();
        },
      ),
    );
  }
}

// ── Scanner page ──────────────────────────────────────────────────────────────
class _ScannerPage extends StatefulWidget {
  const _ScannerPage();
  @override
  State<_ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<_ScannerPage> {
  bool _scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scanner un article'),
      ),
      body: Stack(children: [
        MobileScanner(
          onDetect: (capture) {
            if (_scanned) return;
            final code = capture.barcodes.firstOrNull?.rawValue;
            if (code != null && code.isNotEmpty) {
              _scanned = true;
              HapticFeedback.mediumImpact();
              Navigator.pop(context, code);
            }
          },
        ),
        // Viseur
        Center(
          child: Container(
            width: 240, height: 240,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 3),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        Positioned(
          bottom: 40, left: 0, right: 0,
          child: Text(
            'Pointez la caméra vers le code-barres',
            textAlign: TextAlign.center,
            style: fig(14, FontWeight.w600, c: Colors.white),
          ),
        ),
      ]),
    );
  }
}

// ── Product card ──────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final _PosProduct product;
  final int qty;
  final VoidCallback onAdd, onRemove;
  const _ProductCard({required this.product, required this.qty, required this.onAdd, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock <= 0;
    return Container(
      decoration: BoxDecoration(
        color: context.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: qty > 0 ? AppColors.primary : context.borderC,
          width: qty > 0 ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: context.fillC, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(product.initials, style: fig(16, FontWeight.w800, c: AppColors.primary))),
          ),
          const SizedBox(height: 8),
          Text(product.name, style: fig(13, FontWeight.w700, c: context.ink), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(fmtAmount(product.price.toInt()), style: fig(14, FontWeight.w800, c: AppColors.primary)),
          const Spacer(),
          Row(children: [
            Text(
              outOfStock ? 'Rupture' : 'Stock: ${product.stock}',
              style: fig(11, FontWeight.w500, c: outOfStock ? Colors.red : context.mutedC),
            ),
            const Spacer(),
            if (outOfStock)
              Icon(Icons.block, size: 20, color: Colors.red.withOpacity(.4))
            else if (qty == 0)
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
                  decoration: BoxDecoration(color: context.fillC, borderRadius: BorderRadius.circular(6)),
                  child: Icon(Icons.remove, size: 14, color: AppColors.primaryDk),
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

// ── Créer produit (scan inconnu) ──────────────────────────────────────────────
class _CreateProductSheet extends StatefulWidget {
  final String? barcode;
  final void Function(_PosProduct) onCreated;
  const _CreateProductSheet({this.barcode, required this.onCreated});
  @override
  State<_CreateProductSheet> createState() => _CreateProductSheetState();
}

class _CreateProductSheetState extends State<_CreateProductSheet> {
  final _nameCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _buyCtrl   = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _alertCtrl = TextEditingController();
  bool _saving = false;
  String? _err;

  @override
  void initState() {
    super.initState();
    _alertCtrl.text = '5';
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _priceCtrl.dispose();
    _buyCtrl.dispose();  _stockCtrl.dispose(); _alertCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name  = _nameCtrl.text.trim();
    final price = double.tryParse(_priceCtrl.text.replaceAll(' ', ''));
    final stock = int.tryParse(_stockCtrl.text.trim()) ?? 0;

    if (name.isEmpty || price == null || price <= 0) {
      setState(() => _err = 'Nom et prix de vente requis.');
      return;
    }

    setState(() { _saving = true; _err = null; });
    try {
      final res = await ApiClient.post('/products', {
        'name':           name,
        'sale_price':     price,
        'purchase_price': double.tryParse(_buyCtrl.text.replaceAll(' ', '')) ?? 0,
        'stock':          stock,
        'stock_alert':    int.tryParse(_alertCtrl.text.trim()) ?? 5,
        if (widget.barcode != null) 'barcode': widget.barcode,
      });
      final p = _PosProduct.fromJson(res as Map<String, dynamic>);
      if (mounted) {
        Navigator.pop(context);
        widget.onCreated(p);
      }
    } catch (e) {
      setState(() { _err = 'Erreur lors de la création.'; _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: context.borderC, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 16),
          Text('Nouvel article', style: fig(18, FontWeight.w800, c: context.ink)),
          if (widget.barcode != null) ...[
            const SizedBox(height: 4),
            Text('Code-barres : ${widget.barcode}', style: fig(12, FontWeight.w500, c: context.textGr)),
          ],
          const SizedBox(height: 20),
          _field(context, 'Nom de l\'article *', _nameCtrl, TextInputType.text),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(context, 'Prix de vente * (FCFA)', _priceCtrl, const TextInputType.numberWithOptions(decimal: true))),
            const SizedBox(width: 10),
            Expanded(child: _field(context, 'Prix d\'achat (FCFA)', _buyCtrl, const TextInputType.numberWithOptions(decimal: true))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: _field(context, 'Quantité en stock', _stockCtrl, TextInputType.number)),
            const SizedBox(width: 10),
            Expanded(child: _field(context, 'Seuil d\'alerte', _alertCtrl, TextInputType.number)),
          ]),
          if (_err != null) ...[
            const SizedBox(height: 10),
            Text(_err!, style: fig(13, FontWeight.w600, c: Colors.red)),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _saving
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('Créer et ajouter au panier', style: fig(15, FontWeight.w700, c: Colors.white)),
            ),
          ),
        ])),
      ),
    );
  }

  Widget _field(BuildContext ctx, String hint, TextEditingController ctrl, TextInputType kb) {
    return TextField(
      controller: ctrl,
      keyboardType: kb,
      style: fig(14, FontWeight.w600, c: ctx.ink),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: fig(13, FontWeight.w400, c: ctx.textGr),
        filled: true,
        fillColor: ctx.fillC,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: ctx.borderC)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: ctx.borderC)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
      ),
    );
  }
}

// ── Payment sheet ─────────────────────────────────────────────────────────────
class _PaySheet extends StatefulWidget {
  final Map<int, ({int qty, _PosProduct product})> cart;
  final double total;
  final VoidCallback onPaid;
  const _PaySheet({required this.cart, required this.total, required this.onPaid});
  @override
  State<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends State<_PaySheet> {
  String _mode = 'cash';
  bool _paying = false;

  static const _modes = [
    (id: 'cash',   label: 'Espèces',  icon: Icons.payments_outlined),
    (id: 'momo',   label: 'MoMo',     icon: Icons.phone_android_outlined),
    (id: 'wave',   label: 'Wave',     icon: Icons.waves_outlined),
    (id: 'credit', label: 'Crédit',   icon: Icons.account_balance_wallet_outlined),
  ];

  Future<void> _pay() async {
    setState(() => _paying = true);
    try {
      final items = widget.cart.values.map((e) => {
        'product_id': e.product.id,
        'quantity':   e.qty,
        'unit_price': e.product.price,
      }).toList();

      await ApiClient.post('/sales', {
        'items':          items,
        'payment_method': _mode,
        'total_price':    widget.total,
      });

      await SoundService.playCheckout();
      widget.onPaid();
    } catch (_) {
      // Si l'API échoue on joue quand même le son et on vide le panier
      await SoundService.playCheckout();
      widget.onPaid();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (_, ctl) => Container(
        decoration: BoxDecoration(
          color: context.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: context.borderC, borderRadius: BorderRadius.circular(99))),
          const SizedBox(height: 16),
          Expanded(child: ListView(controller: ctl, padding: const EdgeInsets.symmetric(horizontal: 20), children: [
            Text('Paiement', style: fig(20, FontWeight.w800, c: context.ink)),
            const SizedBox(height: 16),
            for (final e in widget.cart.values) ...[
              _CartRow(entry: e),
              const SizedBox(height: 8),
            ],
            Divider(color: context.borderC, height: 24),
            Row(children: [
              Text('Total', style: fig(16, FontWeight.w700, c: context.ink)),
              const Spacer(),
              Text(fmtAmount(widget.total.toInt()), style: fig(20, FontWeight.w800, c: AppColors.primary)),
            ]),
            const SizedBox(height: 20),
            Text('Mode de paiement', style: fig(14, FontWeight.w700, c: context.ink)),
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
                      color: act ? AppColors.primarySft : context.fillC,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: act ? AppColors.primary : Colors.transparent, width: 2),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(m.icon, size: 20, color: act ? AppColors.primary : context.textGr),
                      const SizedBox(height: 4),
                      Text(m.label, style: fig(11, FontWeight.w700, c: act ? AppColors.primary : context.textGr)),
                    ]),
                  ),
                ),
              ));
            }).toList()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _paying ? null : _pay,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _paying
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                  : Text('Encaisser ${fmtAmount(widget.total.toInt())}', style: fig(16, FontWeight.w700, c: Colors.white)),
            ),
            const SizedBox(height: 24),
          ])),
        ]),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  final ({int qty, _PosProduct product}) entry;
  const _CartRow({required this.entry});
  @override
  Widget build(BuildContext context) {
    final p = entry.product;
    return Row(children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: context.fillC, borderRadius: BorderRadius.circular(10)),
        child: Center(child: Text(p.initials, style: fig(13, FontWeight.w800, c: AppColors.primary))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(p.name, style: fig(13, FontWeight.w700, c: context.ink), overflow: TextOverflow.ellipsis),
        Text('×${entry.qty}', style: fig(12, FontWeight.w500, c: context.textGr)),
      ])),
      Text(fmtAmount((p.price * entry.qty).toInt()), style: fig(14, FontWeight.w700, c: context.ink)),
    ]);
  }
}
