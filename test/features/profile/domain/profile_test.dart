import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/features/profile/domain/customer_profile.dart';
import 'package:tikka/features/profile/domain/profile_validators.dart';

void main() {
  test('CustomerProfile serializes and deserializes approved fields', () {
    const profile = CustomerProfile(
      id: 'customer-1',
      fullName: 'Tikka Customer',
      phoneNumber: '+94771234567',
      savedAddress: '12 Main Street',
      avatarUrl: null,
    );

    final restored = CustomerProfile.fromJson(profile.toJson());

    expect(restored.id, profile.id);
    expect(restored.fullName, profile.fullName);
    expect(restored.phoneNumber, profile.phoneNumber);
    expect(restored.savedAddress, profile.savedAddress);
    expect(restored.avatarUrl, isNull);
  });

  test('profile validators accept optional empty contact fields', () {
    expect(ProfileValidators.fullName(''), isNotNull);
    expect(ProfileValidators.fullName('Customer'), isNull);
    expect(ProfileValidators.phoneNumber(''), isNull);
    expect(ProfileValidators.phoneNumber('+94 77 123 4567'), isNull);
    expect(ProfileValidators.phoneNumber('not-a-phone'), isNotNull);
    expect(ProfileValidators.savedAddress(''), isNull);
    expect(ProfileValidators.savedAddress('a' * 251), isNotNull);
  });
}
