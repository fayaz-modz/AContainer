import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../theme/app_theme.dart';

class AppThemeController extends GetxController {
  static AppThemeController get to => Get.find();
  final GetStorage _storage = GetStorage();

  // Theme mode
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;
  


  @override
  void onInit() {
    super.onInit();
    _loadSettings();
    // Apply initial theme
    ever(themeMode, (_) => _applyTheme());
  }

  void _loadSettings() {
    // Load theme mode
    final savedThemeMode = _storage.read('theme_mode');
    if (savedThemeMode != null) {
      switch (savedThemeMode) {
        case 'light':
          themeMode.value = ThemeMode.light;
          break;
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        default:
          themeMode.value = ThemeMode.system;
      }
    }


  }

  void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    _storage.write('theme_mode', modeString);
    Get.changeThemeMode(mode);
  }

  void _applyTheme() {
    final isDark = Get.isPlatformDarkMode ?? false;
    final currentThemeMode = themeMode.value;
    
    ThemeData theme;
    if (currentThemeMode == ThemeMode.dark || 
        (currentThemeMode == ThemeMode.system && isDark)) {
      theme = AppTheme.darkTheme();
    } else {
      theme = AppTheme.lightTheme();
    }

    Get.changeTheme(theme);
  }

  void resetToDefaults() {
    setThemeMode(ThemeMode.system);
  }
}