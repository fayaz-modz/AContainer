// ignore_for_file: constant_identifier_names

import 'package:get/get.dart';

import '../modules/container_detail/bindings/container_detail_binding.dart';
import '../modules/container_detail/views/container_detail_view.dart';
import '../modules/create_container/bindings/create_container_binding.dart';
import '../modules/create_container/views/create_container_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/terminal/bindings/terminal_binding.dart';
import '../modules/terminal/views/terminal_view.dart';
import '../modules/terminal/views/terminal_settings_view.dart';
import '../modules/settings/bindings/about_binding.dart';
import '../modules/settings/bindings/general_settings_binding.dart';
import '../modules/settings/views/about_view.dart';
import '../modules/settings/views/general_settings_view.dart';
import '../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CREATE_CONTAINER,
      page: () => const CreateContainerView(),
      binding: CreateContainerBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_CONTAINER,
      page: () => const CreateContainerView(),
      binding: CreateContainerBinding(),
    ),
    GetPage(
      name: _Paths.CONTAINER_DETAIL,
      page: () => ContainerDetailView(),
      binding: ContainerDetailBinding(),
    ),
    GetPage(
      name: _Paths.TERMINAL,
      page: () => TerminalView(),
      binding: TerminalBinding(),
    ),
    GetPage(
      name: _Paths.TERMINAL_SETTINGS,
      page: () => const TerminalSettingsView(),
    ),
    GetPage(
      name: _Paths.GENERAL_SETTINGS,
      page: () => const GeneralSettingsView(),
      binding: GeneralSettingsBinding(),
    ),
    GetPage(
      name: _Paths.ABOUT,
      page: () => const AboutView(),
      binding: AboutBinding(),
    ),
    GetPage(name: _Paths.SETTINGS, page: () => const SettingsView()),
  ];
}
