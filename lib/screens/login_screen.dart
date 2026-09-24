import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';

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

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _entryCtrl,
    curve: Curves.easeOut,
  );
  late final Animation<Offset> _slideUp = Tween<Offset>(
    begin: const Offset(0, 0.08),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut));

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final nav  = Navigator.of(context);
    final ok   = await auth.login(_emailCtrl.text.trim(), _passCtrl.text);
    if (ok && mounted) {
      nav.pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const DashboardScreen(),
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A16),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fond dégradé ─────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.6),
                radius: 1.0,
                colors: [Color(0x28E8590C), Color(0xFF0A0A16)],
              ),
            ),
          ),

          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // ── Logo ─────────────────────────────────────────
                      Center(
                        child: Column(children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withOpacity(0.4),
                                  blurRadius: 30,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sellvantix',
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800, letterSpacing: -0.8),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Connectez-vous à votre boutique',
                            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
                          ),
                        ]),
                      ),

                      const SizedBox(height: 48),

                      // ── Formulaire ───────────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141421),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF1F1F35), width: 1.5),
                          boxShadow: const [
                            BoxShadow(color: Color(0x33000000), blurRadius: 40, offset: Offset(0, 16)),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email
                              _label('Adresse e-mail'),
                              const SizedBox(height: 8),
                              _darkField(
                                controller: _emailCtrl,
                                hint: 'vous@boutique.com',
                                icon: Icons.email_outlined,
                                keyboard: TextInputType.emailAddress,
                                action: TextInputAction.next,
                              ),
                              const SizedBox(height: 20),

                              // Mot de passe
                              _label('Mot de passe'),
                              const SizedBox(height: 8),
                              _darkField(
                                controller: _passCtrl,
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscure: _obscure,
                                action: TextInputAction.done,
                                onSubmit: (_) => _submit(),
                                suffix: IconButton(
                                  icon: Icon(
                                    _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    size: 18,
                                    color: const Color(0xFF6B7280),
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                              ),

                              // Erreur
                              if (auth.error != null) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.error.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                                  ),
                                  child: Row(children: [
                                    const Icon(Icons.error_outline, color: AppTheme.error, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(auth.error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
                                    ),
                                  ]),
                                ),
                              ],

                              const SizedBox(height: 28),

                              // Bouton
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: auth.loading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    disabledBackgroundColor: AppTheme.primary.withOpacity(0.5),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                    shadowColor: AppTheme.primary.withOpacity(0.4),
                                  ).copyWith(
                                    elevation: WidgetStateProperty.resolveWith((s) =>
                                      s.contains(WidgetState.pressed) ? 0 : 6),
                                  ),
                                  child: auth.loading
                                      ? const SizedBox(width: 22, height: 22,
                                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Text('Se connecter',
                                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                      const Center(
                        child: Text('Sellvantix © 2025',
                            style: TextStyle(color: Color(0xFF374151), fontSize: 12)),
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

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(color: Color(0xFFD1D5DB), fontWeight: FontWeight.w500, fontSize: 13),
  );

  Widget _darkField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    TextInputType? keyboard,
    TextInputAction? action,
    Widget? suffix,
    void Function(String)? onSubmit,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      textInputAction: action,
      onFieldSubmitted: onSubmit,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      cursorColor: AppTheme.primary,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4B5563)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFF0D0D1C),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1F1F35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1F1F35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Champ requis' : null,
    );
  }
}
