import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/discovered_vault.dart';
import '../state/vault_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';
import 'home_shell.dart';

/// Proximity discovery + pairing. Scans for nearby CurioLock vaults, shows
/// them by signal strength, and pairs when you tap Connect. Once connected it
/// proceeds to the app (where the keypad becomes usable).
class ScanConnectScreen extends StatefulWidget {
  const ScanConnectScreen({super.key});
  @override
  State<ScanConnectScreen> createState() => _ScanConnectScreenState();
}

class _ScanConnectScreenState extends State<ScanConnectScreen> {
  VaultController? _controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller = context.read<VaultController>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VaultController>().startScan();
    });
  }

  @override
  void dispose() {
    _controller?.stopScan();
    super.dispose();
  }

  Future<void> _pair(DiscoveredVault v) async {
    final c = context.read<VaultController>();
    await c.connectToVault(v.id);
    if (!mounted) return;
    if (c.connected) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Pairing failed — move closer and try again'),
        backgroundColor: AppColors.danger,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<VaultController>();
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text('Find your vault', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              Text('Walk up to your Smart Vault — CurioLock will sense it over Bluetooth.',
                  style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 28),

              // radar pulse
              Expanded(
                flex: 0,
                child: _RadarPulse(active: c.nearby.isEmpty),
              ),
              const SizedBox(height: 24),

              if (c.nearby.isEmpty)
                Center(
                  child: Text(
                    c.scanning ? 'Scanning for nearby vaults…' : 'Tap retry to scan',
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    itemCount: c.nearby.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _vaultTile(c, c.nearby[i]),
                  ),
                ),

              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => c.startScan(),
                icon: const Icon(Icons.refresh, color: AppColors.accent),
                label: const Text('Rescan', style: TextStyle(color: AppColors.accent)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _vaultTile(VaultController c, DiscoveredVault v) {
    final pairing = c.pairingId == v.id;
    final color = v.inRange ? AppColors.success : AppColors.warning;
    return CurioCard(
      border: v.inRange ? AppColors.success.withValues(alpha: 0.4) : null,
      child: Row(children: [
        _SignalBars(bars: v.bars, color: color),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(v.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 2),
            Text('${v.proximity} · ${v.rssi} dBm', style: Theme.of(context).textTheme.bodySmall),
          ]),
        ),
        SizedBox(
          width: 104,
          height: 42,
          child: pairing
              ? const Center(child: SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2)))
              : GradientButton(
                  label: v.inRange ? 'Connect' : 'Too far',
                  onTap: v.inRange ? () => _pair(v) : null,
                ),
        ),
      ]),
    );
  }
}

class _SignalBars extends StatelessWidget {
  final int bars;
  final Color color;
  const _SignalBars({required this.bars, required this.color});
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(4, (i) {
        final on = i < bars;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          height: 8.0 + i * 6,
          width: 6,
          decoration: BoxDecoration(
            color: on ? color : AppColors.surfaceBorder,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}

class _RadarPulse extends StatefulWidget {
  final bool active;
  const _RadarPulse({required this.active});
  @override
  State<_RadarPulse> createState() => _RadarPulseState();
}

class _RadarPulseState extends State<_RadarPulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return Stack(
              alignment: Alignment.center,
              children: [
                for (final phase in [0.0, 0.5])
                  Opacity(
                    opacity: (1 - ((_ctrl.value + phase) % 1)).clamp(0.0, 1.0) * 0.4,
                    child: Container(
                      height: 40 + ((_ctrl.value + phase) % 1) * 110,
                      width: 40 + ((_ctrl.value + phase) % 1) * 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.accent, width: 2),
                      ),
                    ),
                  ),
                Container(
                  height: 64,
                  width: 64,
                  decoration: const BoxDecoration(gradient: AppColors.brandGradient, shape: BoxShape.circle),
                  child: const Icon(Icons.bluetooth_searching, color: Colors.white, size: 30),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
