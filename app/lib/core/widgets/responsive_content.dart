import 'package:flutter/material.dart';

/// Ограничивает ширину контента и центрирует его на больших экранах (Web).
///
/// На узких экранах (телефон) контент занимает всю доступную ширину,
/// на широких (планшет, десктоп, Web) — центрируется с ограничением
/// [maxWidth], чтобы строки текста и формы оставались читаемыми.
class ResponsiveContent extends StatelessWidget {
  const ResponsiveContent({
    super.key,
    required this.child,
    this.maxWidth = kResponsiveMaxWidth,
    this.alignment = Alignment.topCenter,
  });

  /// Ширина, после которой включается ограничение контента.
  static const double breakpoint = kResponsiveMaxWidth;

  /// Базовая максимальная ширина контента.
  static const double kResponsiveMaxWidth = 880;

  /// Максимальная ширина контента на широких экранах.
  final double maxWidth;

  /// Выравнивание контента внутри ограниченной области.
  final AlignmentGeometry alignment;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double horizontalInset = screenWidth > maxWidth
        ? (screenWidth - maxWidth) / 2
        : 0;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalInset),
      child: Align(
        alignment: alignment,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: child,
        ),
      ),
    );
  }
}
