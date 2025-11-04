import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final logger = Logger('home');
  final dbox = Get.find<DboxController>();
  Rx<bool> envOk = false.obs;
  Rx<bool> loading = false.obs;
  RxList<ContainerInfo> containers = <ContainerInfo>[].obs;

  Future<bool> checkEnv() async {
    final result = await dbox.envCheck();
    envOk.value = result;
    return result;
  }

  Future<void> loadContainers() async {
    try {
      final containerList = await dbox.list();
      containers.value = containerList;
    } catch (e) {
      logger.e('Failed to load containers: $e');
    }
  }

  Future<void> refreshPage() async {
    loading.value = true;
    await Future.wait([checkEnv(), loadContainers()]);
    loading.value = false;
  }

  @override
  void onInit() async {
    loading.value = true;
    super.onInit();
    await refreshPage();
  }
}
