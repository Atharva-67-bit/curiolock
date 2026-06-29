import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/curio_widgets.dart';
import 'scan_connect_screen.dart';

/// Shown after login when the account has no display name yet — asks for it once.
class NamePromptScreen extends StatefulWidget {
  const NamePromptScreen({super.key});
  @override
  State<NamePromptScreen> createState() => _NamePromptScreenState();
}

class _NamePromptScreenState extends State<NamePromptScreen> {
  final _name = TextEditingController();
  bool _saving = false;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty) return;
    setState(() => _saving = true);
    await context.read<AuthService>().updateName(_name.text.trim());
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ScanConnectScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('👋', style: TextStyle(fontSize: 64), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              Text('What should we call you?', textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('We\'ll use this to greet you in the app.',
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 28),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Your name'),
              ),
              const SizedBox(height: 20),
              GradientButton(
                label: 'Continue',
                icon: Icons.arrow_forward_rounded,
                loading: _saving,
                onTap: _name.text.trim().isEmpty ? null : _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
