import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> checkForUpdate(BuildContext context) async {
  try {
    // Get current app version
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    // 👉 Hardcode latest version (no API as you requested)
    const latestVersion = "1.0.5"; // 🔴 CHANGE THIS WHEN YOU UPDATE PLAY STORE

    if (_isUpdateAvailable(currentVersion, latestVersion)) {
      _showUpdateDialog(context);
    }
  } catch (e) {
    debugPrint("Update check error: $e");
  }
}

/// Compare versions
bool _isUpdateAvailable(String current, String latest) {
  List<int> currentParts = current.split('.').map(int.parse).toList();
  List<int> latestParts = latest.split('.').map(int.parse).toList();

  for (int i = 0; i < latestParts.length; i++) {
    if (i >= currentParts.length) return true;
    if (latestParts[i] > currentParts[i]) return true;
    if (latestParts[i] < currentParts[i]) return false;
  }
  return false;
}

/// Show dialog
void _showUpdateDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AlertDialog(
        title: const Text("Update Available"),
        content: const Text(
          "A new version of the app is available. Please update for better experience.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later"),
          ),
          TextButton(
            onPressed: () {
              const url =
                  "https://play.google.com/store/apps/details?id=com.poketstor.app";
              launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
            },
            child: const Text("Update"),
          ),
        ],
      );
    },
  );
}
