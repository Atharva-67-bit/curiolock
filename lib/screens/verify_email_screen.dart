import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';
import 'scan_connect_screen.dart';
import 'login_screen.dart';

/// Shown after sign-up. The user must click the link in their email, then tap
/// "I've verified" to continue.
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});
  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;
  bool _resent = false;
  String? _msg;

  Future<void> _check() async {
    setState(() { _checking = true; _msg = null; });
    final verified = await context.read<AuthService>().refreshVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (verified) {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const ScanConnectScreen()));
    } else {
      setState(() => _msg = 'Not verified yet — check your inbox and tap the link.');
    }
  }

  Future<void> _resend() async {
    await context.read<AuthService>().resendVerification();
    if (!mounted) return;
    setState(() => _resent = true);
  }

  @override
  Widget build(BuildContext context) {
    final email = context.read<AuthService>().email ?? 'your email';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 72, color: AppColors.accent),
              const SizedBox(height: 20),
              Text('Verify your email', textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 10),
              Text('We sent a verification link to:\n$email\n\nOpen it, then come back and continue.',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 28),
              if (_msg != null) ...[
                Text(_msg!, textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.warning, fontSize: 13)),
                const SizedBox(height: 12),
              ],
              GradientButton(
                label: "I've verified — continue",
                icon: Icons.check_circle_outline,
                loading: _checking,
                onTap: _check,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _resent ? null : _resend,
                icon: const Icon(Icons.refresh),
                label: Text(_resent ? 'Verification email sent' : 'Resend email'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  context.read<AuthService>().signOut();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                },
                child: const Text('Use a different account',
                    style: TextStyle(color: AppColors.textMuted)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
