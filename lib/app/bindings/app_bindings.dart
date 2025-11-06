import 'package:get/get.dart';
import '../controllers/dbox_controller.dart';
import '../controllers/terminal_session_controller.dart';
import '../theme/terminal_theme_controller.dart';
import '../controllers/app_theme_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DboxController>(() => DboxController(), fenix: true);
    
    // Register terminal session controller as permanent singleton
    Get.put<TerminalSessionController>(TerminalSessionController(), permanent: true);
    
    // Register terminal theme controller as singleton
    Get.put<TerminalThemeController>(TerminalThemeController.instance, permanent: true);
    
    // Register app theme controller as singleton
    Get.put<AppThemeController>(AppThemeController(), permanent: true);
  }
}
