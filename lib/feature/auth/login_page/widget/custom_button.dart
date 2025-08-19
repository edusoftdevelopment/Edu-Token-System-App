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
              backgroundColor: backgroundColor ?? AppColors.kCustomButtonsColor,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: borderColor ?? AppColors.kCustomBorderColor,
                ),
                borderRadius: BorderRadius.circular(borderRadius ?? 16),
              ),
              padding: padding ?? EdgeInsets.all(allPadding ?? 16),
              elevation: 0,
            ),
        child:
            widget ??
            AutoSizeText(
              name ?? 'Empty Button',
              style: TextStyle(
                color:
                    textColor ??
                    (darkMode ? AppColors.kWhite : Theme.of(context).cardColor),
                fontWeight: fontWeight ?? FontWeight.w600, // Semibold
                fontSize: fontSize ?? 16,
              ),
            ),
      ),
    );
  }
}

///! Used for secondary actions like "Cancel"
class CustomSecondaryButton extends StatelessWidget {
  const CustomSecondaryButton({
    required this.text,
    super.key,
    this.onPressed,
    this.borderColor,
    this.width,
    // this.height = 48.0,
    this.foreGroundColor,
    this.borderRadius = 8.0,
    this.fontSize,
    this.fontWeight = FontWeight.w700,
    this.textColor = AppColors.kMidnightBlue,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  });
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  // final double height;
  final Color? foreGroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final Color? textColor;
  final double? fontSize;
  final FontWeight fontWeight;
  final Color? borderColor;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      // height: height,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: foreGroundColor ?? AppColors.kMidnightBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(color: borderColor ?? AppColors.kMidnightBlue),
          ),
          padding: padding,
        ),
        child: AutoSizeText(
          text,
          presetFontSizes: [14.sp, 16.sp, 18.sp, 20.sp],
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontFamily: 'Roboto',
            fontSize: fontSize ?? 16.sp,
            color: textColor ?? AppColors.kMidnightBlue,
            fontWeight: fontWeight,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

///! Used for toggle actions like "Precise: On"
class CustomToggleButton extends StatelessWidget {
  const CustomToggleButton({
    required this.label,
    required this.value,
    super.key,
    this.isSelected = false,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.selectedBackgroundColor,
    this.selectedTextColor,
    this.icon,
    this.borderRadius = 80.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? selectedBackgroundColor;
  final Color? selectedTextColor;
  final IconData? icon;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    // final bgColor = isSelected
    //     ? (selectedBackgroundColor ?? AppColors.kWhite)
    //     : (backgroundColor ?? AppColors.kGrey200);

    final txtColor = isSelected
        ? (selectedTextColor ?? const Color.fromARGB(255, 0, 122, 255))
        : (textColor ?? Colors.grey.shade600);

    return GestureDetector(
      onTap: onPressed,
      child: Card(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
        ),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            //   color: bgColor,
            borderRadius: BorderRadius.circular(borderRadius),
            //   border: isSelected
            //       ? Border.all(color: const Color(0xFF1976D2))
            //       : null,
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp, color: txtColor),
                SizedBox(width: 6.w),
              ],
              AutoSizeText(
                '$label: $value',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: txtColor,

                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
