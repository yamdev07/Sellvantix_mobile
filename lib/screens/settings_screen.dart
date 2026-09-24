import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notifs = true;
  bool _sound = false;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final name = auth.user?.name ?? 'Administrateur';
    final email = auth.user?.email ?? 'admin@boutique.com';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        // Profile card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDk], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(children: [
            Container(
              width: 58, height: 58,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: Center(child: Text(initials(name), style: fig(20, FontWeight.w800, c: AppColors.primaryDk))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: fig(16, FontWeight.w800, c: Colors.white)),
              const SizedBox(height: 3),
              Text(email, style: fig(13, FontWeight.w400, c: Colors.white70)),
              const SizedBox(height: 6),
              Container(
                height: 24, width: 90,
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(99)),
                child: Center(child: Text('Administrateur', style: fig(11, FontWeight.w700, c: Colors.white))),
              ),
            ])),
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
              onPressed: () {},
            ),
          ]),
        ),
        const SizedBox(height: 22),

        // Shop section
        _Section(title: 'Boutique', children: [
          _SettingsRow(icon: Icons.store_outlined, label: 'Nom de la boutique', value: 'Quincaillerie du Marché'),
          _SettingsRow(icon: Icons.location_on_outlined, label: 'Adresse', value: 'Abidjan, Côte d\'Ivoire'),
          _SettingsRow(icon: Icons.currency_franc_rounded, label: 'Devise', value: 'XOF (F CFA)'),
        ]),
        const SizedBox(height: 16),

        // Preferences
        _Section(title: 'Préférences', children: [
          _ToggleRow(icon: Icons.notifications_outlined, label: 'Notifications', value: _notifs, onChanged: (v) => setState(() => _notifs = v)),
          _ToggleRow(icon: Icons.volume_up_outlined, label: 'Sons de caisse', value: _sound, onChanged: (v) => setState(() => _sound = v)),
          _ToggleRow(icon: Icons.dark_mode_outlined, label: 'Mode sombre', value: _darkMode, onChanged: (v) => setState(() => _darkMode = v)),
        ]),
        const SizedBox(height: 16),

        // App
        _Section(title: 'Application', children: [
          _SettingsRow(icon: Icons.info_outline, label: 'Version', value: '1.0.0'),
          _SettingsRow(icon: Icons.privacy_tip_outlined, label: 'Politique de confidentialité'),
          _SettingsRow(icon: Icons.help_outline, label: 'Aide & Support'),
        ]),
        const SizedBox(height: 24),

        // Logout
        GestureDetector(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: Text('Se déconnecter', style: fig(17, FontWeight.w800, c: AppColors.ink)),
                content: Text('Voulez-vous vraiment vous déconnecter ?', style: fig(14, FontWeight.w500, c: AppColors.textGrey)),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Annuler', style: fig(14, FontWeight.w600, c: AppColors.textGrey))),
                  TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Déconnecter', style: fig(14, FontWeight.w700, c: const Color(0xFFEF4444)))),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              await auth.logout();
            }
          },
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
              const SizedBox(width: 8),
              Text('Se déconnecter', style: fig(15, FontWeight.w700, c: const Color(0xFFEF4444))),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(title.toUpperCase(), style: fig(11, FontWeight.w700, c: AppColors.muted, ls: 0.8)),
      ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: List.generate(children.length, (i) => Column(children: [
            children[i],
            if (i < children.length - 1)
              const Divider(height: 1, indent: 52, color: AppColors.listBdr),
          ])),
        ),
      ),
    ]);
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  const _SettingsRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 18, color: AppColors.textMid),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: fig(14, FontWeight.w600, c: AppColors.ink))),
        if (value != null) Text(value!, style: fig(13, FontWeight.w500, c: AppColors.textGrey)),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, color: AppColors.muted, size: 20),
      ]),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.icon, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(children: [
        Container(
          width: 34, height: 34,
          decoration: BoxDecoration(color: AppColors.fill, borderRadius: BorderRadius.circular(9)),
          child: Icon(icon, size: 18, color: AppColors.textMid),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: fig(14, FontWeight.w600, c: AppColors.ink))),
        Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ]),
    );
  }
}
