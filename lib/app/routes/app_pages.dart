import 'package:get/get.dart';

import '../modules/container_detail/bindings/container_detail_binding.dart';
import '../modules/container_detail/views/container_detail_view.dart';
import '../modules/create_container/bindings/create_container_binding.dart';
import '../modules/create_container/views/create_container_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/terminal/bindings/terminal_binding.dart';
import '../modules/terminal/views/terminal_view.dart';

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
      name: _Paths.CONTAINER_DETAIL,
      page: () => ContainerDetailView(),
      binding: ContainerDetailBinding(),
    ),
    GetPage(
      name: _Paths.TERMINAL,
      page: () => const TerminalView(),
      binding: TerminalBinding(),
    ),
  ];
}
