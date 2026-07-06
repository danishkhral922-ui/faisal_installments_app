import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:installment_app/providers/auth_provider.dart';
import 'package:installment_app/providers/customer_provider.dart';
import 'package:installment_app/ui/screens/auth_screen.dart';
import 'package:installment_app/ui/screens/bottom_nav_shell_screen.dart';
import 'package:installment_app/ui/screens/home_screen.dart';
import 'package:installment_app/ui/widgets/app_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('[SplashScreen] init start');

      final customerProvider = context.read<CustomerProvider>();
      final authProvider = context.read<AuthProvider>();

      debugPrint('[SplashScreen] initialize CustomerProvider');
      debugPrint('[SplashScreen] initialize AuthProvider');
      await Future.wait([
        customerProvider.initialize(),
        authProvider.initialize(),
      ]);

      debugPrint('[SplashScreen] init done');
      await Future.delayed(const Duration(milliseconds: 1200));
    } catch (e, s) {
      debugPrint('[SplashScreen] init failed: $e');
      debugPrint('[SplashScreen] stack: $s');
      // Continue to the next screen even if initialization fails.
    }

    if (!mounted) return;

    final auth = context.read<AuthProvider>();
    debugPrint(
      '[SplashScreen] navigate. isAuthenticated=${auth.isAuthenticated}',
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => auth.isAuthenticated
            ? const BottomNavShellScreen()
            : const AuthScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF112A5C), Color(0xFF2A5298), Color(0xFF5E7BE2)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -40,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orangeAccent.withValues(alpha: 0.18),
                ),
              ),
            ),
            Positioned(
              bottom: -50,
              left: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const AppLogo(),
                        const SizedBox(height: 24),
                        const Text(
                          'FAISAL ELECTRONICS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.4,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Manage customers, payments, and installments with elegance',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white70,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_rounded,
                                color: Colors.orangeAccent,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Secure • Fast • Smart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const SizedBox(
                          width: 180,
                          child: LinearProgressIndicator(
                            backgroundColor: Colors.white24,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.orangeAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
