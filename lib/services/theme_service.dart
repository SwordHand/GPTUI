import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themePrefsKey = 'theme_mode';
  static const String _colorPrefsKey = 'theme_color';

  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  static Future<ThemeService> create() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeService(prefs);
  }

  ThemeMode get themeMode {
    final value = _prefs.getString(_themePrefsKey);
    return ThemeMode.values.firstWhere(
          (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(_themePrefsKey, mode.name);
    notifyListeners();
  }

  Color get themeColor {
    final value = _prefs.getInt(_colorPrefsKey);
    return value != null ? Color(value) : Colors.blue;
  }

  Future<void> setThemeColor(Color color) async {
    await _prefs.setInt(_colorPrefsKey, color.value);
    notifyListeners();
  }

  bool get useDynamicColor {
    return _prefs.getBool('use_dynamic_color') ?? false;
  }

  Future<void> setUseDynamicColor(bool value) async {
    if (value != useDynamicColor) {
      await _prefs.setBool('use_dynamic_color', value);
      notifyListeners();
    }
  }

  List<ThemeColorOption> get themeColorOptions => [
    ThemeColorOption(
      name: '动态取色',
      color: themeColor,
      isDynamic: true,
    ),
    ThemeColorOption(
      name: '默认蓝色',
      color: Colors.blue,
    ),
    ThemeColorOption(
      name: '清新绿色',
      color: Colors.green,
    ),
    ThemeColorOption(
      name: '活力橙色',
      color: Colors.orange,
    ),
    ThemeColorOption(
      name: '浪漫紫色',
      color: Colors.purple,
    ),
  ];
}

class ThemeColorOption {
  final String name;
  final Color color;
  final bool isDynamic;

  const ThemeColorOption({
    required this.name,
    required this.color,
    this.isDynamic = false,
  });
}