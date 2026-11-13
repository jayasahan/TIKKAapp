import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';

class TikkaAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TikkaAppBar({
    super.key,
    required this.title,
    this.eyebrow,
    this.onBackPressed,
    this.action,
    this.actionTooltip,
    this.onActionPressed,
  });

  final String title;
  final String? eyebrow;
  final VoidCallback? onBackPressed;
  final Widget? action;
  final String? actionTooltip;
  final VoidCallback? onActionPressed;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppBar(
      automaticallyImplyLeading: false,
      toolbarHeight: 60,
      titleSpacing: onBackPressed == null ? 16 : 0,
      leading: onBackPressed == null
          ? null
          : IconButton(
              onPressed: onBackPressed,
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
            ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (eyebrow != null)
            Text(
              eyebrow!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          Text(title, style: textTheme.headlineSmall),
        ],
      ),
      actions: action == null
          ? null
          : <Widget>[
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  onPressed: onActionPressed,
                  tooltip: actionTooltip,
                  style: IconButton.styleFrom(
                    fixedSize: const Size(44, 44),
                    backgroundColor: AppColors.surface,
                    foregroundColor: AppColors.textPrimary,
                    side: const BorderSide(color: AppColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.button),
                    ),
                  ),
                  icon: action!,
                ),
              ),
            ],
    );
  }
}
