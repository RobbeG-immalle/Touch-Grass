import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch_grass/config/constants.dart';
import 'package:touch_grass/services/notification_service.dart';

class SettingsProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _notificationsEnabled = true;
  String _notificationTime = AppConstants.defaultNotificationTime;
  String _defaultVisibility = AppConstants.visibilityFriends;

  ThemeMode get themeMode => _themeMode;
  bool get notificationsEnabled => _notificationsEnabled;
  String get notificationTime => _notificationTime;
  String get defaultVisibility => _defaultVisibility;

  SettingsProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt(AppConstants.prefThemeMode) ?? 0;
    _themeMode = ThemeMode.values[themeIndex];
    _notificationsEnabled =
        prefs.getBool(AppConstants.prefNotificationsEnabled) ?? true;
    _notificationTime =
        prefs.getString(AppConstants.prefNotificationTime) ??
        AppConstants.defaultNotificationTime;
    _defaultVisibility =
        prefs.getString(AppConstants.prefDefaultVisibility) ??
        AppConstants.visibilityFriends;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.prefThemeMode, mode.index);
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.prefNotificationsEnabled, enabled);
    if (enabled) {
      final parts = _notificationTime.split(':');
      await NotificationService.instance.scheduleDailyNotification(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } else {
      await NotificationService.instance.cancelDailyNotification();
    }
  }

  Future<void> setNotificationTime(String time) async {
    _notificationTime = time;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefNotificationTime, time);
    if (_notificationsEnabled) {
      final parts = time.split(':');
      await NotificationService.instance.scheduleDailyNotification(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    }
  }

  Future<void> setDefaultVisibility(String visibility) async {
    _defaultVisibility = visibility;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefDefaultVisibility, visibility);
  }
}
