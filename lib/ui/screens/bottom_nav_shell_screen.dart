import 'package:flutter/material.dart';

import 'add_customer_screen.dart';
import 'home_screen.dart';
import 'installments_screen.dart';

class BottomNavShellScreen extends StatefulWidget {
  const BottomNavShellScreen({super.key});

  @override
  State<BottomNavShellScreen> createState() => _BottomNavShellScreenState();
}

class _BottomNavShellScreenState extends State<BottomNavShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const selectedColor = Color(0xFF122A5E);
    const primaryBlue1 = Color(0xFF122A5E);
    const primaryBlue2 = Color(0xFF2A5298);
    const highlightOrange = Color(0xFFFFA726);

    final screens = [
      const HomeScreen(),
      const AddCustomerScreen(),
      const InstallmentsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: IndexedStack(index: _index, children: screens),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                // full width + small height
                padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryBlue1, primaryBlue2],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(0),
                    child: NavigationBar(
                      selectedIndex: _index,
                      onDestinationSelected: (int newIndex) {
                        setState(() => _index = newIndex);
                      },
                      backgroundColor: Colors.transparent,
                      indicatorColor: highlightOrange,
                      labelBehavior:
                          NavigationDestinationLabelBehavior.alwaysShow,
                      height: 62,
                      destinations: [
                        NavigationDestination(
                          icon: Icon(
                            Icons.home_outlined,
                            size: 22,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.70,
                            ),
                          ),
                          selectedIcon: const Icon(
                            Icons.home,
                            size: 22,
                            color: selectedColor,
                          ),
                          label: 'Home',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.person_add_outlined,
                            size: 22,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.70,
                            ),
                          ),
                          selectedIcon: const Icon(
                            Icons.person_add,
                            size: 22,
                            color: selectedColor,
                          ),
                          label: 'Add',
                        ),
                        NavigationDestination(
                          icon: Icon(
                            Icons.receipt_long_outlined,
                            size: 22,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.70,
                            ),
                          ),
                          selectedIcon: const Icon(
                            Icons.receipt_long,
                            size: 22,
                            color: selectedColor,
                          ),
                          label: 'Installments',
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
