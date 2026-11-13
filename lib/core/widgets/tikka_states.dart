import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tikka/app/theme/app_theme.dart';

class TikkaLoadingState extends StatelessWidget {
  const TikkaLoadingState({super.key, this.message = 'Loading…'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: message,
      child: SizedBox(
        height: 120,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SvgPicture.asset(
                'assets/icons/loading_indicator.svg',
                width: 28,
                height: 28,
                excludeFromSemantics: true,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTheme.stateLabel.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TikkaEmptyState extends StatelessWidget {
  const TikkaEmptyState({
    super.key,
    required this.title,
    required this.message,
    this.height = 180,
  });

  final String title;
  final String message;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 330),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppTheme.stateLabel.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w400,
                  fontVariations: const <FontVariation>[
                    FontVariation('wght', 400),
                    FontVariation('opsz', 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TikkaErrorState extends StatelessWidget {
  const TikkaErrorState({
    super.key,
    this.title = 'Something went wrong',
    required this.message,
    this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 330),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTheme.stateLabel.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w400,
                    fontVariations: const <FontVariation>[
                      FontVariation('wght', 400),
                      FontVariation('opsz', 14),
                    ],
                  ),
                ),
                if (onRetry != null) ...<Widget>[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: onRetry,
                    child: const Text('Try again'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
