import 'package:flutter/widgets.dart';

/// Сетка отступов Dreem World.
class AppSpacing {
  const AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  static const EdgeInsets page = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
  static const EdgeInsets card = EdgeInsets.all(md);
  static const EdgeInsets gapH = EdgeInsets.symmetric(horizontal: md);
}
