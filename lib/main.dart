import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:installment_app/firebase_options.dart';
import 'package:installment_app/providers/auth_provider.dart';
import 'package:installment_app/providers/customer_provider.dart';
import 'package:installment_app/providers/theme_provider.dart';
import 'package:installment_app/ui/screens/auth_screen.dart';
import 'package:installment_app/ui/screens/settings_screen.dart';
import 'package:installment_app/ui/splash_screen.dart';
import 'package:provider/provider.dart';

Future<void> _initializeAppDependencies() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeAppDependencies();

  final provider = CustomerProvider();
  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: provider),
        ChangeNotifierProvider.value(value: authProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const InstallmentApp(),
    ),
  );
}

class InstallmentApp extends StatelessWidget {
  const InstallmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final preset = themeProvider.activePreset;

    return MaterialApp(
      // Rebuild the whole MaterialApp when theme changes.
      key: ValueKey(themeProvider.selectedThemeIndex),
      title: 'Installment Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: preset.seedColor),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
