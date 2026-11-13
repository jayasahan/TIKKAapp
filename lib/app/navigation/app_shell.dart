import 'package:flutter/material.dart';
import 'package:tikka/app/navigation/customer_destination.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_app_bar.dart';
import 'package:tikka/core/widgets/tikka_bottom_navigation.dart';
import 'package:tikka/core/widgets/tikka_states.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.destination});

  final CustomerDestination destination;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TikkaAppBar(eyebrow: 'TIKKA', title: destination.label),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.large),
            child: TikkaEmptyState(
              title: destination.placeholderTitle,
              message: destination.placeholderMessage,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.large,
            0,
            AppSpacing.large,
            AppSpacing.small,
          ),
          child: TikkaBottomNavigation(
            selectedDestination: destination,
            onDestinationSelected: (nextDestination) {
              if (nextDestination == destination) {
                return;
              }
              Navigator.of(
                context,
              ).pushReplacementNamed(AppRoutes.forDestination(nextDestination));
            },
          ),
        ),
      ),
    );
  }
}
