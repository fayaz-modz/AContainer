import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:xterm/xterm.dart' as xterm;
import 'app_themes.dart';

class TerminalThemeController extends GetxController {
  static const String _terminalThemeKey = 'terminal_theme';
  static const String _customThemeKey = 'custom_terminal_theme';

  final RxString _currentThemeName = 'default'.obs;
  final Rx<xterm.TerminalTheme> _customTheme = Rx<xterm.TerminalTheme>(
    xterm.TerminalTheme(
      cursor: Color(0XAAAEAFAD),
      selection: Color(0XAAAEAFAD),
      foreground: Color(0XFFCCCCCC),
      background: Color(0XFF1E1E1E),
      black: Color(0XFF000000),
      red: Color(0XFFCD3131),
      green: Color(0XFF0DBC79),
      yellow: Color(0XFFE5E510),
      blue: Color(0XFF2472C8),
      magenta: Color(0XFFBC3FBC),
      cyan: Color(0XFF11A8CD),
      white: Color(0XFFE5E5E5),
      brightBlack: Color(0XFF666666),
      brightRed: Color(0XFFF14C4C),
      brightGreen: Color(0XFF23D18B),
      brightYellow: Color(0XFFF5F543),
      brightBlue: Color(0XFF3B8EEA),
      brightMagenta: Color(0XFFD670D6),
      brightCyan: Color(0XFF29B8DB),
      brightWhite: Color(0XFFFFFFFF),
      searchHitBackground: Color(0XFFFFFF2B),
      searchHitBackgroundCurrent: Color(0XFF31FF26),
      searchHitForeground: Color(0XFF000000),
    ),
  );
  final Rx<xterm.TerminalTheme> _currentTerminalTheme = Rx<xterm.TerminalTheme>(
    xterm.TerminalTheme(
      cursor: Color(0XAAAEAFAD),
      selection: Color(0XAAAEAFAD),
      foreground: Color(0XFFCCCCCC),
      background: Color(0XFF1E1E1E),
      black: Color(0XFF000000),
      red: Color(0XFFCD3131),
      green: Color(0XFF0DBC79),
      yellow: Color(0XFFE5E510),
      blue: Color(0XFF2472C8),
      magenta: Color(0XFFBC3FBC),
      cyan: Color(0XFF11A8CD),
      white: Color(0XFFE5E5E5),
      brightBlack: Color(0XFF666666),
      brightRed: Color(0XFFF14C4C),
      brightGreen: Color(0XFF23D18B),
      brightYellow: Color(0XFFF5F543),
      brightBlue: Color(0XFF3B8EEA),
      brightMagenta: Color(0XFFD670D6),
      brightCyan: Color(0XFF29B8DB),
      brightWhite: Color(0XFFFFFFFF),
      searchHitBackground: Color(0XFFFFFF2B),
      searchHitBackgroundCurrent: Color(0XFF31FF26),
      searchHitForeground: Color(0XFF000000),
    ),
  );

  static final TerminalThemeController _instance = TerminalThemeController._internal();
  factory TerminalThemeController() => _instance;
  TerminalThemeController._internal();

  static TerminalThemeController get instance => _instance;

  String get currentThemeName => _currentThemeName.value;
  xterm.TerminalTheme get terminalTheme => _currentTerminalTheme.value;

@override
  void onInit() {
    super.onInit();
    _loadThemeSettings();
    _updateCurrentTerminalTheme();
  }

  void _updateCurrentTerminalTheme() {
    _currentTerminalTheme.value = _currentThemeName.value == 'custom' 
        ? _customTheme.value 
        : AppThemes.getThemeByName(_currentThemeName.value).terminalTheme;
  }

