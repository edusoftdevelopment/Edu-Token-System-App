// ignore_for_file: must_be_immutable

part of '../common.dart';

class CustomAppBarEduTokenSystem extends StatelessWidget
    implements PreferredSizeWidget {
  CustomAppBarEduTokenSystem({
    required this.title,
    required this.size,
    this.titleWidget,
    this.titleStyle,
    this.centerTitle = true,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.scrolledUnderElevation,
    this.automaticallyImplyLeading = true,
    this.leading,
    this.bottom,
    this.shape,
    this.systemOverlayStyle,
    this.shadowColor,
    super.key,
  });

  final String title;
  final TextStyle? titleStyle;
  final bool centerTitle;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  final double? scrolledUnderElevation;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final ShapeBorder? shape;
  final SystemUiOverlayStyle? systemOverlayStyle;
  final Color? shadowColor;
  final Widget? titleWidget;

  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;

    return AppBar(
      title:
          titleWidget ??
          AutoSizeText(
            title,
            style: titleStyle ?? appBarTheme.titleTextStyle,
            minFontSize: 14,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      titleTextStyle:
          appBarTheme.titleTextStyle ??
          const TextStyle(overflow: TextOverflow.ellipsis),
      centerTitle: centerTitle,
      actions: actions,
      // backgroundColor ko null rakhenge takay gradient kaam kare
      backgroundColor: Colors.transparent,
      elevation: elevation ?? appBarTheme.elevation ?? 0.0,
      scrolledUnderElevation:
          scrolledUnderElevation ?? appBarTheme.scrolledUnderElevation ?? 0.0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      bottom: bottom,
      shape: shape,
      systemOverlayStyle: systemOverlayStyle ?? appBarTheme.systemOverlayStyle,
      shadowColor: shadowColor ?? appBarTheme.shadowColor,
      foregroundColor: AppColors.kWhite,

      // 🔹 Gradient yahan flexibleSpace me apply hoga
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8), // 🔹 Blur intensity
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF0f2027), // Dark Navy
                  Color(0xFF203a43), // Deep Blue
                  Color(0xFF2c5364), // Blue-Gray
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0.0;
    return Size.fromHeight(size.height * 0.075 + bottomHeight);
  }
}

// part of '../common.dart';

// class CustomAppBarEduTokenSystem extends StatelessWidget
//     implements PreferredSizeWidget {
//   CustomAppBarEduTokenSystem({
//     required this.title,
//     required this.size,
//     this.titleWidget,
//     this.titleStyle,
//     this.centerTitle = true,
//     this.actions,
//     this.backgroundColor,
//     this.elevation,
//     this.scrolledUnderElevation,
//     this.automaticallyImplyLeading = true,
//     this.leading,
//     this.bottom,
//     this.shape,
//     this.systemOverlayStyle,
//     this.shadowColor,

//     super.key,
//   });
//   final String title;

//   final TextStyle? titleStyle;

//   final bool centerTitle;

//   final List<Widget>? actions;

//   final Color? backgroundColor;

//   final double? elevation;

//   final double? scrolledUnderElevation;

//   final bool automaticallyImplyLeading;

//   final Widget? leading;

//   final PreferredSizeWidget? bottom;

//   final ShapeBorder? shape;

//   final SystemUiOverlayStyle? systemOverlayStyle;

//   final Color? shadowColor;

//   final Widget? titleWidget;
//   Size size;
//   @override
//   Widget build(BuildContext context) {
//     size = MediaQuery.of(context).size;
//     final theme = Theme.of(context);
//     final appBarTheme = theme.appBarTheme;

//     return AppBar(
//       title:
//           titleWidget ??
//           AutoSizeText(
//             title,
//             style: titleStyle ?? appBarTheme.titleTextStyle,
//             minFontSize: 14,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//           ),
//       titleTextStyle:
//           appBarTheme.titleTextStyle ??
//           const TextStyle(overflow: TextOverflow.ellipsis),
//       centerTitle: centerTitle,
//       actions: actions,
//       backgroundColor: backgroundColor ?? appBarTheme.backgroundColor,
//       elevation: elevation ?? appBarTheme.elevation ?? 0.0,
//       scrolledUnderElevation:
//           scrolledUnderElevation ?? appBarTheme.scrolledUnderElevation ?? 0.0,
//       automaticallyImplyLeading: automaticallyImplyLeading,
//       leading: leading,
//       bottom: bottom,
//       shape: shape,
//       systemOverlayStyle: systemOverlayStyle ?? appBarTheme.systemOverlayStyle,
//       shadowColor: shadowColor ?? appBarTheme.shadowColor,
//       foregroundColor: AppColors.kWhite,
//     );
//   }

//   @override
//   Size get preferredSize {
//     final bottomHeight = bottom?.preferredSize.height ?? 0.0;
//     return Size.fromHeight(size.height * 0.075 + bottomHeight);
//   }
// }
