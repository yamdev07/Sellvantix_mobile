import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/brand_mark.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;

  late final AnimationController _entryCtrl = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  )..forward();

  late final Animation<double> _headerFade = CurvedAnimation(
    parent: _entryCtrl,
    curve: const Interval(0, 0.6, curve: Curves.easeOut),
  );
  late final Animation<Offset> _sheetSlide = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final nav  = Navigator.of(context);
    final ok   = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      nav.pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const AppScaffold(),
        transitionDuration: const Duration(milliseconds: 450),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Stack(
        children: [
          const BrandBackdrop(),
          LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      FadeTransition(opacity: _headerFade, child: const _Header()),
                      Expanded(
                        child: SlideTransition(
                          position: _sheetSlide,
                          child: _sheet(auth),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Feuille blanche avec le formulaire ─────────────────────────────────────
  Widget _sheet(AuthProvider auth) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 32, 24, 20 + bottom),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Connexion', style: fig(22, FontWeight.w800, c: AppColors.ink, ls: -0.5)),
            const SizedBox(height: 4),
            Text('Entrez vos identifiants pour continuer.',
                style: fig(14, FontWeight.w500, c: AppColors.textGrey)),
            const SizedBox(height: 28),

            _label('Adresse e-mail'),
            const SizedBox(height: 8),
            _field(
              controller: _emailCtrl,
              hint: 'vous@boutique.com',
              icon: Icons.mail_outline_rounded,
              keyboard: TextInputType.emailAddress,
              action: TextInputAction.next,
              autofill: const [AutofillHints.email],
            ),
            const SizedBox(height: 18),

            _label('Mot de passe'),
            const SizedBox(height: 8),
            _field(
              controller: _passCtrl,
              hint: '••••••••',
              icon: Icons.lock_outline_rounded,
              obscure: _obscure,
              action: TextInputAction.done,
              autofill: const [AutofillHints.password],
              onSubmit: (_) => _submit(),
              suffix: IconButton(
                tooltip: _obscure ? 'Afficher' : 'Masquer',
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.muted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),

            if (auth.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.errorBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(auth.error!, style: fig(13, FontWeight.w600, c: AppColors.error)),
                  ),
                ]),
              ),
            ],

            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: auth.loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.55),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: auth.loading
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Se connecter', style: fig(16, FontWeight.w800, c: Colors.white)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),

            const Spacer(),
            const SizedBox(height: 24),
            Center(
              child: Text('Sellvantix © 2026', style: fig(12, FontWeight.w500, c: AppColors.muted)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) =>
      Text(text, style: fig(13, FontWeight.w700, c: AppColors.textMid));

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboard,
    TextInputAction? action,
    Iterable<String>? autofill,
    Widget? suffix,
    void Function(String)? onSubmit,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: c, width: w),
        );

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textInputAction: action,
      autofillHints: autofill,
      onFieldSubmitted: onSubmit,
      style: fig(15, FontWeight.w600, c: AppColors.ink),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: fig(15, FontWeight.w500, c: AppColors.disabled),
        prefixIcon: Icon(icon, size: 20, color: AppColors.muted),
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border(AppColors.inputBdr),
        enabledBorder: border(AppColors.inputBdr),
        focusedBorder: border(AppColors.primary, 1.5),
        errorBorder: border(AppColors.error),
        focusedErrorBorder: border(AppColors.error, 1.5),
      ),
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
    );
  }
}

// ── En-tête orange : logo + message d'accueil ────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const BrandMark(size: 44),
              const SizedBox(width: 12),
              Text('Sellvantix', style: fig(20, FontWeight.w800, c: Colors.white, ls: -0.5)),
            ]),
            const SizedBox(height: 36),
            Text('Bon retour !', style: fig(32, FontWeight.w800, c: Colors.white, ls: -1)),
            const SizedBox(height: 6),
            Text(
              'Ventes, stock et clients :\ntout votre commerce au même endroit.',
              style: fig(15, FontWeight.w500, c: const Color(0xE6FFFFFF)).copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
