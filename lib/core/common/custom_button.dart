import 'package:edu_token_system_app/Export/export.dart';
import 'package:edu_token_system_app/core/utils/utils.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    required this.onPressed,
    this.name,
    super.key,
    this.height,
    this.width,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.allPadding,
    this.padding,
    this.borderRadius,
    this.fontWeight,
    this.style,
    this.widget,
    this.borderColor,
  });

  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback onPressed;
  final String? name;
  final double? fontSize;
  final double? allPadding;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final FontWeight? fontWeight;
  final ButtonStyle? style;
  final Widget? widget;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style:
            style ??
            ElevatedButton.styleFrom(
              padding: EdgeInsets.zero, // 🔹 important for gradient
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: borderColor ?? AppColors.kCustomBorderColor,
                ),
                borderRadius: BorderRadius.circular(borderRadius ?? 16),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent, // 🔹 remove solid color
            ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0f2027), // Dark Navy
                Color(0xFF203a43), // Deep Blue
                Color(0xFF2c5364), // Blue-Gray
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(borderRadius ?? 16),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: padding ?? EdgeInsets.all(allPadding ?? 16),
            child:
                widget ??
                AutoSizeText(
                  name ?? 'Empty Button',
                  style: TextStyle(
                    color:
                        textColor ??
                        (darkMode
                            ? AppColors.kWhite
                            : Theme.of(context).cardColor),
                    fontWeight: fontWeight ?? FontWeight.w600,
                    fontSize: fontSize ?? 16,
                  ),
                ),
          ),
        ),
      ),
    );
  }
}
