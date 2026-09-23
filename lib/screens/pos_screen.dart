import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../models/product_model.dart';

class _CartItem {
  final ProductModel product;
  int qty;
  _CartItem({required this.product, this.qty = 1});
  double get total => product.effectivePrice * qty;
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  List<ProductModel> _products = [];
  List<ProductModel> _filtered = [];
  final List<_CartItem> _cart = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  String _payMethod = 'cash';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    setState(() { _loading = true; });
    try {
      final res = await ApiClient.get('/products?in_stock=1') as List;
      setState(() {
        _products = res.map((j) => ProductModel.fromJson(j)).toList();
        _filtered = List.from(_products);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _filter(String q) {
    setState(() {
      _filtered = q.isEmpty
          ? List.from(_products)
          : _products.where((p) => p.name.toLowerCase().contains(q.toLowerCase())).toList();
    });
  }

  void _addToCart(ProductModel p) {
    final existing = _cart.where((c) => c.product.id == p.id).firstOrNull;
    setState(() {
      if (existing != null) {
        if (existing.qty < p.stock) existing.qty++;
      } else {
        _cart.add(_CartItem(product: p));
      }
    });
  }

  void _removeFromCart(int idx) => setState(() => _cart.removeAt(idx));

  double get _total => _cart.fold(0, (s, c) => s + c.total);

  String _fcfa(double v) {
    final n = v.toInt();
    return '${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }

  Future<void> _confirm() async {
    if (_cart.isEmpty) return;
    setState(() => _submitting = true);

    try {
      await ApiClient.post('/sales', {
        'payment_method': _payMethod,
        'discount': 0,
        'items': _cart.map((c) => {
          'product_id': c.product.id,
          'quantity': c.qty,
          'unit_price': c.product.effectivePrice,
        }).toList(),
      });

      setState(() {
        _cart.clear();
        _submitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vente enregistrée !'),
            backgroundColor: AppTheme.success,
          ),
        );
        _loadProducts(); // refresh stock
      }
    } catch (e) {
      setState(() => _submitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppTheme.error),
        );
      }
    }
  }

  void _showPaymentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(builder: (ctx, setLocal) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            const Text('Confirmer la vente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(_fcfa(_total), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.primary)),
            const SizedBox(height: 20),
            const Align(alignment: Alignment.centerLeft, child: Text('Mode de paiement', style: TextStyle(fontWeight: FontWeight.w600))),
            const SizedBox(height: 10),
            Wrap(spacing: 8, children: [
              for (final m in [
                ('cash', 'Espèces', Icons.payments),
                ('mobile_money', 'Mobile Money', Icons.phone_android),
                ('card', 'Carte', Icons.credit_card),
                ('credit', 'Crédit', Icons.access_time),
              ])
                ChoiceChip(
                  label: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(m.$3, size: 16, color: _payMethod == m.$1 ? Colors.white : AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Text(m.$2),
                  ]),
                  selected: _payMethod == m.$1,
                  selectedColor: AppTheme.primary,
                  labelStyle: TextStyle(color: _payMethod == m.$1 ? Colors.white : AppTheme.textDark),
                  onSelected: (_) => setLocal(() => setState(() => _payMethod = m.$1)),
                ),
            ]),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitting ? null : () { Navigator.pop(ctx); _confirm(); },
                child: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Valider la vente'),
              ),
            ),
          ]),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Caisse (POS)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(children: [
                  // ── Recherche ─────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Chercher un produit...',
                        prefixIcon: Icon(Icons.search, size: 20),
                        isDense: true,
                      ),
                      onChanged: _filter,
                    ),
                  ),

                  // ── Catalogue ─────────────────────────────────────────────
                  Expanded(
                    child: _filtered.isEmpty
                        ? const Center(child: Text('Aucun produit'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) {
                              final p = _filtered[i];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: ListTile(
                                  dense: true,
                                  leading: p.imageUrl != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.network(p.imageUrl!, width: 40, height: 40, fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => _thumb(p.initials)),
                                        )
                                      : _thumb(p.initials),
                                  title: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                  subtitle: Text(_fcfa(p.effectivePrice), style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                    Text('Stock: ${p.stock}', style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () => _addToCart(p),
                                      child: Container(
                                        width: 32, height: 32,
                                        decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8)),
                                        child: const Icon(Icons.add, color: Colors.white, size: 18),
                                      ),
                                    ),
                                  ]),
                                ),
                              );
                            },
                          ),
                  ),

                  // ── Panier ────────────────────────────────────────────────
                  if (_cart.isNotEmpty) ...[
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
                      ),
                      child: Column(children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Panier (${_cart.length})', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                              Text(_fcfa(_total), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 16)),
                            ],
                          ),
                        ),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 180),
                          child: ListView.builder(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            itemCount: _cart.length,
                            itemBuilder: (_, i) {
                              final c = _cart[i];
                              return ListTile(
                                dense: true,
                                title: Text(c.product.name, style: const TextStyle(fontSize: 13)),
                                subtitle: Text(_fcfa(c.total), style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
                                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () => setState(() {
                                      if (c.qty > 1) { c.qty--; } else { _cart.removeAt(i); }
                                    }),
                                  ),
                                  Text('${c.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20),
                                    onPressed: () => setState(() {
                                      if (c.qty < c.product.stock) c.qty++;
                                    }),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.error),
                                    onPressed: () => _removeFromCart(i),
                                  ),
                                ]),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                          child: ElevatedButton.icon(
                            onPressed: _showPaymentSheet,
                            icon: const Icon(Icons.check_circle_outline),
                            label: Text('Encaisser ${_fcfa(_total)}'),
                          ),
                        ),
                      ]),
                    ),
                  ],
                ]),
    );
  }

  Widget _thumb(String txt) => Container(
    width: 40, height: 40,
    decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
    alignment: Alignment.center,
    child: Text(txt, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
  );
}
