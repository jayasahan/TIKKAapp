import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.brandYellow,
      body: Semantics(
        button: true,
        label: 'Continue to sign in',
        child: InkWell(
          onTap: () {
            Navigator.of(context).pushReplacementNamed(AppRoutes.login);
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: <Widget>[
                  const Spacer(flex: 7),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'TIKKA',
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(fontSize: 44, height: 1),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'tikka.lk',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: const Color(0xFF33332E),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Get it done.',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const Spacer(flex: 2),
                  Text(
                    'Trusted home services, simply requested.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                  const Spacer(flex: 5),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
