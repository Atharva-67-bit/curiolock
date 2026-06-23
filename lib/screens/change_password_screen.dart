import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/vault_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _current = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _busy = false;

  bool get _lenOk => _new.text.length >= 4;
  bool get _matchOk => _new.text.isNotEmpty && _new.text == _confirm.text;
  bool get _canSubmit => _current.text.length >= 4 && _lenOk && _matchOk;

  Future<void> _submit() async {
    setState(() => _busy = true);
    final ok = await context.read<VaultController>().changePassword(_current.text, _new.text);
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(ok ? 'Password updated' : 'Current password is wrong'),
      backgroundColor: ok ? AppColors.success : AppColors.danger,
    ));
    if (ok) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            CurioCard(
              child: Column(children: [
                _field(_current, 'Current password'),
                const Divider(height: 28, color: AppColors.surfaceBorder),
                _field(_new, 'New password'),
                const Divider(height: 28, color: AppColors.surfaceBorder),
                _field(_confirm, 'Confirm new password'),
              ]),
            ),
            const SizedBox(height: 16),
            Row(children: [
              _chip('4+ digits', _lenOk),
              const SizedBox(width: 10),
              _chip('matches', _matchOk),
            ]),
            const SizedBox(height: 24),
            GradientButton(
              label: 'Update Password',
              icon: Icons.key_rounded,
              loading: _busy,
              onTap: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController c, String hint) => TextField(
        controller: c,
        obscureText: true,
        keyboardType: TextInputType.number,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: hint, border: InputBorder.none, filled: false),
      );

  Widget _chip(String label, bool ok) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: (ok ? AppColors.success : AppColors.textMuted).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(ok ? Icons.check_circle : Icons.circle_outlined,
              size: 15, color: ok ? AppColors.success : AppColors.textMuted),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: ok ? AppColors.success : AppColors.textMuted, fontSize: 12)),
        ]),
      );
}
