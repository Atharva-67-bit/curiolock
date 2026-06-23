import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';
import 'scan_connect_screen.dart';

/// Login / Sign-up. UI is wired; swap the mock auth for Firebase Auth
/// (see design §5) by calling FirebaseAuth in _submit().
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

  Future<void> _submit() async {
    setState(() => _loading = true);
    // TODO: replace with FirebaseAuth signIn/createUser.
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScanConnectScreen()),
    );
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
                  height: 88,
                  width: 88,
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
                Text('From Curiosity to Security',
                    style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 36),
                TextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(hintText: 'Email'),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _pass,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                          color: AppColors.textMuted),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                GradientButton(
                  label: _signUp ? 'Create Account' : 'Sign In',
                  icon: Icons.lock_open_rounded,
                  loading: _loading,
                  onTap: _submit,
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => setState(() => _signUp = !_signUp),
                  child: Text(
                    _signUp ? 'Already have an account?  Sign In' : 'New here?  Create account',
                    style: const TextStyle(color: AppColors.accent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
