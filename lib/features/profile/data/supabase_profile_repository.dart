import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/profile/domain/customer_profile.dart';
import 'package:tikka/features/profile/domain/profile_failure.dart';
import 'package:tikka/features/profile/domain/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  const SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<CustomerProfile> getCurrentProfile() async {
    final user = _requireUser();
    try {
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .limit(1);
      final rows = response as List<dynamic>;
      if (rows.isEmpty) {
        throw const ProfileFailure(
          'Your profile could not be found. Please contact support.',
        );
      }
      return CustomerProfile.fromJson(rows.first as Map<String, dynamic>);
    } on ProfileFailure {
      rethrow;
    } on PostgrestException catch (error) {
      throw ProfileFailure(_friendlyMessage(error));
    } on Object {
      throw const ProfileFailure(
        'We could not load your profile. Check your connection and try again.',
      );
    }
  }

  @override
  Future<CustomerProfile> updateCurrentProfile({
    required String fullName,
    String? phoneNumber,
    String? savedAddress,
  }) async {
    final user = _requireUser();
    try {
      final response = await _client
          .from('profiles')
          .update(<String, dynamic>{
            'full_name': fullName.trim(),
            'phone_number': _nullable(phoneNumber),
            'saved_address': _nullable(savedAddress),
          })
          .eq('id', user.id)
          .select();
      final rows = response as List<dynamic>;
      if (rows.isEmpty) {
        throw const ProfileFailure(
          'Your profile could not be found. Please contact support.',
        );
      }
      return CustomerProfile.fromJson(rows.first as Map<String, dynamic>);
    } on PostgrestException catch (error) {
      throw ProfileFailure(_friendlyMessage(error));
    } on Object {
      throw const ProfileFailure(
        'We could not save your profile. Check your connection and try again.',
      );
    }
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ProfileFailure(
        'Your session has expired. Please sign in again.',
      );
    }
    return user;
  }

  String? _nullable(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String _friendlyMessage(PostgrestException error) {
    final message = error.message.toLowerCase();
    if (message.contains('permission') || message.contains('row-level')) {
      return 'You do not have permission to update this profile.';
    }
    return 'We could not complete the profile request. Please try again.';
  }
}
