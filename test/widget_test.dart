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

  testWidgets('bottom navigation opens the selected placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const ValueKey<String>('nav_services')));
    await tester.pumpAndSettle();

    expect(find.text('Services content is being prepared'), findsOneWidget);
  });

  testWidgets('feature and auth named routes resolve to placeholders', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final navigator = Navigator.of(tester.element(find.text('Home').first));
    final routeCases = <MapEntry<String, String>>[
      MapEntry<String, String>(AppRoutes.login, 'Sign in'),
      MapEntry<String, String>(AppRoutes.register, 'Create account'),
      MapEntry<String, String>(AppRoutes.verifyEmail, 'Verify email'),
      MapEntry<String, String>(AppRoutes.forgotPassword, 'Forgot password'),
      MapEntry<String, String>(AppRoutes.resetPassword, 'Reset password'),
      MapEntry<String, String>(
        AppRoutes.serviceDetails('plumbing'),
        'Service details',
      ),
      MapEntry<String, String>(
        AppRoutes.createBooking('plumbing'),
        'New booking',
      ),
      MapEntry<String, String>(
        AppRoutes.bookingConfirmation,
        'Booking confirmation',
      ),
      MapEntry<String, String>(
        AppRoutes.requestTracking('request-123'),
        'Request tracking',
      ),
      MapEntry<String, String>(AppRoutes.editProfile, 'Edit profile'),
      MapEntry<String, String>(
        AppRoutes.writeReview('request-123'),
        'Review a request',
      ),
    ];

    for (final routeCase in routeCases) {
      unawaited(navigator.pushNamed<void>(routeCase.key));
      await tester.pumpAndSettle();
      expect(find.text(routeCase.value), findsOneWidget, reason: routeCase.key);
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
                hintText: 'Enter your email',
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
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: TikkaLoadingState()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Loading…'), findsOneWidget);
  });
}
