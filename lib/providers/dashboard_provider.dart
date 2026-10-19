import 'package:flutter/material.dart';
import '../core/api_client.dart';

class DashboardProvider extends ChangeNotifier {
  Map<String, dynamic>? _data;
  Map<String, dynamic>? _conseil;
  bool _loading = false;
  String? _error;

  Map<String, dynamic>? get data    => _data;
  Map<String, dynamic>? get conseil => _conseil;
  bool get loading                  => _loading;
  bool get hasError                 => _error != null;

  double get todayRevenue  => (_data?['today_revenue']  as num? ?? 0).toDouble();
  int    get todaySales    => (_data?['today_sales']    as num? ?? 0).toInt();
  int    get totalProducts => (_data?['total_products'] as num? ?? 0).toInt();
  int    get outOfStock    => (_data?['out_of_stock']   as num? ?? 0).toInt();
  int    get targetPct     => (_data?['target_pct']     as num? ?? 0).toInt();
  List   get lowStock      => (_data?['low_stock']      as List?) ?? [];
  List   get recentSales   => (_data?['recent_sales']   as List?) ?? [];

  String get conseilMessage => _conseil?['message'] ?? 'Chargement du conseil…';
  String? get conseilAction => _conseil?['action'];
  String get conseilUrgence => _conseil?['urgence'] ?? 'low';

  Future<void> fetch() async {
    if (_loading) return;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        ApiClient.get('/dashboard'),
        ApiClient.get('/conseil'),
      ]);
      _data    = results[0] as Map<String, dynamic>;
      _conseil = results[1] as Map<String, dynamic>;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Erreur réseau';
    }

    _loading = false;
    notifyListeners();
  }
}