  Future<void> _loadThemeSettings() async {
    try {
      // Ensure GetStorage is initialized
      await GetStorage.init();
      final box = GetStorage();
      final themeName = box.read(_terminalThemeKey) ?? 'default';
      _currentThemeName.value = themeName;

      if (themeName == 'custom') {
        final customThemeJson = box.read(_customThemeKey);
        if (customThemeJson != null && customThemeJson is Map<String, dynamic>) {
          _customTheme.value = _terminalThemeFromJson(customThemeJson);
        }
      }
      
      _updateCurrentTerminalTheme();
    } catch (e) {
      Get.log('Error loading terminal theme settings: $e');
    }
  }

  Future<void> setTheme(String themeName) async {
    final box = GetStorage();
    try {
      _currentThemeName.value = themeName;
      await box.write(_terminalThemeKey, themeName);
      
      if (themeName != 'custom') {
        final appTheme = AppThemes.getThemeByName(themeName);
        _customTheme.value = appTheme.terminalTheme;
        await box.write(_customThemeKey, _terminalThemeToJson(_customTheme.value));
      }
      
      _updateCurrentTerminalTheme();
      
      // Force a UI update
      update();
    } catch (e) {
      Get.log('Error setting terminal theme: $e');
      // Revert the change if storage failed
      _currentThemeName.value = box.read(_terminalThemeKey) ?? 'default';
      _updateCurrentTerminalTheme();
    }
  }

  Future<void> updateCustomTheme({
    Color? cursor,
    Color? selection,
    Color? foreground,
    Color? background,
    Color? black,
    Color? white,
    Color? red,
    Color? green,
    Color? yellow,
    Color? blue,
    Color? magenta,
    Color? cyan,
    Color? brightBlack,
    Color? brightRed,
    Color? brightGreen,
    Color? brightYellow,
    Color? brightBlue,
    Color? brightMagenta,
    Color? brightCyan,
    Color? brightWhite,
    Color? searchHitBackground,
    Color? searchHitBackgroundCurrent,
    Color? searchHitForeground,
  }) async {
    try {
      _customTheme.value = xterm.TerminalTheme(
        cursor: cursor ?? _customTheme.value.cursor,
        selection: selection ?? _customTheme.value.selection,
        foreground: foreground ?? _customTheme.value.foreground,
        background: background ?? _customTheme.value.background,
        black: black ?? _customTheme.value.black,
        white: white ?? _customTheme.value.white,
        red: red ?? _customTheme.value.red,
        green: green ?? _customTheme.value.green,
        yellow: yellow ?? _customTheme.value.yellow,
        blue: blue ?? _customTheme.value.blue,
        magenta: magenta ?? _customTheme.value.magenta,
        cyan: cyan ?? _customTheme.value.cyan,
        brightBlack: brightBlack ?? _customTheme.value.brightBlack,
        brightRed: brightRed ?? _customTheme.value.brightRed,
        brightGreen: brightGreen ?? _customTheme.value.brightGreen,
        brightYellow: brightYellow ?? _customTheme.value.brightYellow,
        brightBlue: brightBlue ?? _customTheme.value.brightBlue,
        brightMagenta: brightMagenta ?? _customTheme.value.brightMagenta,
        brightCyan: brightCyan ?? _customTheme.value.brightCyan,
        brightWhite: brightWhite ?? _customTheme.value.brightWhite,
        searchHitBackground: searchHitBackground ?? _customTheme.value.searchHitBackground,
        searchHitBackgroundCurrent: searchHitBackgroundCurrent ?? _customTheme.value.searchHitBackgroundCurrent,
        searchHitForeground: searchHitForeground ?? _customTheme.value.searchHitForeground,
      );

      final box = GetStorage();
      await box.write(_customThemeKey, _terminalThemeToJson(_customTheme.value));
      
      _updateCurrentTerminalTheme();
    } catch (e) {
      Get.log('Error updating custom terminal theme: $e');
    }
  }

