import 'package:get/get.dart';
import '../controllers/terminal_controller.dart';

class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    // Terminal session controller is already registered globally in AppBindings
    // Register terminal controller lazily for each terminal instance
    Get.lazyPut<TerminalController>(() => TerminalController());
  }
}
