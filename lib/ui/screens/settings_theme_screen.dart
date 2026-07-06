import 'package:flutter/material.dart';

import '../../providers/theme_provider.dart';
import '../../utils/theme_persistence.dart';
import 'package:provider/provider.dart';

class SettingsThemeScreen extends StatefulWidget {
  const SettingsThemeScreen({super.key});

  @override
  State<SettingsThemeScreen> createState() => _SettingsThemeScreenState();
}

class _SettingsThemeScreenState extends State<SettingsThemeScreen> {
  int _selectedTheme = 0;

  @override
  void initState() {
    super.initState();
    // Initialize selected theme from provider (and persisted storage if provider loads it).
    final themeProvider = context.read<ThemeProvider>();
    _selectedTheme = themeProvider.selectedThemeIndex;
  }

  final _themes = const [
    _ThemeItem(
      name: 'Blue Ocean',
      top: Color(0xFF112A5C),
      mid: Color(0xFF1E3C72),
      bottom: Color(0xFF2A5298),
    ),
    _ThemeItem(
      name: 'Violet Glow',
      top: Color(0xFF2B1055),
      mid: Color(0xFF6A11CB),
      bottom: Color(0xFF2575FC),
    ),
    _ThemeItem(
      name: 'Dark Navy',
      top: Color(0xFF08102A),
      mid: Color(0xFF122A5E),
      bottom: Color(0xFF2A5298),
    ),
    _ThemeItem(
      name: 'Sky Light',
      top: Color(0xFF0B3D91),
      mid: Color(0xFF2575FC),
      bottom: Color(0xFF2A5298),
    ),
    _ThemeItem(
      name: 'Royal Purple',
      top: Color(0xFF3B0764),
      mid: Color(0xFF6A11CB),
      bottom: Color(0xFF4E54C8),
    ),
    _ThemeItem(
      name: 'Ocean Teal',
      top: Color(0xFF003C43),
      mid: Color(0xFF0E8AA0),
      bottom: Color(0xFF2A5298),
    ),
    _ThemeItem(
      name: 'Forest',
      top: Color(0xFF0B3D2E),
      mid: Color(0xFF0F766E),
      bottom: Color(0xFF2A5298),
    ),
    _ThemeItem(
      name: 'Indigo+',
      top: Color(0xFF130E5E),
      mid: Color(0xFF4B0082),
      bottom: Color(0xFF2A5298),
    ),
    _ThemeItem(
      name: 'Red Accent',
      top: Color(0xFF3A0A0A),
      mid: Color(0xFFB00020),
      bottom: Color(0xFF2A5298),
    ),
    _ThemeItem(
      name: 'Gold Marine',
      top: Color(0xFF0B2E4A),
      mid: Color(0xFF0E7490),
      bottom: Color(0xFFB45309),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final active = _themes[_selectedTheme];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme'),
        foregroundColor: Colors.white,
        backgroundColor: active.mid,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [active.top, active.mid, active.bottom],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _themes.length,
          itemBuilder: (context, i) {
            final t = _themes[i];
            final selected = i == _selectedTheme;

            return GestureDetector(
              onTap: () async {
                setState(() => _selectedTheme = i);
                final themeProvider = context.read<ThemeProvider>();
                themeProvider.setThemeIndex(i);
                await ThemePersistence.saveSelectedThemeIndex(i);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [t.top, t.mid, t.bottom],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: selected ? 0.35 : 0.18,
                      ),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: selected
                        ? Colors.orangeAccent
                        : Colors.white.withValues(alpha: 0.15),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          selected ? Icons.check_circle : Icons.color_lens,
                          color: selected
                              ? Colors.orangeAccent
                              : Colors.white70,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (selected)
                        const Text(
                          'Selected',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ThemeItem {
  final String name;
  final Color top;
  final Color mid;
  final Color bottom;

  const _ThemeItem({
    required this.name,
    required this.top,
    required this.mid,
    required this.bottom,
  });
}
