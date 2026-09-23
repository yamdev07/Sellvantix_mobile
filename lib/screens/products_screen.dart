import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../models/product_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductModel> _products = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load({String q = ''}) async {
    setState(() { _loading = true; _error = null; });
    try {
      final path = q.isEmpty ? '/products' : '/products?q=${Uri.encodeComponent(q)}';
      final res = await ApiClient.get(path) as List;
      setState(() {
        _products = res.map((j) => ProductModel.fromJson(j)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fcfa(double v) {
    final n = v.toInt();
    return '${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher un produit...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _load();
                        },
                      )
                    : null,
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onChanged: (v) => _load(q: v),
            ),
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppTheme.error)))
              : _products.isEmpty
                  ? const Center(child: Text('Aucun produit trouvé'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _products.length,
                        itemBuilder: (_, i) => _productTile(_products[i]),
                      ),
                    ),
    );
  }

  Widget _productTile(ProductModel p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: p.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  p.imageUrl!,
                  width: 48, height: 48, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _initials(p.initials),
                ),
              )
            : _initials(p.initials),
        title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p.categoryName != null)
              Text(p.categoryName!, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
            Text(_fcfa(p.effectivePrice), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600)),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: p.stock <= 0
                ? const Color(0xFFFFEBEE)
                : p.stock <= 5
                    ? const Color(0xFFFFF3E0)
                    : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            p.stock <= 0 ? 'Rupture' : '${p.stock} ${p.unit ?? ''}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: p.stock <= 0 ? AppTheme.error : p.stock <= 5 ? AppTheme.warning : AppTheme.success,
            ),
          ),
        ),
        isThreeLine: p.categoryName != null,
      ),
    );
  }

  Widget _initials(String txt) {
    return Container(
      width: 48, height: 48,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: Text(txt, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
    );
  }
}
