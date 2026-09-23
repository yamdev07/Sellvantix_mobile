import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_client.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'pos_screen.dart';
import 'products_screen.dart';
import 'sales_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
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
      final res = await ApiClient.get('/dashboard');
      setState(() { _data = res; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _fcfa(dynamic val) {
    if (val == null) return '0 FCFA';
    final n = (val as num).toInt();
    return '${n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]} ',
    )} FCFA';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bonjour, ${user?.name.split(' ').first ?? ''}'),
            Text(
              user?.tenantName ?? '',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'Actualiser',
          ),
          PopupMenuButton<String>(
            icon: CircleAvatar(
              backgroundColor: Colors.white24,
              child: Text(user?.initials ?? '?', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ),
            onSelected: (v) async {
              if (v == 'logout') {
                final auth = context.read<AuthProvider>();
                final nav  = Navigator.of(context);
                await auth.logout();
                if (mounted) {
                  nav.pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                }
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'info',
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(user?.role ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textGrey)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Row(
                children: [
                  Icon(Icons.logout, size: 18, color: AppTheme.error),
                  SizedBox(width: 8),
                  Text('Déconnexion', style: TextStyle(color: AppTheme.error)),
                ],
              )),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(onRefresh: _load, child: _buildBody()),
      bottomNavigationBar: _buildNav(context),
    );
  }

  Widget _buildError() => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.wifi_off, size: 48, color: AppTheme.textGrey),
        const SizedBox(height: 16),
        Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.textGrey)),
        const SizedBox(height: 16),
        ElevatedButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Réessayer')),
      ]),
    ),
  );

  Widget _buildBody() {
    final d = _data!;
    final todayRevenue = d['today_revenue'] ?? 0;
    final dailyTarget  = d['daily_target'] ?? 0;
    final targetPct    = d['target_pct'] ?? 0;
    final lowStock     = (d['low_stock'] as List?) ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Objectif du jour ───────────────────────────────────────────────
        if (dailyTarget > 0) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, Color(0xFFFF8C47)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Objectif du jour', style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(_fcfa(todayRevenue), style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('sur ${_fcfa(dailyTarget)}', style: const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (targetPct as num) / 100,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 6),
              Text('$targetPct% atteint', style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // ── Stats cards ───────────────────────────────────────────────────
        Row(children: [
          _statCard('Ventes aujourd\'hui', '${d['today_sales'] ?? 0}', Icons.receipt_long, AppTheme.primary),
          const SizedBox(width: 12),
          _statCard('CA du jour', _fcfa(todayRevenue), Icons.payments_outlined, AppTheme.success),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          _statCard('Produits', '${d['total_products'] ?? 0}', Icons.inventory_2_outlined, const Color(0xFF6366F1)),
          const SizedBox(width: 12),
          _statCard('Ruptures', '${d['out_of_stock'] ?? 0}', Icons.warning_amber_rounded, AppTheme.error),
        ]),
        const SizedBox(height: 24),

        // ── Stock critique ────────────────────────────────────────────────
        if (lowStock.isNotEmpty) ...[
          const Text('Stock critique', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...lowStock.map((p) => _stockAlert(p)),
          const SizedBox(height: 24),
        ],

        // ── Raccourcis ────────────────────────────────────────────────────
        const Text('Accès rapide', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _shortcut(context, 'Caisse (POS)', Icons.point_of_sale, AppTheme.primary, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen()));
            }),
            _shortcut(context, 'Produits', Icons.inventory_2, const Color(0xFF6366F1), () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
            }),
            _shortcut(context, 'Ventes', Icons.receipt_long, AppTheme.success, () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesScreen()));
            }),
            _shortcut(context, 'Actualiser', Icons.refresh, AppTheme.textGrey, _load),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textGrey)),
          ]),
        ),
      ),
    );
  }

  Widget _stockAlert(Map p) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: const CircleAvatar(
          backgroundColor: Color(0xFFFFF3E0),
          child: Icon(Icons.warning_amber_rounded, color: AppTheme.warning, size: 20),
        ),
        title: Text(p['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text('${p['stock']} ${p['unit'] ?? ''}', style: const TextStyle(color: AppTheme.error, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  Widget _shortcut(BuildContext ctx, String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
        ),
      ),
    );
  }

  Widget _buildNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: AppTheme.primary,
      type: BottomNavigationBarType.fixed,
      onTap: (i) {
        if (i == 1) Navigator.push(context, MaterialPageRoute(builder: (_) => const PosScreen()));
        if (i == 2) Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
        if (i == 3) Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesScreen()));
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.point_of_sale), label: 'Caisse'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Produits'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ventes'),
      ],
    );
  }
}
