import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:installment_app/data/models/customer_model.dart';
import 'package:installment_app/firebase_options.dart';
import 'package:installment_app/providers/auth_provider.dart';
import 'package:installment_app/providers/customer_provider.dart';
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

  try {
    await Hive.initFlutter();
  } catch (error) {
    debugPrint('Hive initialization skipped: $error');
  }

  try {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CustomerModelAdapter());
    }
  } catch (error) {
    debugPrint('Hive adapter registration skipped: $error');
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
      ],
      child: const InstallmentApp(),
    ),
  );
}

class InstallmentApp extends StatelessWidget {
  const InstallmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Installment Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF122A5E)),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/auth': (_) => const AuthScreen(),
        '/settings': (_) => const SettingsScreen(),
      },
    );
  }
}
