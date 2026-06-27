import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';
import 'scan_connect_screen.dart';
import 'verify_email_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _signUp = false;
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  bool _emailValid(String e) =>
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(e.trim());

  Future<void> _submit() async {
    final email = _email.text.trim();
    final pass = _pass.text;
    // client-side checks first
    if (!_emailValid(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    setState(() { _loading = true; _error = null; });

    final auth = context.read<AuthService>();
    final err = _signUp ? await auth.signUp(email, pass) : await auth.signIn(email, pass);
    if (!mounted) return;
    setState(() => _loading = false);

    if (err != null) { setState(() => _error = err); return; }

    // Route: needs email verification? -> verify screen. Else -> app.
    if (AuthService.firebaseReady && !auth.isEmailVerified) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const VerifyEmailScreen()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ScanConnectScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 88, width: 88,
                  decoration: BoxDecoration(
                    gradient: AppColors.brandGradient,
                    borderRadius: BorderRadius.circular(26),
                    boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.4), blurRadius: 30)],
                  ),
                  child: const Icon(Icons.shield_outlined, color: Colors.white, size: 46),
                ),
                const SizedBox(height: 18),
                Text('CurioLock', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text('From Curiosity to Security', style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 36),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  onChanged: (_) => setState(() => _error = null),
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _pass,
                  obscureText: _obscure,
                  onChanged: (_) => setState(() => _error = null),
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                if (!_signUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                      child: const Text('Forgot password?',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                    ),
                  ),
                if (_error != null) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                    const SizedBox(width: 6),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.danger, fontSize: 13))),
                  ]),
                ],
                const SizedBox(height: 18),
                GradientButton(
                  label: _signUp ? 'Create Account' : 'Sign In',
                  icon: Icons.lock_open_rounded,
                  loading: _loading,
                  onTap: _submit,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() { _signUp = !_signUp; _error = null; }),
                  child: Text(
                    _signUp ? 'Already have an account?  Sign In' : 'New here?  Create account',
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ),
                if (!AuthService.firebaseReady) ...[
                  const SizedBox(height: 8),
                  Text('Demo mode — set up Firebase for real accounts.',
                      style: TextStyle(color: AppColors.textMuted.withValues(alpha: 0.7), fontSize: 11)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
