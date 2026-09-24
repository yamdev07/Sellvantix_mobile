import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../screens/home_screen.dart';
import '../screens/pos_screen.dart';
import '../screens/stock_screen.dart';
import '../screens/clients_screen.dart';
import '../screens/settings_screen.dart';

class AppScaffold extends StatefulWidget {
  const AppScaffold({super.key});
  @override
  State<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends State<AppScaffold> {
  // 0=home 1=stock 2=pos(FAB) 3=clients 4=settings
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.name ?? 'Administrateur';
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: _Header(
              userName: name,
              onAvatarTap: () => setState(() => _tab = 4),
            ),
          ),
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              clipBehavior: Clip.hardEdge,
              child: IndexedStack(
                index: _tab,
                children: const [
                  HomeScreen(),
                  StockScreen(),
                  PosScreen(),
                  ClientsScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          ),
          _TabBar(
            current: _tab,
            onTap: (i) => setState(() => _tab = i),
            bottomPad: bottom,
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  final String userName;
  final VoidCallback onAvatarTap;
  const _Header({required this.userName, required this.onAvatarTap});

  @override
  Widget build(BuildContext context) {
    final ini = initials(userName);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 18),
      child: Row(children: [
        // Logo box
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Center(child: CustomPaint(size: const Size(20, 20), painter: _LogoPainter())),
        ),
        const SizedBox(width: 10),
        // Shop + user
        const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Quincaillerie du Marché',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 1),
          Text(
            'Administrateur',
            style: TextStyle(color: Color(0xE0FFFFFF), fontSize: 12),
          ),
        ])),
        const SizedBox(width: 6),
        // Sync pill
        Container(
          height: 30, padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 7, height: 7, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            const Text('À jour', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
        const SizedBox(width: 8),
        // Avatar
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            width: 44, height: 44,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Center(child: Text(
              ini,
              style: const TextStyle(color: AppColors.primaryDk, fontWeight: FontWeight.w800, fontSize: 14),
            )),
          ),
        ),
      ]),
    );
  }
}

// ── Logo SVG painter ───────────────────────────────────────────────────────────
class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100;
    final stroke = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 14 * s
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeJoin = StrokeJoin.miter;

    final path = Path();
    path.moveTo(78 * s, 22 * s);
    path.lineTo(52 * s, 22 * s);
    path.cubicTo(36 * s, 22 * s, 28 * s, 28 * s, 28 * s, 38 * s);
    path.cubicTo(28 * s, 52 * s, 72 * s, 48 * s, 72 * s, 64 * s);
    path.cubicTo(72 * s, 76 * s, 62 * s, 80 * s, 48 * s, 80 * s);
    path.lineTo(22 * s, 80 * s);
    canvas.drawPath(path, stroke);

    final fill = Paint()..color = AppColors.primary..style = PaintingStyle.fill;
    final a1 = Path()
      ..moveTo(76 * s, 8 * s)..lineTo(94 * s, 22 * s)..lineTo(76 * s, 36 * s)..close();
    canvas.drawPath(a1, fill);
    final a2 = Path()
      ..moveTo(24 * s, 66 * s)..lineTo(6 * s, 80 * s)..lineTo(24 * s, 94 * s)..close();
    canvas.drawPath(a2, fill);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Tab bar ────────────────────────────────────────────────────────────────────
class _TabBar extends StatelessWidget {
  final int current;
  final ValueChanged<int> onTap;
  final double bottomPad;
  const _TabBar({required this.current, required this.onTap, required this.bottomPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            height: 56 + bottomPad,
            child: Row(children: [
              _Tab(icon: Icons.home_outlined, label: 'Accueil', active: current == 0, onTap: () => onTap(0)),
              _Tab(icon: Icons.inventory_2_outlined, label: 'Stock', active: current == 1, onTap: () => onTap(1)),
              const SizedBox(width: 72), // FAB placeholder
              _Tab(icon: Icons.people_outline, label: 'Clients', active: current == 3, onTap: () => onTap(3)),
              _Tab(icon: Icons.settings_outlined, label: 'Réglages', active: current == 4, onTap: () => onTap(4)),
            ]),
          ),
          // Central FAB — raised 30 px
          Positioned(
            top: -30, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () => onTap(2),
                child: Container(
                  width: 62, height: 62,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(color: Color(0x73E8590C), blurRadius: 20, offset: Offset(0, 8)),
                    ],
                  ),
                  child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.icon, required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textGrey;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 2),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 3),
            Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Container(
              width: 18, height: 3,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
