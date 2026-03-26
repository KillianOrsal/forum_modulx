import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;
  String? _error;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    String? errorMsg;
    if (_isLogin) {
      errorMsg = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      errorMsg = await AuthService().register(
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (errorMsg == null) {
      Navigator.of(context).pop(true); // succès
    } else {
      setState(() => _error = errorMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark,
                  borderRadius: AppTheme.cardRadius,
                  border: Border.all(color: AppTheme.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.view_in_ar,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isLogin ? 'Connexion' : 'Inscription',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _isLogin
                            ? 'Connectez-vous pour commenter'
                            : 'Créez votre compte ModulX',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Erreur
                      if (_error != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Champs inscription
                      if (!_isLogin) ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: 'Prénom',
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppTheme.textMuted, size: 20),
                                ),
                                validator: (v) => !_isLogin &&
                                        (v == null || v.isEmpty)
                                    ? 'Requis'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary),
                                decoration: const InputDecoration(
                                  hintText: 'Nom',
                                  prefixIcon: Icon(Icons.person_outline,
                                      color: AppTheme.textMuted, size: 20),
                                ),
                                validator: (v) => !_isLogin &&
                                        (v == null || v.isEmpty)
                                    ? 'Requis'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style:
                            const TextStyle(color: AppTheme.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined,
                              color: AppTheme.textMuted, size: 20),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Email requis' : null,
                      ),
                      const SizedBox(height: 14),

                      // Mot de passe
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style:
                            const TextStyle(color: AppTheme.textPrimary),
                        decoration: InputDecoration(
                          hintText: 'Mot de passe',
                          prefixIcon: const Icon(Icons.lock_outline,
                              color: AppTheme.textMuted, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppTheme.textMuted,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Mot de passe requis'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Bouton
                      _isLoading
                          ? const CircularProgressIndicator(
                              color: AppTheme.primaryPurple)
                          : GradientButton(
                              text: _isLogin ? 'Se connecter' : 'S\'inscrire',
                              icon: _isLogin ? Icons.login : Icons.person_add,
                              onPressed: _submit,
                              width: double.infinity,
                            ),
                      const SizedBox(height: 20),

                      // Toggle login/register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLogin
                                ? 'Pas encore de compte ?'
                                : 'Déjà un compte ?',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          TextButton(
                            onPressed: () => setState(() {
                              _isLogin = !_isLogin;
                              _error = null;
                            }),
                            child: Text(
                              _isLogin ? 'S\'inscrire' : 'Se connecter',
                              style: const TextStyle(
                                color: AppTheme.primaryPurpleLight,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
