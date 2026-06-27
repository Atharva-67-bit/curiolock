import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'services/ble_service.dart';
import 'services/auth_service.dart';
import 'state/vault_controller.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';

// CurioLock — Smart Vault 3.0 companion. From Curiosity to Security.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Try to start Firebase. If it isn't configured yet (no google-services.json),
  // the app still runs with a demo login. See FIREBASE_SETUP.md.
  try {
    await Firebase.initializeApp();
    AuthService.firebaseReady = true;
  } catch (_) {
    AuthService.firebaseReady = false;
  }

  final ble = BleService();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VaultController(ble)),
        Provider(create: (_) => AuthService()),
      ],
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
