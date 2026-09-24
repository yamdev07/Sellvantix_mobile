import 'package:flutter/material.dart';
import '../core/app_theme.dart';

const _kClients = [
  (id: 1, name: 'Kouassi Atta', phone: '+225 07 45 23 10', debt: 45000, lastBuy: 'Il y a 2 jours'),
  (id: 2, name: 'Mme. Traoré Aminata', phone: '+225 05 67 89 34', debt: 0, lastBuy: 'Aujourd\'hui'),
  (id: 3, name: 'BTP Abidjan SARL', phone: '+225 27 22 45 67', debt: 180000, lastBuy: 'Il y a 5 jours'),
  (id: 4, name: 'Koné Ibrahim', phone: '+225 01 23 45 67', debt: 22500, lastBuy: 'Hier'),
];

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  int get _totalDebt => _kClients.fold(0, (acc, c) => acc + c.debt);
  int get _debtorCount => _kClients.where((c) => c.debt > 0).length;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Debt summary card
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primarySft,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFFD4BB)),
          ),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Total dettes en cours', style: fig(13, FontWeight.w600, c: AppColors.textMid)),
              const SizedBox(height: 6),
              Text(fmtAmount(_totalDebt), style: fig(28, FontWeight.w800, c: AppColors.primary, ls: -0.5)),
              const SizedBox(height: 4),
              Text('$_debtorCount client${_debtorCount > 1 ? 's' : ''} débiteur${_debtorCount > 1 ? 's' : ''}',
                  style: fig(12, FontWeight.w600, c: AppColors.textGrey)),
            ]),
            const Spacer(),
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 26),
            ),
          ]),
        ),
      ),
      // Actions row
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
        child: Row(children: [
          Expanded(child: _ActionBtn(
            label: 'Nouveau client',
            icon: Icons.person_add_outlined,
            onTap: () {},
          )),
          const SizedBox(width: 10),
          Expanded(child: _ActionBtn(
            label: 'Relancer tous',
            icon: Icons.notifications_outlined,
            onTap: () {},
            outlined: true,
          )),
        ]),
      ),
      // Client list
      Expanded(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          itemCount: _kClients.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) => _ClientCard(client: _kClients[i]),
        ),
      ),
    ]);
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;
  const _ActionBtn({required this.label, required this.icon, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: outlined ? Colors.transparent : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: outlined ? AppColors.primary : AppColors.primary),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 18, color: outlined ? AppColors.primary : Colors.white),
          const SizedBox(width: 6),
          Text(label, style: fig(13, FontWeight.w700, c: outlined ? AppColors.primary : Colors.white)),
        ]),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final ({int id, String name, String phone, int debt, String lastBuy}) client;
  const _ClientCard({required this.client});

  @override
  Widget build(BuildContext context) {
    final hasDebt = client.debt > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: hasDebt ? const Color(0x33E8590C) : AppColors.border),
      ),
      child: Row(children: [
        // Avatar
        Container(
          width: 46, height: 46,
          decoration: BoxDecoration(
            color: hasDebt ? AppColors.primarySft : AppColors.fill,
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(
            initials(client.name),
            style: fig(16, FontWeight.w800, c: hasDebt ? AppColors.primary : AppColors.textMid),
          )),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(client.name, style: fig(14, FontWeight.w700, c: AppColors.ink), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(client.phone, style: fig(12, FontWeight.w500, c: AppColors.textGrey)),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.access_time_rounded, size: 12, color: AppColors.muted),
            const SizedBox(width: 4),
            Text(client.lastBuy, style: fig(11.5, FontWeight.w500, c: AppColors.muted)),
          ]),
        ])),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          if (hasDebt) ...[
            Text(fmtAmount(client.debt), style: fig(14, FontWeight.w800, c: AppColors.primary)),
            const SizedBox(height: 6),
            GestureDetector(
              child: Container(
                height: 30, padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(99)),
                child: Center(child: Text('Relancer', style: fig(12, FontWeight.w700, c: Colors.white))),
              ),
            ),
          ] else ...[
            Container(
              height: 24, padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(99)),
              child: Center(child: Text('À jour', style: fig(11, FontWeight.w700, c: const Color(0xFF16A34A)))),
            ),
          ],
        ]),
      ]),
    );
  }
}
