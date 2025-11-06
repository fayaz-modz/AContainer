import 'package:acontainer/app/bindings/app_bindings.dart';
import 'package:acontainer/app/theme/app_theme.dart';
import 'package:acontainer/app/theme/terminal_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';

void main() async {
  await GetStorage.init();

  // Initialize terminal theme controller
  TerminalThemeController.instance;

  runApp(
    DynamicColorBuilder(
      builder: (lightColorScheme, darkColorScheme) {
        return GetMaterialApp(
          title: "AContainer",
          initialBinding: AppBindings(),
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          theme: AppTheme.lightTheme(lightColorScheme),
          darkTheme: AppTheme.darkTheme(darkColorScheme),
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
        );
      },
    ),
  );
}
