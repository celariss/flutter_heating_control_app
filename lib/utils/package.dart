import 'package:package_info_plus/package_info_plus.dart';

class Package {
  static final Package _instance = Package._internal();
  Package._internal();
  factory Package() {
    return _instance;
  }

  PackageInfo? packageInfo;

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  PackageInfo? getPackageInfo() {
    return packageInfo;
  }
}