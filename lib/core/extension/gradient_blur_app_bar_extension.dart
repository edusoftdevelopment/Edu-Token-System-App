part of 'extension.dart';

extension GradientBlurExtension on Widget {
  Widget withGradientBlur({
    double sigmaX = 8,
    double sigmaY = 8,
    BorderRadius? borderRadius,
    List<Color>? colors,
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors:
                  colors ??
                  const [
                    Color(0xFF0f2027), // Dark Navy
                    Color(0xFF203a43), // Deep Blue
                    Color(0xFF2c5364), // Blue-Gray
                  ],
              begin: begin,
              end: end,
            ),
          ),
          child: this,
        ),
      ),
    );
  }
}
