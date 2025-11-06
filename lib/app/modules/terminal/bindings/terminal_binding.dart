import 'package:get/get.dart';

class TerminalBinding extends Bindings {
  @override
  void dependencies() {
    // Terminal session controller is already registered globally in AppBindings
    // No need to register individual terminal controllers here anymore
  }
}
