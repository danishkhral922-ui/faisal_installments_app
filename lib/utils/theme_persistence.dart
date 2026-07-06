import 'package:shared_preferences/shared_preferences.dart';

import '../providers/theme_provider.dart';

class ThemePersistence {
  static const _kThemeIndex = 'selected_theme_index';

  static Future<int?> loadSelectedThemeIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kThemeIndex);
  }

  static Future<void> saveSelectedThemeIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kThemeIndex, index);
  }

  static Future<void> applyThemeFromStorage({
    required ThemeProvider provider,
  }) async {
    final idx = await loadSelectedThemeIndex();
    if (idx == null) return;
    if (idx < 0 || idx >= provider.presets.length) return;
    provider.setThemeIndex(idx);
  }

  static ThemeDataPreset presetForIndex({
    required ThemeProvider provider,
    required int index,
  }) {
    if (index < 0 || index >= provider.presets.length) {
      return provider.presets.first;
    }
    return provider.presets[index];
  }
}
