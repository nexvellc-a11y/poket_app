import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<void> requestPermissions() async {
    // 🚫 Web does not support permission_handler location
    if (kIsWeb) return;

    final status = await Permission.locationWhenInUse.status;

    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }
  }
}
