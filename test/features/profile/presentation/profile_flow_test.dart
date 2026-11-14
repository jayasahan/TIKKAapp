import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_session_snapshot.dart';
import 'package:tikka/features/profile/domain/customer_profile.dart';
import 'package:tikka/features/profile/domain/profile_repository.dart';
import 'package:tikka/features/profile/presentation/profile_screen.dart';

void main() {
  testWidgets('profile screen displays customer details and edit action', (
    WidgetTester tester,
  ) async {
    final profileRepository = _FakeProfileRepository();
    await tester.pumpWidget(
      MaterialApp(
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Text('Edit profile destination')),
        ),
        home: Scaffold(
          body: ProfileScreen(
            repository: profileRepository,
            authRepository: _FakeAuthRepository(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tikka Customer'), findsOneWidget);
    expect(find.text('customer@example.com'), findsOneWidget);
    expect(find.text('+94771234567'), findsOneWidget);
    expect(find.text('12 Main Street'), findsOneWidget);
    expect(find.text('Edit Profile'), findsOneWidget);

    await tester.tap(find.text('Edit Profile'));
    await tester.pumpAndSettle();
    expect(find.text('Edit profile destination'), findsOneWidget);
  });
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<CustomerProfile> getCurrentProfile() async => const CustomerProfile(
    id: 'customer-1',
    fullName: 'Tikka Customer',
    phoneNumber: '+94771234567',
    savedAddress: '12 Main Street',
  );

  @override
  Future<CustomerProfile> updateCurrentProfile({
    required String fullName,
    String? phoneNumber,
    String? savedAddress,
  }) async => CustomerProfile(
    id: 'customer-1',
    fullName: fullName,
    phoneNumber: phoneNumber,
    savedAddress: savedAddress,
  );
}

class _FakeAuthRepository implements AuthRepository {
  @override
  AuthSessionSnapshot? get currentSnapshot => const AuthSessionSnapshot(
    userId: 'customer-1',
    email: 'customer@example.com',
    isEmailVerified: true,
  );

  @override
  Stream<AuthSessionSnapshot?> get authStateChanges =>
      const Stream<AuthSessionSnapshot?>.empty();

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async => false;

  @override
  Future<void> resendSignupVerification(String email) async {}

  @override
  Future<void> requestPasswordRecovery(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> signOut() async {}
}
