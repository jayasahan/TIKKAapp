import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_session_snapshot.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(SupabaseClient client, {required this.authRedirectUrl})
    : _client = client,
      _snapshot = _fromSession(client.auth.currentSession) {
    _authSubscription = _client.auth.onAuthStateChange.listen(
      (state) {
        final continuingPasswordRecovery =
            _snapshot?.isPasswordRecovery == true &&
            state.session != null &&
            state.event != AuthChangeEvent.userUpdated &&
            state.event != AuthChangeEvent.signedOut;
        _snapshot = _fromSession(
          state.session,
          isPasswordRecovery:
              state.event == AuthChangeEvent.passwordRecovery ||
              continuingPasswordRecovery,
        );
        _authEvents.add(_snapshot);
      },
      onError: (Object _, StackTrace _) {
        // Token refresh errors must not become uncaught stream exceptions.
        // Auth actions surface their own failures to the presentation layer.
      },
    );
  }

  final SupabaseClient _client;
  final String authRedirectUrl;
  final StreamController<AuthSessionSnapshot?> _authEvents =
      StreamController<AuthSessionSnapshot?>.broadcast(sync: true);
  late final StreamSubscription<AuthState> _authSubscription;
  AuthSessionSnapshot? _snapshot;

  @override
  AuthSessionSnapshot? get currentSnapshot => _snapshot;

  @override
  Stream<AuthSessionSnapshot?> get authStateChanges => _authEvents.stream;

  @override
  Future<void> signIn({required String email, required String password}) {
    return _withUserMessage(() async {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      final user = response.user;

      if (response.session == null || user == null) {
        throw const AuthFailure(
          'Please confirm your email address before signing in.',
        );
      }

      if (user.emailConfirmedAt == null) {
        await _signOutUnverifiedSession();
        throw const AuthFailure(
          'Please confirm your email address before signing in.',
        );
      }
    });
  }

  @override
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) {
    return _withUserMessage(() async {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: <String, Object>{
          'full_name': fullName.trim(),
          'phone_number': phoneNumber.trim(),
        },
        emailRedirectTo: authRedirectUrl,
      );
      final user = response.user;

      if (user == null) {
        throw const AuthFailure(
          'We could not create your account. Please try again.',
        );
      }

      final needsEmailVerification =
          response.session == null || user.emailConfirmedAt == null;
      if (needsEmailVerification && response.session != null) {
        await _signOutUnverifiedSession();
      }
      return needsEmailVerification;
    });
  }

  @override
  Future<void> resendSignupVerification(String email) {
    return _withUserMessage(() async {
      await _client.auth.resend(
        type: OtpType.signup,
        email: email.trim(),
        emailRedirectTo: authRedirectUrl,
      );
    });
  }

  @override
  Future<void> requestPasswordRecovery(String email) {
    return _withUserMessage(() async {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: authRedirectUrl,
      );
    });
  }

  @override
  Future<void> updatePassword(String password) {
    return _withUserMessage(() async {
      await _client.auth.updateUser(UserAttributes(password: password));
    });
  }

  @override
  Future<void> signOut() {
    return _withUserMessage(() async {
      await _client.auth.signOut();
    });
  }

  Future<void> dispose() async {
    await _authSubscription.cancel();
    await _authEvents.close();
  }

  Future<void> _signOutUnverifiedSession() async {
    try {
      await _client.auth.signOut();
    } on AuthException {
      // An unverified session is still blocked by the application route guard.
    }
  }

  Future<T> _withUserMessage<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthFailure {
      rethrow;
    } on AuthException catch (error) {
      throw AuthFailure(_friendlyMessage(error));
    } on Object {
      throw const AuthFailure(
        'We could not reach the authentication service. Please try again.',
      );
    }
  }

  String _friendlyMessage(AuthException error) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'The email or password is incorrect.';
    }
    if (message.contains('email not confirmed')) {
      return 'Please confirm your email address before signing in.';
    }
    if (message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('weak password') ||
        message.contains('password should')) {
      return 'Choose a stronger password and try again.';
    }
    if (message.contains('rate limit')) {
      return 'Too many attempts. Wait a little and try again.';
    }
    return 'We could not complete the authentication request. Please try again.';
  }

  static AuthSessionSnapshot? _fromSession(
    Session? session, {
    bool isPasswordRecovery = false,
  }) {
    final user = session?.user;
    if (user == null) {
      return null;
    }
    return AuthSessionSnapshot(
      userId: user.id,
      email: user.email,
      isEmailVerified: user.emailConfirmedAt != null,
      isPasswordRecovery: isPasswordRecovery,
    );
  }
}
