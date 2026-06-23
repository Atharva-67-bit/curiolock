import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../state/vault_controller.dart';
import '../theme/app_theme.dart';

/// Smart Keypad — enter a 4-digit PIN, send unlock over BLE.
/// Demo PIN in mock mode is 1234 (see BleService).
class KeypadScreen extends StatefulWidget {
  const KeypadScreen({super.key});
  @override
  State<KeypadScreen> createState() => _KeypadScreenState();
}

class _KeypadScreenState extends State<KeypadScreen> {
  String _pin = '';
  static const _len = 4;
  bool _error = false;
  bool _busy = false;

  void _tap(String d) {
    if (_pin.length >= _len || _busy) return;
    HapticFeedback.lightImpact();
    setState(() {
      _error = false;
      _pin += d;
    });
    if (_pin.length == _len) _submit();
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    final ok = await context.read<VaultController>().unlock(_pin);
    if (!mounted) return;
    setState(() => _busy = false);
    if (ok) {
      HapticFeedback.mediumImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vault unlocked'), backgroundColor: AppColors.success),
      );
      Navigator.of(context).pop();
    } else {
      HapticFeedback.heavyImpact();
      setState(() {
        _error = true;
        _pin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Password'), backgroundColor: Colors.transparent),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_len, (i) {
                final filled = i < _pin.length;
                final color = _error ? AppColors.danger : (filled ? AppColors.accent : AppColors.surfaceBorder);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 18,
                  width: 18,
                  decoration: BoxDecoration(
                    color: filled ? color : Colors.transparent,
                    border: Border.all(color: color, width: 2),
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(_error ? 'Wrong password — try again' : 'Enter your 4-digit PIN',
                style: TextStyle(color: _error ? AppColors.danger : AppColors.textMuted)),
            const Spacer(),
            // keypad grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (final n in ['1', '2', '3', '4', '5', '6', '7', '8', '9']) _key(n),
                  _iconKey(Icons.backspace_outlined, _backspace),
                  _key('0'),
                  _iconKey(Icons.check_rounded, _pin.length == _len ? _submit : null, color: AppColors.success),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _key(String n) => _KeyButton(label: n, onTap: () => _tap(n));
  Widget _iconKey(IconData ic, VoidCallback? onTap, {Color? color}) =>
      _KeyButton(icon: ic, color: color, onTap: onTap);
}

class _KeyButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Color? color;
  final VoidCallback? onTap;
  const _KeyButton({this.label, this.icon, this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Center(
          child: icon != null
              ? Icon(icon, color: color ?? AppColors.textPrimary, size: 26)
              : Text(label!, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
