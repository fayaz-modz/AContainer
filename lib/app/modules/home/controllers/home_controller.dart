import 'package:acontainer/app/controllers/dbox_controller.dart';
import 'package:acontainer/app/models/container.dart';
import 'package:acontainer/app/utils/logger.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final logger = Logger('home');
  final dbox = Get.find<DboxController>();
  Rx<bool> envOk = false.obs;
  Rx<bool> loading = false.obs;
  RxInt currentBottomNavIndex = 0.obs;

  RxList<ContainerInfo> get containers => dbox.containers;

  Future<bool> checkEnv() async {
    try {
      final result = await dbox.envCheck();
      envOk.value = result;
      return result;
    } catch (e) {
      logger.i('Failed to check environment: $e');
    }
    envOk.value = false;
    return false;
  }

  Future<void> loadContainers() async {
    try {
      await dbox.refreshAll();
    } catch (e) {
      logger.e('Failed to load containers and volumes: $e');
    }
  }

  Future<void> refreshPage() async {
    loading.value = true;
    final result = await checkEnv();
    if (result) {
      await loadContainers();
    }
    loading.value = false;
  }

  @override
  void onInit() async {
    loading.value = true;
    super.onInit();
    await refreshPage();
  }
}
