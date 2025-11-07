import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutController extends GetxController {
  final RxString appName = ''.obs;
  final RxString version = ''.obs;
  final RxString buildNumber = ''.obs;
  final RxString packageName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appName.value = packageInfo.appName;
      version.value = packageInfo.version;
      buildNumber.value = packageInfo.buildNumber;
      packageName.value = packageInfo.packageName;
    } catch (e) {
      // Fallback values if package_info_plus fails
      appName.value = 'acontainer';
      version.value = '1.0.0';
      buildNumber.value = '1';
      packageName.value = 'com.example.acontainer';
    }
  }
}
