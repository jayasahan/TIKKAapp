import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_app_bar.dart';
import 'package:tikka/core/widgets/tikka_page.dart';

class AuthFormPage extends StatelessWidget {
  const AuthFormPage({
    super.key,
    required this.title,
    required this.description,
    required this.child,
  });

  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TikkaAppBar(
        title: title,
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: TikkaPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xLarge),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
