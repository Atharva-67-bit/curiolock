import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/ble_service.dart';
import 'state/vault_controller.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

// CurioLock — Smart Vault 3.0 companion. From Curiosity to Security.
//
// Runs in MOCK mode out of the box (BleService.useMock = true), so the full
// UI demos with no hardware. Demo PIN is 1234. Flip useMock to false and wire
// flutter_blue_plus + Firebase per the design doc for the real build.
void main() {
  final ble = BleService();
  runApp(
    ChangeNotifierProvider(
      create: (_) => VaultController(ble),
      child: const CurioLockApp(),
    ),
  );
}

class CurioLockApp extends StatelessWidget {
  const CurioLockApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CurioLock',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const LoginScreen(),
    );
  }
}
