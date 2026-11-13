import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';

enum TikkaButtonStyle { primary, secondary, text }

class TikkaButton extends StatelessWidget {
  const TikkaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.style = TikkaButtonStyle.primary,
    this.fullWidth = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final TikkaButtonStyle style;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final button = switch (style) {
      TikkaButtonStyle.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.textPrimary,
          disabledBackgroundColor: AppColors.disabledButton,
          disabledForegroundColor: AppColors.textSecondary,
          minimumSize: Size(fullWidth ? 0 : 180, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          elevation: 0,
          textStyle: AppTheme.buttonLabel,
        ),
        child: Text(label),
      ),
      TikkaButtonStyle.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textSecondary,
          minimumSize: Size(fullWidth ? 0 : 180, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          textStyle: AppTheme.buttonLabel,
        ),
        child: Text(label),
      ),
      TikkaButtonStyle.text => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textSecondary,
          minimumSize: Size(fullWidth ? 0 : 110, 52),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
          textStyle: AppTheme.buttonLabel,
        ),
        child: Text(label),
      ),
    };

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: 52,
      child: button,
    );
  }
}
