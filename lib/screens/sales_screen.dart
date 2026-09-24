import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<dynamic> _sales = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient.get('/sales');
      setState(() {
        _sales = res['data'] ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fcfa(dynamic v) {
    if (v == null) return '0 FCFA';
    final n = (v as num).toInt();
    return '${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';
  }

  String _payLabel(String? method) {
    switch (method) {
      case 'cash':         return 'Espèces';
      case 'card':         return 'Carte';
      case 'mobile_money': return 'Mobile Money';
      case 'credit':       return 'Crédit';
      default:             return method ?? '—';
    }
  }

  Color _payColor(String? method) {
    switch (method) {
      case 'cash':         return AppTheme.success;
      case 'mobile_money': return const Color(0xFF6366F1);
      case 'credit':       return AppTheme.warning;
      default:             return AppTheme.textGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historique des ventes')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Color(0xFFEF4444))))
              : _sales.isEmpty
                  ? const Center(child: Text('Aucune vente'))
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _sales.length,
                        itemBuilder: (_, i) => _saleTile(_sales[i]),
                      ),
                    ),
    );
  }

  Widget _saleTile(Map s) {
    final method = s['payment_method'] as String?;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(Icons.receipt, color: AppTheme.primary, size: 20),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Vente #${s['id']}', style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(_fcfa(s['final_price']), style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(s['client']?['name'] ?? 'Client anonyme', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _payColor(method).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_payLabel(method), style: TextStyle(fontSize: 11, color: _payColor(method), fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Text(s['created_at']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ]),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
