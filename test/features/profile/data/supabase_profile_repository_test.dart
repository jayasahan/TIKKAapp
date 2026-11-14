import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/profile/data/supabase_profile_repository.dart';
import 'package:tikka/features/profile/domain/profile_failure.dart';

void main() {
  late Future<http.Response> Function(http.BaseRequest request) responseFor;
  late MockClient httpClient;
  late SupabaseClient client;
  late SupabaseProfileRepository repository;

  setUp(() {
    responseFor = (request) async {
      if (request.url.path.startsWith('/auth/v1/token')) {
        return http.Response(
          jsonEncode(<String, Object?>{
            'access_token': _accessToken(),
            'refresh_token': 'refresh-token',
            'token_type': 'bearer',
            'expires_in': 3600,
            'user': _userJson(),
          }),
          200,
          headers: const <String, String>{'content-type': 'application/json'},
          request: request,
        );
      }
      return http.Response(
        jsonEncode(<Map<String, Object?>>[_profileJson()]),
        200,
        headers: const <String, String>{
          'content-type': 'application/json',
          'content-range': '0-0/1',
        },
        request: request,
      );
    };
    httpClient = MockClient((request) => responseFor(request));
    client = SupabaseClient(
      'https://tikka-test.supabase.co',
      'test-anon-key',
      httpClient: httpClient,
      authOptions: const AuthClientOptions(autoRefreshToken: false),
    );
    repository = SupabaseProfileRepository(client);
  });

  tearDown(() async {
    await client.dispose();
    httpClient.close();
  });

  test('requires an authenticated Supabase user', () async {
    await expectLater(
      repository.getCurrentProfile(),
      throwsA(
        isA<ProfileFailure>().having(
          (failure) => failure.userMessage,
          'userMessage',
          'Your session has expired. Please sign in again.',
        ),
      ),
    );
  });

  test('retrieves the profile using the authenticated user id', () async {
    await client.auth.signInWithPassword(
      email: 'customer@example.com',
      password: 'safe-password',
    );

    final profile = await repository.getCurrentProfile();

    expect(profile.id, 'customer-1');
    expect(profile.fullName, 'Tikka Customer');
  });

  test('maps a missing profile row to a profile failure', () async {
    await client.auth.signInWithPassword(
      email: 'customer@example.com',
      password: 'safe-password',
    );
    responseFor = (request) async => http.Response(
      '[]',
      200,
      headers: const <String, String>{
        'content-type': 'application/json',
        'content-range': '0-0/0',
      },
      request: request,
    );

    await expectLater(
      repository.getCurrentProfile(),
      throwsA(isA<ProfileFailure>()),
    );
  });

  test('updates only the authenticated user profile row', () async {
    await client.auth.signInWithPassword(
      email: 'customer@example.com',
      password: 'safe-password',
    );
    http.BaseRequest? capturedRequest;
    responseFor = (request) async {
      capturedRequest = request;
      return http.Response(
        jsonEncode(<Map<String, Object?>>[
          _profileJson(fullName: 'Updated Customer'),
        ]),
        200,
        headers: const <String, String>{
          'content-type': 'application/json',
          'content-range': '0-0/1',
        },
        request: request,
      );
    };

    final profile = await repository.updateCurrentProfile(
      fullName: ' Updated Customer ',
      phoneNumber: '',
      savedAddress: 'New address',
    );

    expect(profile.fullName, 'Updated Customer');
    expect(capturedRequest?.url.queryParameters['id'], 'eq.customer-1');
    final body = jsonDecode(
      (capturedRequest! as http.Request).body,
    ) as Map<String, dynamic>;
    expect(body['full_name'], 'Updated Customer');
    expect(body['phone_number'], isNull);
    expect(body['saved_address'], 'New address');
  });
}

Map<String, Object?> _profileJson({String fullName = 'Tikka Customer'}) =>
    <String, Object?>{
      'id': 'customer-1',
      'full_name': fullName,
      'phone_number': '+94771234567',
      'saved_address': '12 Main Street',
      'avatar_url': null,
    };

Map<String, Object?> _userJson() => <String, Object?>{
  'id': 'customer-1',
  'aud': 'authenticated',
  'role': 'authenticated',
  'email': 'customer@example.com',
  'email_confirmed_at': '2026-11-13T00:00:00Z',
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
