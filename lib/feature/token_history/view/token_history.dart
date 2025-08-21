import 'dart:io';

import 'package:edu_token_system_app/core/common/snack_bar/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class TokenHistoryPage extends StatefulWidget {
  const TokenHistoryPage({super.key});

  @override
  State<TokenHistoryPage> createState() => _TokenHistoryPageState();
}

class _TokenHistoryPageState extends State<TokenHistoryPage> {
  /// Improved permission requester + debug prints.
  /// Returns true if at least one core Bluetooth permission is actually granted,
  /// or (when bluetooth enums are not available) locationWhenInUse is granted.
  Future<bool> requestBluetoothPermissions() async {
    if (!Platform.isAndroid && !Platform.isIOS) return true;

    final permissions = <Permission>[];

    if (Platform.isAndroid) {
      permissions.addAll([
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ]);
    } else {
      permissions.addAll([
        Permission.bluetooth,
        Permission.locationWhenInUse,
      ]);
    }

    // Request each permission (ignore thrown errors for unsupported enums)
    for (final p in permissions) {
      try {
        await p.request();
      } catch (e) {
        debugPrint('request for $p threw: $e');
      }
    }

    // Collect statuses and print for debugging
    final statuses = <Permission, PermissionStatus>{};
    for (final p in permissions) {
      try {
        final s = await p.status;
        statuses[p] = s;
      } catch (e) {
        debugPrint('status check for $p threw: $e');
      }
    }

    // Debug output: print all statuses so you can see what the plugin returns.
    debugPrint('--- Bluetooth permission statuses ---');
    statuses.forEach((perm, stat) {
      debugPrint('$perm -> $stat');
    });

    // Decide success:
    // If any bluetooth-related permission exists in statuses and is granted/limited -> success
    final bluetoothKeys = <Permission>[
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.bluetoothAdvertise,
    ];

    final grantedBluetooth = bluetoothKeys.any((k) {
      final s = statuses[k];
      return s != null && (s.isGranted || s.isLimited);
    });

    if (grantedBluetooth) {
      return true;
    }

    // If no bluetooth enums were available (statuses doesn't contain any of them),
    // fallback to location permission (useful for older Android devices where location was needed for BLE scan)
    final anyBluetoothEnumAvailable = bluetoothKeys.any(
      statuses.containsKey,
    );

    if (!anyBluetoothEnumAvailable) {
      final loc = statuses[Permission.locationWhenInUse];
      if (loc != null && (loc.isGranted || loc.isLimited)) {
        return true;
      }
    }

    // Otherwise permission not sufficient
    return false;
  }

  Future<bool> _anyPermissionPermanentlyDenied() async {
    final checkPerms = <Permission>[];
    if (Platform.isAndroid) {
      checkPerms.addAll([
        Permission.bluetooth,
        Permission.bluetoothScan,
        Permission.bluetoothConnect,
        Permission.bluetoothAdvertise,
        Permission.locationWhenInUse,
      ]);
    } else if (Platform.isIOS) {
      checkPerms.addAll([Permission.bluetooth, Permission.locationWhenInUse]);
    }

    for (final p in checkPerms) {
      try {
        final status = await p.status;
        if (status.isPermanentlyDenied) return true;
      } catch (_) {
        // ignore unsupported enums
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    // Request permissions as soon as the screen is shown (after first frame)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _askPermissionsOnEnter();
    });
  }

  Future<void> _askPermissionsOnEnter() async {
    final granted = await requestBluetoothPermissions();

    if (!granted && mounted) {
      final permanentlyDenied = await _anyPermissionPermanentlyDenied();
      if (permanentlyDenied) {
        _showOpenSettingsDialog();
      } else {
        CustomSnackbar.show(
          context,
          'Please provide the bluetooth permission',
          gradientColors: const [Color(0xFFDC143C), Color(0xFF8B0000)],
        );
      }
    }
  }

  void _showOpenSettingsDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission required'),
        content: const Text(
          'Bluetooth permission permanently denied. Please open app settings and allow Bluetooth permission to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bluetooth Printer Example')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(),
      ),
    );
  }
}
