import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/app/app.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/core/widgets/tikka_text_field.dart';

void main() {
  testWidgets('launches the TIKKA shell with four destinations', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('TIKKA'), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('nav_home')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('nav_services')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('nav_requests')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('nav_profile')), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
  });

  testWidgets('bottom navigation opens the selected destination', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const ValueKey<String>('nav_services')));
    await tester.pumpAndSettle();

    expect(find.text('Choose what you need'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey<String>('nav_requests')));
    await tester.pumpAndSettle();

    expect(find.text('No requests yet'), findsOneWidget);
  });

  testWidgets('feature and auth named routes resolve properly', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final navigator = Navigator.of(tester.element(find.text('Home').first));
    final routeCases = <MapEntry<String, String>>[
      const MapEntry<String, String>(AppRoutes.login, 'Sign in'),
      const MapEntry<String, String>(AppRoutes.register, 'Create account'),
      const MapEntry<String, String>(AppRoutes.verifyEmail, 'Verify email'),
      const MapEntry<String, String>(
        AppRoutes.forgotPassword,
        'Forgot password',
      ),
      const MapEntry<String, String>(AppRoutes.resetPassword, 'Reset password'),
      MapEntry<String, String>(
        AppRoutes.serviceDetails('plumbing-general'),
        'Plumbing',
      ),
      MapEntry<String, String>(
        AppRoutes.createBooking('plumbing-general'),
        'Request Plumbing',
      ),
      const MapEntry<String, String>(
        AppRoutes.bookingConfirmation,
        'Review request',
      ),
      MapEntry<String, String>(
        AppRoutes.requestTracking('request-123'),
        'Request tracking',
      ),
      const MapEntry<String, String>(AppRoutes.editProfile, 'Edit profile'),
      MapEntry<String, String>(
        AppRoutes.writeReview('request-123'),
        'Submit review',
      ),
    ];

    for (final routeCase in routeCases) {
      unawaited(navigator.pushNamed<void>(routeCase.key));
      await tester.pumpAndSettle();
      if (routeCase.key.startsWith('/services/')) {
        expect(find.text(routeCase.value), findsWidgets, reason: routeCase.key);
      } else {
        expect(
          find.text(routeCase.value),
          findsOneWidget,
          reason: routeCase.key,
        );
      }
      unawaited(navigator.maybePop());
      await tester.pumpAndSettle();
    }
  });

  testWidgets('shared text field presents its error state', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: 330,
              child: TikkaTextField(
                label: 'Email',
                hintText: 'Enter email',
                errorText: 'invalid email',
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('invalid email'), findsOneWidget);
  });

  testWidgets('loading state uses the bundled Figma indicator', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TikkaLoadingState())),
    );

    expect(find.text('Loading…'), findsOneWidget);
  });
}
