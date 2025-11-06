import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/app_theme_controller.dart';

class GeneralSettingsController extends GetxController {
  final AppThemeController _themeController = Get.find();

  // Getters for theme controller properties
  ThemeMode get themeMode => _themeController.themeMode.value;

  void setThemeMode(ThemeMode mode) {
    _themeController.setThemeMode(mode);
  }

  void resetToDefaults() {
    _themeController.resetToDefaults();
  }
}