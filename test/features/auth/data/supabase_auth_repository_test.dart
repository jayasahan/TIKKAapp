import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/auth/data/supabase_auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_failure.dart';

void main() {
  const authRedirectUrl = 'tikka://auth-callback';
  late Future<http.Response> Function(http.BaseRequest request) responseFor;
  late MockClient httpClient;
  late SupabaseClient client;
  late SupabaseAuthRepository repository;

  setUp(() {
    responseFor = (_) async => http.Response('{}', 200);
    httpClient = MockClient((request) => responseFor(request));
    client = SupabaseClient(
      'https://tikka-test.supabase.co',
      'test-anon-key',
      httpClient: httpClient,
      authOptions: const AuthClientOptions(
        autoRefreshToken: false,
        authFlowType: AuthFlowType.implicit,
      ),
    );
    repository = SupabaseAuthRepository(
      client,
      authRedirectUrl: authRedirectUrl,
    );
  });

  tearDown(() async {
    await repository.dispose();
    await client.dispose();
    httpClient.close();
  });

  test(
    'sign up sends profile metadata and requests email verification',
    () async {
      http.BaseRequest? capturedRequest;
      responseFor = (request) async {
        capturedRequest = request;
        return http.Response(
          jsonEncode(_userJson(email: 'customer@example.com')),
          200,
          headers: const <String, String>{'content-type': 'application/json'},
        );
      };

      final needsVerification = await repository.signUp(
        fullName: '  Tikka Customer  ',
        email: ' customer@example.com ',
        phoneNumber: ' +94771234567 ',
        password: 'safe-password',
      );

      expect(needsVerification, isTrue);
      expect(capturedRequest?.url.path, '/auth/v1/signup');
      expect(
        capturedRequest?.url.queryParameters['redirect_to'],
        authRedirectUrl,
      );
      final body = jsonDecode(
        (capturedRequest! as http.Request).body,
      ) as Map<String, dynamic>;
      expect(body['email'], 'customer@example.com');
      expect(body['data'], <String, String>{
        'full_name': 'Tikka Customer',
        'phone_number': '+94771234567',
      });
    },
  );

  test('sign in publishes a verified session snapshot', () async {
    responseFor = (_) async => http.Response(
      jsonEncode(<String, Object?>{
        'access_token': _accessToken(),
        'refresh_token': 'test-refresh-token',
        'token_type': 'bearer',
        'expires_in': 3600,
        'user': _userJson(
          email: 'customer@example.com',
          emailConfirmedAt: '2026-11-13T00:00:00Z',
        ),
      }),
      200,
      headers: const <String, String>{'content-type': 'application/json'},
    );
    final snapshotFuture = repository.authStateChanges.first;

    await repository.signIn(
      email: ' customer@example.com ',
      password: 'safe-password',
    );

    final snapshot = await snapshotFuture.timeout(const Duration(seconds: 2));
    expect(snapshot?.userId, 'customer-1');
    expect(snapshot?.email, 'customer@example.com');
    expect(snapshot?.isAuthenticated, isTrue);
    expect(repository.currentSnapshot, snapshot);
  });

  test(
    'maps an unconfirmed sign-in failure to a user-readable message',
    () async {
      responseFor = (_) async => http.Response(
        jsonEncode(<String, String>{
          'code': 'email_not_confirmed',
          'message': 'Email not confirmed',
        }),
        400,
        headers: const <String, String>{'content-type': 'application/json'},
      );

      await expectLater(
        repository.signIn(
          email: 'customer@example.com',
          password: 'safe-password',
        ),
        throwsA(
          isA<AuthFailure>().having(
            (failure) => failure.userMessage,
            'userMessage',
            'Please confirm your email address before signing in.',
          ),
        ),
      );
    },
  );

  test('password recovery includes the configured app redirect', () async {
    http.BaseRequest? capturedRequest;
    responseFor = (request) async {
      capturedRequest = request;
      return http.Response('{}', 200);
    };

    await repository.requestPasswordRecovery(' customer@example.com ');

    expect(capturedRequest?.url.path, '/auth/v1/recover');
    expect(
      capturedRequest?.url.queryParameters['redirect_to'],
      authRedirectUrl,
    );
    final body = jsonDecode(
      (capturedRequest! as http.Request).body,
    ) as Map<String, dynamic>;
    expect(body['email'], 'customer@example.com');
  });
}

Map<String, Object?> _userJson({
  required String email,
  String? emailConfirmedAt,
}) => <String, Object?>{
  'id': 'customer-1',
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': email,
  'email_confirmed_at': emailConfirmedAt,
  'created_at': '2026-11-13T00:00:00Z',
  'app_metadata': <String, Object?>{},
  'user_metadata': <String, Object?>{},
  'identities': <Object?>[],
};

String _accessToken() {
  String segment(String value) =>
      base64Url.encode(utf8.encode(value)).replaceAll('=', '');

  return '${segment('{"alg":"HS256","typ":"JWT"}')}'
      '.${segment('{"exp":4102444800,"sub":"customer-1","role":"authenticated"}')}'
      '.test-signature';
}
