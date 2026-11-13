import 'package:flutter/material.dart';
import 'package:tikka/core/widgets/tikka_app_bar.dart';
import 'package:tikka/core/widgets/tikka_page.dart';
import 'package:tikka/core/widgets/tikka_states.dart';

class FeaturePlaceholderScreen extends StatelessWidget {
  const FeaturePlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
    this.showAppBar = true,
  });

  final String title;
  final String message;
  final bool showAppBar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? TikkaAppBar(
              title: title,
              onBackPressed: () => Navigator.of(context).maybePop(),
            )
          : null,
      body: SafeArea(
        child: TikkaPage(
          child: Center(
            child: TikkaEmptyState(
              title: showAppBar ? 'Coming soon' : title,
              message: message,
            ),
          ),
        ),
      ),
    );
  }
}