  Future<void> resetToDefault() async {
    try {
      final defaultTheme = AppThemes.getThemeByName('default').terminalTheme;
      _customTheme.value = defaultTheme;
      
      final box = GetStorage();
      await box.write(_customThemeKey, _terminalThemeToJson(_customTheme.value));
      
      _updateCurrentTerminalTheme();
    } catch (e) {
      Get.log('Error resetting terminal theme: $e');
    }
  }

  Future<void> loadFromAppTheme(String themeName) async {
    try {
      final appTheme = AppThemes.getThemeByName(themeName);
      _customTheme.value = appTheme.terminalTheme;
      
      final box = GetStorage();
      await box.write(_customThemeKey, _terminalThemeToJson(_customTheme.value));
      
      _updateCurrentTerminalTheme();
    } catch (e) {
      Get.log('Error loading terminal theme from app theme: $e');
    }
  }

  Map<String, dynamic> _terminalThemeToJson(xterm.TerminalTheme theme) {
    return {
      'cursor': theme.cursor.value,
      'selection': theme.selection.value,
      'foreground': theme.foreground.value,
      'background': theme.background.value,
      'black': theme.black.value,
      'white': theme.white.value,
      'red': theme.red.value,
      'green': theme.green.value,
      'yellow': theme.yellow.value,
      'blue': theme.blue.value,
      'magenta': theme.magenta.value,
      'cyan': theme.cyan.value,
      'brightBlack': theme.brightBlack.value,
      'brightRed': theme.brightRed.value,
      'brightGreen': theme.brightGreen.value,
      'brightYellow': theme.brightYellow.value,
      'brightBlue': theme.brightBlue.value,
      'brightMagenta': theme.brightMagenta.value,
      'brightCyan': theme.brightCyan.value,
      'brightWhite': theme.brightWhite.value,
      'searchHitBackground': theme.searchHitBackground.value,
      'searchHitBackgroundCurrent': theme.searchHitBackgroundCurrent.value,
      'searchHitForeground': theme.searchHitForeground.value,
    };
  }

  xterm.TerminalTheme _terminalThemeFromJson(Map<String, dynamic> json) {
    return xterm.TerminalTheme(
      cursor: Color(json['cursor'] ?? 0xFFAEAFAD),
      selection: Color(json['selection'] ?? 0xFFAEAFAD),
      foreground: Color(json['foreground'] ?? 0xFFCCCCCC),
      background: Color(json['background'] ?? 0xFF1E1E1E),
      black: Color(json['black'] ?? 0xFF000000),
      white: Color(json['white'] ?? 0xFFE5E5E5),
      red: Color(json['red'] ?? 0xFFCD3131),
      green: Color(json['green'] ?? 0xFF0DBC79),
      yellow: Color(json['yellow'] ?? 0xFFE5E510),
      blue: Color(json['blue'] ?? 0xFF2472C8),
      magenta: Color(json['magenta'] ?? 0xFFBC3FBC),
      cyan: Color(json['cyan'] ?? 0xFF11A8CD),
      brightBlack: Color(json['brightBlack'] ?? 0xFF666666),
      brightRed: Color(json['brightRed'] ?? 0xFFF14C4C),
      brightGreen: Color(json['brightGreen'] ?? 0xFF23D18B),
      brightYellow: Color(json['brightYellow'] ?? 0xFFF5F543),
      brightBlue: Color(json['brightBlue'] ?? 0xFF3B8EEA),
      brightMagenta: Color(json['brightMagenta'] ?? 0xFFD670D6),
      brightCyan: Color(json['brightCyan'] ?? 0xFF29B8DB),
      brightWhite: Color(json['brightWhite'] ?? 0xFFFFFFFF),
      searchHitBackground: Color(json['searchHitBackground'] ?? 0xFFFFFF2B),
      searchHitBackgroundCurrent: Color(json['searchHitBackgroundCurrent'] ?? 0xFF31FF26),
      searchHitForeground: Color(json['searchHitForeground'] ?? 0xFF000000),
    );
  }
}