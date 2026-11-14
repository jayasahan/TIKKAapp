import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_session_snapshot.dart';
import 'package:tikka/features/auth/presentation/forgot_password_screen.dart';
import 'package:tikka/features/auth/presentation/login_screen.dart';
import 'package:tikka/features/auth/presentation/register_screen.dart';
import 'package:tikka/features/auth/presentation/verify_email_screen.dart';

void main() {
  testWidgets('login validates required fields before calling the repository', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LoginScreen(repository: repository),
      ),
    );

    await tester.tap(find.widgetWithText(TikkaButton, 'Login'));
    await tester.pump();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);
    expect(repository.lastSignInEmail, isNull);
  });

  testWidgets('login displays a repository authentication failure', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository()
      ..signInFailure = const AuthFailure(
        'The email or password is incorrect.',
      );
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: LoginScreen(repository: repository),
      ),
    );
    await tester.enterText(find.byType(TextField).at(0), 'user@example.com');
    await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
    await tester.tap(find.widgetWithText(TikkaButton, 'Login'));
    await tester.pumpAndSettle();

    expect(find.text('The email or password is incorrect.'), findsOneWidget);
    expect(repository.lastSignInEmail, 'user@example.com');
  });

  testWidgets('registration submits the agreed fields and opens verification', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: RegisterScreen(repository: repository),
        routes: <String, WidgetBuilder>{
          AppRoutes.verifyEmail: (context) {
            final email = ModalRoute.of(context)?.settings.arguments as String?;
            return VerifyEmailScreen(email: email, repository: repository);
          },
        },
      ),
    );
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Tikka Customer');
    await tester.enterText(fields.at(1), 'customer@example.com');
    await tester.enterText(fields.at(2), '+94771234567');
    await tester.enterText(fields.at(3), 'safe-password');
    await tester.enterText(fields.at(4), 'safe-password');
    final submitButton = find.widgetWithText(TikkaButton, 'Create account');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    expect(repository.lastSignUp, <String, String>{
      'fullName': 'Tikka Customer',
      'email': 'customer@example.com',
      'phoneNumber': '+94771234567',
      'password': 'safe-password',
    });
    expect(
      find.textContaining(
        'A confirmation link was sent to customer@example.com',
      ),
      findsOneWidget,
    );
  });

  testWidgets('recovery request presents a non-enumerating confirmation', (
    WidgetTester tester,
  ) async {
    final repository = _FakeAuthRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ForgotPasswordScreen(repository: repository),
      ),
    );
    await tester.enterText(
      find.byType(TextField).first,
      'customer@example.com',
    );
    await tester.tap(find.widgetWithText(TikkaButton, 'Send reset link'));
    await tester.pumpAndSettle();

    expect(repository.lastRecoveryEmail, 'customer@example.com');
    expect(
      find.text(
        'If an account exists for this email, password reset instructions will arrive shortly.',
      ),
      findsOneWidget,
    );
  });
}

class _FakeAuthRepository implements AuthRepository {
  final StreamController<AuthSessionSnapshot?> _authEvents =
      StreamController<AuthSessionSnapshot?>.broadcast(sync: true);

  AuthSessionSnapshot? _currentSnapshot;
  AuthFailure? signInFailure;
  String? lastSignInEmail;
  String? lastRecoveryEmail;
  Map<String, String>? lastSignUp;

  @override
  AuthSessionSnapshot? get currentSnapshot => _currentSnapshot;

  @override
  Stream<AuthSessionSnapshot?> get authStateChanges => _authEvents.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    lastSignInEmail = email;
    if (signInFailure != null) {
      throw signInFailure!;
    }
    _currentSnapshot = const AuthSessionSnapshot(
      userId: 'customer-1',
      email: 'customer@example.com',
      isEmailVerified: true,
    );
    _authEvents.add(_currentSnapshot);
  }

  @override
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async {
    lastSignUp = <String, String>{
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'password': password,
    };
    return true;
  }

  @override
  Future<void> resendSignupVerification(String email) async {}

  @override
  Future<void> requestPasswordRecovery(String email) async {
    lastRecoveryEmail = email;
  }

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> signOut() async {
    _currentSnapshot = null;
    _authEvents.add(null);
  }

  Future<void> dispose() => _authEvents.close();
}
