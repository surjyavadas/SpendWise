import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Settings service for managing app-wide preferences
class SettingsService {
  static const String _themeKey = 'theme_mode';
  static const String _lastWarningDateKey = 'last_warning_date';

  final SharedPreferences _prefs;

  SettingsService(this._prefs);

  /// Get stored theme mode (System/Light/Dark)
  ThemeMode get themeMode {
    final stored = _prefs.getInt(_themeKey);
    if (stored == null) return ThemeMode.system;
    return ThemeMode.values[stored];
  }

  /// Save theme mode preference
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setInt(_themeKey, mode.index);
  }

  /// Check if warning was already shown today
  bool hasShownWarningToday() {
    final lastDate = _prefs.getString(_lastWarningDateKey);
    if (lastDate == null) return false;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastWarningDate = DateTime.parse(lastDate);
    final lastWarningDay = DateTime(lastWarningDate.year, lastWarningDate.month, lastWarningDate.day);
    
    return lastWarningDay == today;
  }

  /// Mark warning as shown today
  Future<void> markWarningShown() async {
    await _prefs.setString(_lastWarningDateKey, DateTime.now().toIso8601String());
  }
}
