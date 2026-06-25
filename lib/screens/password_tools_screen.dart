import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/vault_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';

/// Two tools: VERIFY a password (is this the current PIN?) and REVEAL the
/// current PIN. Both talk to the vault over BLE.
class PasswordToolsScreen extends StatefulWidget {
  const PasswordToolsScreen({super.key});
  @override
  State<PasswordToolsScreen> createState() => _PasswordToolsScreenState();
}

class _PasswordToolsScreenState extends State<PasswordToolsScreen> {
  final _checkCtrl = TextEditingController();
  bool _checking = false;
  bool? _checkResult; // null = not checked yet

  bool _revealing = false;
  String? _revealed;

  Future<void> _verify() async {
    if (_checkCtrl.text.length < 4) return;
    setState(() => _checking = true);
    final ok = await context.read<VaultController>().verifyPassword(_checkCtrl.text);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _checkResult = ok;
    });
  }

  Future<void> _reveal() async {
    setState(() {
      _revealing = true;
      _revealed = null;
    });
    final pin = await context.read<VaultController>().revealPassword();
    if (!mounted) return;
    setState(() {
      _revealing = false;
      _revealed = pin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // ---- VERIFY ----
            Text('Verify password', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Check if a PIN is the current one — without revealing it.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            CurioCard(
              child: Column(children: [
                TextField(
                  controller: _checkCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() => _checkResult = null),
                  decoration: const InputDecoration(hintText: 'Enter a PIN to check'),
                ),
                const SizedBox(height: 14),
                GradientButton(
                  label: 'Check',
                  icon: Icons.verified_user_outlined,
                  loading: _checking,
                  onTap: _checkCtrl.text.length >= 4 ? _verify : null,
                ),
                if (_checkResult != null) ...[
                  const SizedBox(height: 14),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(_checkResult! ? Icons.check_circle : Icons.cancel,
                        color: _checkResult! ? AppColors.success : AppColors.danger),
                    const SizedBox(width: 8),
                    Text(
                      _checkResult! ? 'Correct — this is the current PIN' : 'Incorrect PIN',
                      style: TextStyle(
                          color: _checkResult! ? AppColors.success : AppColors.danger,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                ],
              ]),
            ),

            const SizedBox(height: 28),

            // ---- REVEAL ----
            Text('Reveal current PIN', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text('Show the vault\'s current password. Keep it private.',
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            CurioCard(
              child: Column(children: [
                if (_revealed == null)
                  GradientButton(
                    label: 'Show current PIN',
                    icon: Icons.visibility_outlined,
                    loading: _revealing,
                    onTap: _reveal,
                  )
                else
                  Column(children: [
                    Text('Current PIN', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Text(
                      _revealed!,
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: 8, color: AppColors.accent),
                    ),
                    const SizedBox(height: 10),
                    TextButton.icon(
                      onPressed: () => setState(() => _revealed = null),
                      icon: const Icon(Icons.visibility_off_outlined, size: 18),
                      label: const Text('Hide'),
                    ),
                  ]),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'For security, the PIN normally stays inside the vault. Only reveal it when you trust your surroundings.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
