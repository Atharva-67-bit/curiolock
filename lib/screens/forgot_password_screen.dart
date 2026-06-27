import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _email = TextEditingController();
  bool _loading = false;
  String? _msg;
  bool _sent = false;

  bool _emailValid(String e) =>
      RegExp(r'^[\w.\-+]+@([\w\-]+\.)+[\w\-]{2,}$').hasMatch(e.trim());

  Future<void> _send() async {
    if (!_emailValid(_email.text)) {
      setState(() { _msg = 'Enter a valid email address.'; _sent = false; });
      return;
    }
    setState(() { _loading = true; _msg = null; });
    final err = await context.read<AuthService>().sendPasswordReset(_email.text);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = err == null;
      _msg = err ?? 'Reset link sent — check your email.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 8),
            const Icon(Icons.lock_reset_rounded, size: 64, color: AppColors.accent),
            const SizedBox(height: 16),
            Text('Forgot your password?', textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Enter your email and we\'ll send you a link to reset it.',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              onChanged: (_) => setState(() => _msg = null),
              decoration: const InputDecoration(hintText: 'Email'),
            ),
            if (_msg != null) ...[
              const SizedBox(height: 12),
              Row(children: [
                Icon(_sent ? Icons.check_circle : Icons.error_outline,
                    color: _sent ? AppColors.success : AppColors.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(_msg!,
                    style: TextStyle(color: _sent ? AppColors.success : AppColors.danger))),
              ]),
            ],
            const SizedBox(height: 24),
            GradientButton(
              label: 'Send reset link',
              icon: Icons.send_rounded,
              loading: _loading,
              onTap: _send,
            ),
          ],
        ),
      ),
    );
  }
}
