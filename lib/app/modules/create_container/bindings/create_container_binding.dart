import 'package:get/get.dart';

import '../controllers/create_container_controller.dart';

class CreateContainerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateContainerController>(
      () => CreateContainerController(),
    );
  }
}
