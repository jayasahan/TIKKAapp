import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';

class TikkaPage extends StatelessWidget {
  const TikkaPage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.large),
    this.maxWidth = 560,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
