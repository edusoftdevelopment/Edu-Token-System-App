import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> checkPhonePermission() async {
    var status = await Permission.phone.status;

    if (status.isDenied) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }
}
