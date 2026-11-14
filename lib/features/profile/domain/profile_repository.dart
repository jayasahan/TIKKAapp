import 'customer_profile.dart';

abstract interface class ProfileRepository {
  Future<CustomerProfile> getCurrentProfile();

  Future<CustomerProfile> updateCurrentProfile({
    required String fullName,
    String? phoneNumber,
    String? savedAddress,
  });
}
