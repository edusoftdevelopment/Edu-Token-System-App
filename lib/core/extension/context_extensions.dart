part of 'extension.dart';

extension ContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get size => mediaQuery.size;
  double get width => size.width;
  double get height => size.height;
  double get adjustHWScreenSize => (height + width) / 2;
  double get shortestSide => size.shortestSide;
  double get pixelRatio => mediaQuery.devicePixelRatio;
}
