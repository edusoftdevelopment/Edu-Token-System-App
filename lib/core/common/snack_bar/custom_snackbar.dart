part of '../common.dart';

class CustomSnackbar {
  ///! Show the gradient snackbar
  static void show(
    BuildContext context,
    String message, {
    List<Color>? gradiantColorsList,
    IconData icon = Icons.bluetooth,
    Duration duration = const Duration(seconds: 2),
    EdgeInsets margin = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    List<Color> gradientColors = const [Color(0xFF6A11CB), Color(0xFF2575FC)],
    double borderRadius = 12.0,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        backgroundColor: Colors.transparent,
        duration: duration,
        margin: margin,
        content: _SnackBarContent(
          message: message,
          icon: icon,
          gradientColors: gradiantColorsList ?? gradientColors,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

/// Internal widget that renders the actual gradient content.
class _SnackBarContent extends StatelessWidget {
  const _SnackBarContent({
    required this.message,
    required this.icon,
    required this.gradientColors,
    required this.borderRadius,
  });
  final String message;
  final IconData icon;
  final List<Color> gradientColors;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
