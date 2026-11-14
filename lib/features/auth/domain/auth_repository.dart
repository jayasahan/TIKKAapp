import 'auth_session_snapshot.dart';

abstract interface class AuthRepository {
  AuthSessionSnapshot? get currentSnapshot;

  Stream<AuthSessionSnapshot?> get authStateChanges;

  Future<void> signIn({required String email, required String password});

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  });

  Future<void> resendSignupVerification(String email);

  Future<void> requestPasswordRecovery(String email);

  Future<void> updatePassword(String password);

  Future<void> signOut();
}
