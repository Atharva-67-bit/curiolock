import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../state/vault_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';
import 'keypad_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final c = context.watch<VaultController>();
    final s = c.status;
    final locked = s.locked;
    final stateColor = locked ? AppColors.danger : AppColors.success;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(_greeting(context), style: Theme.of(context).textTheme.titleLarge)),
                  const Spacer(),
                  StatusPill(
                    label: c.connected ? 'Connected' : (c.busy ? 'Scanning' : 'Offline'),
                    color: c.connected ? AppColors.accent : AppColors.warning,
                    icon: c.connected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Big status card
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: stateColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: stateColor.withValues(alpha: 0.5)),
                ),
                child: Column(children: [
                  Icon(locked ? Icons.lock_rounded : Icons.lock_open_rounded,
                      size: 64, color: stateColor),
                  const SizedBox(height: 12),
                  Text(locked ? 'LOCKED' : 'UNLOCKED',
                      style: TextStyle(color: stateColor, fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(locked ? 'Locked & secure 🔒' : 'Open — welcome in! 🎉',
                      style: Theme.of(context).textTheme.bodySmall),
                ]),
              ),
              const SizedBox(height: 16),

              // Battery + last access
              Row(children: [
                Expanded(
                  child: CurioCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Icon(_batteryIcon(s.battery), color: _batteryColor(s.battery)),
                      const SizedBox(height: 8),
                      Text('${s.battery}%', style: Theme.of(context).textTheme.titleLarge),
                      Text('Battery', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: CurioCard(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Icon(Icons.history, color: AppColors.accent),
                      const SizedBox(height: 8),
                      Text(
                        _lastAccess(c.lastAccessAt),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text('Last access', style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  ),
                ),
              ]),
              const Spacer(),

              if (!c.connected)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    c.busy ? 'Pairing with vault…' : 'Connect to your vault to use the keypad',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.warning, fontSize: 13),
                  ),
                ),
              Opacity(
                opacity: c.connected ? 1 : 0.5,
                child: GradientButton(
                  label: 'Open Smart Keypad',
                  icon: Icons.dialpad_rounded,
                  onTap: c.connected
                      ? () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const KeypadScreen()),
                          )
                      : null,
                ),
              ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => c.lock(),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Lock Now'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                    onPressed: () => c.emergencyLock(),
                    icon: const Icon(Icons.warning_amber_rounded),
                    label: const Text('Emergency'),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _greeting(BuildContext context) {
    final h = DateTime.now().hour;
    final part = h < 12 ? 'Good morning' : (h < 17 ? 'Good afternoon' : 'Good evening');
    final emoji = h < 12 ? '☀️' : (h < 17 ? '👋' : '🌙');
    return '$part, ${_name(context)} $emoji';
  }

  String _name(BuildContext context) {
    final auth = context.read<AuthService>();
    final dn = auth.displayName;
    if (dn != null && dn.trim().isNotEmpty) return dn.split(' ').first;
    final n = (auth.email ?? '').split('@').first;
    return n.isEmpty ? 'there' : n;
  }

  String _lastAccess(DateTime? t) {
    if (t == null) return '—';
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 60) return 'Just now';
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return DateFormat('MMM d, HH:mm').format(t);
  }

  IconData _batteryIcon(int b) => b > 60
      ? Icons.battery_full
      : b > 25
          ? Icons.battery_5_bar
          : Icons.battery_alert;
  Color _batteryColor(int b) => b > 25 ? AppColors.success : AppColors.warning;
}
