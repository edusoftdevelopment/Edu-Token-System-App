
part of 'common.dart';
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
