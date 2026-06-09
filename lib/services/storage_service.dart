import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _themeKey = 'theme_mode';
  static const String _onboardingKey = 'onboarding_done';
  static const String _promptLengthKey = 'prompt_length';
  static const String _promptStyleKey = 'prompt_style';
  static const String _creditReminderKey = 'credit_reminder';
  static const String _appUpdatesKey = 'app_updates';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<String?> getThemeMode() async {
    final prefs = await _prefs;
    return prefs.getString(_themeKey);
  }

  Future<void> setThemeMode(String mode) async {
    final prefs = await _prefs;
    await prefs.setString(_themeKey, mode);
  }

  Future<bool> isOnboardingDone() async {
    final prefs = await _prefs;
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> setOnboardingDone() async {
    final prefs = await _prefs;
    await prefs.setBool(_onboardingKey, true);
  }

  Future<String> getPromptLength() async {
    final prefs = await _prefs;
    return prefs.getString(_promptLengthKey) ?? 'Standard';
  }

  Future<void> setPromptLength(String length) async {
    final prefs = await _prefs;
    await prefs.setString(_promptLengthKey, length);
  }

  Future<String> getPromptStyle() async {
    final prefs = await _prefs;
    return prefs.getString(_promptStyleKey) ?? 'Balanced';
  }

  Future<void> setPromptStyle(String style) async {
    final prefs = await _prefs;
    await prefs.setString(_promptStyleKey, style);
  }

  Future<bool> getCreditReminder() async {
    final prefs = await _prefs;
    return prefs.getBool(_creditReminderKey) ?? true;
  }

  Future<void> setCreditReminder(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_creditReminderKey, value);
  }

  Future<bool> getAppUpdates() async {
    final prefs = await _prefs;
    return prefs.getBool(_appUpdatesKey) ?? true;
  }

  Future<void> setAppUpdates(bool value) async {
    final prefs = await _prefs;
    await prefs.setBool(_appUpdatesKey, value);
  }

  Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.clear();
  }
}
