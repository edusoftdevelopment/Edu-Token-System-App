import 'package:edu_token_system_app/core/utils/utils.dart';
import 'package:flutter/material.dart';

class DialogHelper {
  /// Show Error Dialog (Reusable)
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
     void Function()? onPressed,
    bool forBluetooth = false,
  }) async {
    if (!context.mounted) return;

    return showDialog(
      context: context,
      barrierDismissible: false, // User must tap button
      builder: (BuildContext ctx) => AlertDialog(
        backgroundColor: const Color(0xFF203a43),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.kWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.kWhite),
        ),
        actions: [
          if (forBluetooth)
            TextButton.icon(
              icon: const Icon(
                Icons.settings,
                color: AppColors.kWhite,
                size: 18,
              ),
              label: const Text(
                'Settings',
                style: TextStyle(color: AppColors.kWhite),
              ),
              onPressed: onPressed ?? () {},
            ),
          TextButton(
            child: Text(
              forBluetooth ? 'Ok' : 'Cancel',
              style: const TextStyle(color: AppColors.kWhite),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }
}
