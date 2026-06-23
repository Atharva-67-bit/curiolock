import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/vault_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';
import 'change_password_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.watch<VaultController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header('SECURITY'),
            CurioCard(
              child: Column(children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.key_rounded, color: AppColors.accent),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textMuted),
                  onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
                ),
                const Divider(color: AppColors.surfaceBorder),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.timer_outlined, color: AppColors.accent),
                  title: const Text('Auto-lock timer'),
                  trailing: DropdownButton<int>(
                    value: c.autoLockSeconds,
                    dropdownColor: AppColors.surface,
                    underline: const SizedBox(),
                    items: const [15, 30, 60, 120]
                        .map((s) => DropdownMenuItem(value: s, child: Text('${s}s')))
                        .toList(),
                    onChanged: (v) => v != null ? c.setAutoLock(v) : null,
                  ),
                ),
                const Divider(color: AppColors.surfaceBorder),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.notifications_active_outlined, color: AppColors.accent),
                  title: const Text('Wrong-password alert'),
                  value: c.wrongPasswordAlert,
                  activeThumbColor: AppColors.accent,
                  onChanged: c.setWrongPasswordAlert,
                ),
              ]),
            ),
            const SizedBox(height: 16),
            GradientButton(
              label: 'Emergency Lock',
              icon: Icons.warning_amber_rounded,
              onTap: () {
                c.emergencyLock();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Vault locked'), backgroundColor: AppColors.danger));
              },
            ),
            const SizedBox(height: 28),
            _header('COMING SOON'),
            const CurioCard(
              child: Column(children: [
                _SoonTile(icon: Icons.fingerprint, label: 'Fingerprint Authentication'),
                _SoonTile(icon: Icons.face_retouching_natural, label: 'Face Unlock'),
                _SoonTile(icon: Icons.wifi, label: 'WiFi Connectivity'),
                _SoonTile(icon: Icons.cloud_outlined, label: 'Remote Unlock'),
                _SoonTile(icon: Icons.notifications_none, label: 'Notifications', last: true),
              ]),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false),
              icon: const Icon(Icons.logout, color: AppColors.danger),
              label: const Text('Sign out', style: TextStyle(color: AppColors.danger)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String t) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(t, style: const TextStyle(color: AppColors.textMuted, fontSize: 12, letterSpacing: 1.2)),
      );
}

class _SoonTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool last;
  const _SoonTile({required this.icon, required this.label, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        enabled: false,
        leading: Icon(icon, color: AppColors.textMuted),
        title: Text(label, style: const TextStyle(color: AppColors.textMuted)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text('soon', style: TextStyle(color: AppColors.accent, fontSize: 11)),
        ),
      ),
      if (!last) const Divider(color: AppColors.surfaceBorder, height: 0),
    ]);
  }
}
