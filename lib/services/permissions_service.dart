import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<bool> requestCore() async {
    bool micGranted = false;
    try {
      final status = await Permission.microphone.request().timeout(
            const Duration(seconds: 5),
            onTimeout: () => PermissionStatus.denied,
          );
      micGranted = status.isGranted;
      if (status.isPermanentlyDenied) {
        print(
          'Microphone permission permanently denied - user must enable it manually in Settings > Apps > Maya AI > Permissions.',
        );
      }
    } catch (e) {
      print('Microphone permission error: $e');
    }
    try {
      await Permission.systemAlertWindow.request().timeout(
            const Duration(seconds: 5),
            onTimeout: () => PermissionStatus.denied,
          );
    } catch (e) {
      print('Overlay permission error: $e');
    }
    try {
      await Permission.notification.request().timeout(
            const Duration(seconds: 5),
            onTimeout: () => PermissionStatus.denied,
          );
    } catch (e) {
      print('Notification permission error: $e');
    }
    return micGranted;
  }
}
