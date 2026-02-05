import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermissions() async {
    await [Permission.locationWhenInUse].request();
  }
}
