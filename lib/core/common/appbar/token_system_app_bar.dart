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
      flexibleSpace: const SizedBox.expand().withGradientBlur(),
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
