import 'package:get/get.dart';
import '../controllers/dbox_controller.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DboxController>(() => DboxController(), fenix: true);
  }
}
