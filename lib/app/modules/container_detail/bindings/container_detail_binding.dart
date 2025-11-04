import 'package:get/get.dart';

import '../controllers/container_detail_controller.dart';

class ContainerDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ContainerDetailController>(
      ContainerDetailController(),
    );
  }
}
