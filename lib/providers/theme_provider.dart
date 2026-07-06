import 'package:flutter/material.dart';

import '../utils/theme_persistence.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider();

  // 0..N indexes for predefined themes
  int _selectedThemeIndex = 0;

  // Backward-compatible name used elsewhere in the UI.
  int get selectedThemeIndex => _selectedThemeIndex;

  // 0..N list of predefined themes.
  final List<ThemeDataPreset> presets = const [
    ThemeDataPreset(
      name: 'Blue Ocean',
      top: Color(0xFF112A5C),
      mid: Color(0xFF1E3C72),
      bottom: Color(0xFF2A5298),
      seedColor: Color(0xFF122A5E),
    ),
    ThemeDataPreset(
      name: 'Violet Glow',
      top: Color(0xFF2B1055),
      mid: Color(0xFF6A11CB),
      bottom: Color(0xFF2575FC),
      seedColor: Color(0xFF6A11CB),
    ),
    ThemeDataPreset(
      name: 'Dark Navy',
      top: Color(0xFF08102A),
      mid: Color(0xFF122A5E),
      bottom: Color(0xFF2A5298),
      seedColor: Color(0xFF122A5E),
    ),
    ThemeDataPreset(
      name: 'Sky Light',
      top: Color(0xFF0B3D91),
      mid: Color(0xFF2575FC),
      bottom: Color(0xFF2A5298),
      seedColor: Color(0xFF2575FC),
    ),
    ThemeDataPreset(
      name: 'Ocean Teal',
      top: Color(0xFF003C43),
      mid: Color(0xFF0E8AA0),
      bottom: Color(0xFF2A5298),
      seedColor: Color(0xFF0E8AA0),
    ),
  ];

  ThemeDataPreset get activePreset => presets[_selectedThemeIndex];

  Future<void> applyStoredTheme() async {
    await ThemePersistence.applyThemeFromStorage(provider: this);
  }

  void setThemeIndex(int index) {
    if (index < 0 || index >= presets.length) return;
    _selectedThemeIndex = index;
    notifyListeners();
  }

  LinearGradient get appGradient => LinearGradient(
    colors: [activePreset.top, activePreset.mid, activePreset.bottom],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  Color get seedColor => activePreset.seedColor;
}

class ThemeDataPreset {
  final String name;
  final Color top;
  final Color mid;
  final Color bottom;
  final Color seedColor;

  const ThemeDataPreset({
    required this.name,
    required this.top,
    required this.mid,
    required this.bottom,
    required this.seedColor,
  });
}
