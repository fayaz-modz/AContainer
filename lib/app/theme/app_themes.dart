import 'package:flutter/material.dart';
import 'package:xterm/xterm.dart' as xterm;

class AppThemeData {
  final String name;
  final String displayName;
  final ThemeData themeData;
  final ColorScheme colorScheme;
  final xterm.TerminalTheme terminalTheme;

  const AppThemeData({
    required this.name,
    required this.displayName,
    required this.themeData,
    required this.colorScheme,
    required this.terminalTheme,
  });
}

class AppThemes {
  static final _defaultTheme = AppThemeData(
    name: 'default',
    displayName: 'Default',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF6750A4),
        brightness: Brightness.light,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF6750A4),
      brightness: Brightness.light,
    ),
    terminalTheme: xterm.TerminalTheme(
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

  static final _darkTheme = AppThemeData(
    name: 'dark',
    displayName: 'Dark',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF6750A4),
        brightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
    terminalTheme: xterm.TerminalTheme(
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

  static final _catppuccinLatteTheme = AppThemeData(
    name: 'catppuccin_latte',
    displayName: 'Catppuccin Latte',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF1E66F5),
        brightness: Brightness.light,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF1E66F5),
      secondary: Color(0xFFDC8A78),
      surface: Color(0xFFEFF1F5),
      onSurface: Color(0xFF4C4F69),
      background: Color(0xFFEFF1F5),
      onBackground: Color(0xFF4C4F69),
      onPrimary: Color(0xFFFFFFFF),
      onSecondary: Color(0xFF000000),
    ),
    terminalTheme: xterm.TerminalTheme(
      cursor: Color(0xFF1E66F5),
      selection: Color(0x801E66F5),
      foreground: Color(0xFF4C4F69),
      background: Color(0xFFEFF1F5),
      black: Color(0xFF5C5F77),
      red: Color(0xFFD20F39),
      green: Color(0xFF40A02B),
      yellow: Color(0xFFDF8E1D),
      blue: Color(0xFF1E66F5),
      magenta: Color(0xFFEA76CB),
      cyan: Color(0xFF179299),
      white: Color(0xFFACB0BE),
      brightBlack: Color(0xFF6C6F85),
      brightRed: Color(0xFFDE293E),
      brightGreen: Color(0xFF49AF3D),
      brightYellow: Color(0xFFEEA02D),
      brightBlue: Color(0xFF456EFF),
      brightMagenta: Color(0xFFFE85D8),
      brightCyan: Color(0xFF2D9FA8),
      brightWhite: Color(0xFFBCC0CC),
      searchHitBackground: Color(0x801E66F5),
      searchHitBackgroundCurrent: Color(0xFF40A02B),
      searchHitForeground: Color(0xFFEFF1F5),
    ),
  );

  static final _catppuccinFrappeTheme = AppThemeData(
    name: 'catppuccin_frappe',
    displayName: 'Catppuccin Frappé',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF8CAAEE),
        brightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF8CAAEE),
      secondary: Color(0xFFF2D5CF),
      surface: Color(0xFF303446),
      onSurface: Color(0xFFC6D0F5),
      background: Color(0xFF303446),
      onBackground: Color(0xFFC6D0F5),
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
    ),
    terminalTheme: xterm.TerminalTheme(
      cursor: Color(0xFF8CAAEE),
      selection: Color(0x808CAAEE),
      foreground: Color(0xFFC6D0F5),
      background: Color(0xFF303446),
      black: Color(0xFF51576D),
      red: Color(0xFFE78284),
      green: Color(0xFFA6D189),
      yellow: Color(0xFFE5C890),
      blue: Color(0xFF8CAAEE),
      magenta: Color(0xFFF4B8E4),
      cyan: Color(0xFF81C8BE),
      white: Color(0xFFA5ADCE),
      brightBlack: Color(0xFF626880),
      brightRed: Color(0xFFE67172),
      brightGreen: Color(0xFF8EC772),
      brightYellow: Color(0xFFD9BA73),
      brightBlue: Color(0xFF7B9EF0),
      brightMagenta: Color(0xFFF2A4DB),
      brightCyan: Color(0xFF5ABFB5),
      brightWhite: Color(0xFFB5BFE2),
      searchHitBackground: Color(0x808CAAEE),
      searchHitBackgroundCurrent: Color(0xFFA6D189),
      searchHitForeground: Color(0xFF303446),
    ),
  );

  static final _catppuccinMacchiatoTheme = AppThemeData(
    name: 'catppuccin_macchiato',
    displayName: 'Catppuccin Macchiato',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF8AADF4),
        brightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF8AADF4),
      secondary: Color(0xFFF4DBD6),
      surface: Color(0xFF24273A),
      onSurface: Color(0xFFCAD3F5),
      background: Color(0xFF24273A),
      onBackground: Color(0xFFCAD3F5),
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
    ),
    terminalTheme: xterm.TerminalTheme(
      cursor: Color(0xFF8AADF4),
      selection: Color(0x808AADF4),
      foreground: Color(0xFFCAD3F5),
      background: Color(0xFF24273A),
      black: Color(0xFF494D64),
      red: Color(0xFFED8796),
      green: Color(0xFFA6DA95),
      yellow: Color(0xFFEED49F),
      blue: Color(0xFF8AADF4),
      magenta: Color(0xFFF5BDE6),
      cyan: Color(0xFF8BD5CA),
      white: Color(0xFFA5ADCB),
      brightBlack: Color(0xFF5B6078),
      brightRed: Color(0xFFEC7486),
      brightGreen: Color(0xFF8CCF7F),
      brightYellow: Color(0xFFE1C682),
      brightBlue: Color(0xFF78A1F6),
      brightMagenta: Color(0xFFF2A9DD),
      brightCyan: Color(0xFF63CBC0),
      brightWhite: Color(0xFFB8C0E0),
      searchHitBackground: Color(0x808AADF4),
      searchHitBackgroundCurrent: Color(0xFFA6DA95),
      searchHitForeground: Color(0xFF24273A),
    ),
  );

  static final _catppuccinMochaTheme = AppThemeData(
    name: 'catppuccin_mocha',
    displayName: 'Catppuccin Mocha',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFcba6f7),
        brightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFcba6f7),
      secondary: Color(0xFFf5e0dc),
      surface: Color(0xFF1e1e2e),
      onSurface: Color(0xFFcdd6f4),
      background: Color(0xFF1e1e2e),
      onBackground: Color(0xFFcdd6f4),
      onPrimary: Color(0xFF000000),
      onSecondary: Color(0xFF000000),
    ),
    terminalTheme: xterm.TerminalTheme(
      cursor: Color(0xFFf5e0dc),
      selection: Color(0xFFf5e0dc),
      foreground: Color(0xFFcdd6f4),
      background: Color(0xFF1e1e2e),
      black: Color(0xFF45475a),
      red: Color(0xFFf38ba8),
      green: Color(0xFFa6e3a1),
      yellow: Color(0xFFf9e2af),
      blue: Color(0xFF89b4fa),
      magenta: Color(0xFFf5c2e7),
      cyan: Color(0xFF94e2d5),
      white: Color(0xFFbac2de),
      brightBlack: Color(0xFF585b70),
      brightRed: Color(0xFFf38ba8),
      brightGreen: Color(0xFFa6e3a1),
      brightYellow: Color(0xFFf9e2af),
      brightBlue: Color(0xFF89b4fa),
      brightMagenta: Color(0xFFf5c2e7),
      brightCyan: Color(0xFF94e2d5),
      brightWhite: Color(0xFFa6adc8),
      searchHitBackground: Color(0x80cba6f7),
      searchHitBackgroundCurrent: Color(0xFFa6e3a1),
      searchHitForeground: Color(0xFF1e1e2e),
    ),
  );

  static final _draculaTheme = AppThemeData(
    name: 'dracula',
    displayName: 'Dracula',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFBD93F9),
        brightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFBD93F9),
      secondary: Color(0xFF50FA7B),
      surface: Color(0xFF282A36),
      onSurface: Color(0xFFF8F8F2),
    ),
    terminalTheme: xterm.TerminalTheme(
      cursor: Color(0xFFF8F8F2),
      selection: Color(0x80BD93F9),
      foreground: Color(0xFFF8F8F2),
      background: Color(0xFF282A36),
      black: Color(0xFF21222C),
      red: Color(0xFFFF5555),
      green: Color(0xFF50FA7B),
      yellow: Color(0xFFF1FA8C),
      blue: Color(0xFF6272A4),
      magenta: Color(0xFFBD93F9),
      cyan: Color(0xFF8BE9FD),
      white: Color(0xFFF8F8F2),
      brightBlack: Color(0xFF6272A4),
      brightRed: Color(0xFFFF6E6E),
      brightGreen: Color(0xFF69FF94),
      brightYellow: Color(0xFFFFA657),
      brightBlue: Color(0xFFD6ACFF),
      brightMagenta: Color(0xFFFF92DF),
      brightCyan: Color(0xFFA4FFFF),
      brightWhite: Color(0xFFFFFFFF),
      searchHitBackground: Color(0x80BD93F9),
      searchHitBackgroundCurrent: Color(0xFF50FA7B),
      searchHitForeground: Color(0xFF282A36),
    ),
  );

  static final _gruvboxDarkTheme = AppThemeData(
    name: 'gruvbox_dark',
    displayName: 'Gruvbox Dark',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFFD3869B),
        brightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFFD3869B),
      secondary: Color(0xFF8EC07C),
      surface: Color(0xFF282828),
      onSurface: Color(0xFFEBDBB2),
    ),
    terminalTheme: xterm.TerminalTheme(
      cursor: Color(0xFFEBDBB2),
      selection: Color(0x80D3869B),
      foreground: Color(0xFFEBDBB2),
      background: Color(0xFF282828),
      black: Color(0xFF282828),
      red: Color(0xFFCC241D),
      green: Color(0xFF98971A),
      yellow: Color(0xFFD79921),
      blue: Color(0xFF458588),
      magenta: Color(0xFFB16286),
      cyan: Color(0xFF689D6A),
      white: Color(0xFFA89984),
      brightBlack: Color(0xFF928374),
      brightRed: Color(0xFFFB4934),
      brightGreen: Color(0xFFB8BB26),
      brightYellow: Color(0xFFFABD2F),
      brightBlue: Color(0xFF83A598),
      brightMagenta: Color(0xFFD3869B),
      brightCyan: Color(0xFF8EC07C),
      brightWhite: Color(0xFFEBDBB2),
      searchHitBackground: Color(0x80D3869B),
      searchHitBackgroundCurrent: Color(0xFF98971A),
      searchHitForeground: Color(0xFF282828),
    ),
  );

  static final _monokaiTheme = AppThemeData(
    name: 'monokai',
    displayName: 'Monokai',
    themeData: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Color(0xFF66D9EF),
        brightness: Brightness.dark,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF66D9EF),
      secondary: Color(0xFFA6E22E),
      surface: Color(0xFF272822),
      onSurface: Color(0xFFF8F8F2),
    ),
    terminalTheme: xterm.TerminalTheme(
      cursor: Color(0xFFF8F8F2),
      selection: Color(0x8066D9EF),
      foreground: Color(0xFFF8F8F2),
      background: Color(0xFF272822),
      black: Color(0xFF272822),
      red: Color(0xFFF92672),
      green: Color(0xFFA6E22E),
      yellow: Color(0xFFF4BF75),
      blue: Color(0xFF66D9EF),
      magenta: Color(0xFFAE81FF),
      cyan: Color(0xFFA1EFD3),
      white: Color(0xFFF8F8F2),
      brightBlack: Color(0xFF75715E),
      brightRed: Color(0xFFF92672),
      brightGreen: Color(0xFFA6E22E),
      brightYellow: Color(0xFFF4BF75),
      brightBlue: Color(0xFF66D9EF),
      brightMagenta: Color(0xFFAE81FF),
      brightCyan: Color(0xFFA1EFD3),
      brightWhite: Color(0xFFF9F8F5),
      searchHitBackground: Color(0x8066D9EF),
      searchHitBackgroundCurrent: Color(0xFFA6E22E),
      searchHitForeground: Color(0xFF272822),
    ),
  );

  static final List<AppThemeData> allThemes = [
    _defaultTheme,
    _darkTheme,
    _catppuccinLatteTheme,
    _catppuccinFrappeTheme,
    _catppuccinMacchiatoTheme,
    _catppuccinMochaTheme,
    _draculaTheme,
    _gruvboxDarkTheme,
    _monokaiTheme,
  ];

  static AppThemeData getThemeByName(String name) {
    return allThemes.firstWhere(
      (theme) => theme.name == name,
      orElse: () => _defaultTheme,
    );
  }

  static AppThemeData getThemeByDisplayName(String displayName) {
    return allThemes.firstWhere(
      (theme) => theme.displayName == displayName,
      orElse: () => _defaultTheme,
    );
  }
}