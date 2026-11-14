abstract final class ProfileValidators {
  static String? fullName(String value) {
    if (value.trim().isEmpty) {
      return 'Enter your full name.';
    }
    return null;
  }

  static String? phoneNumber(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final normalized = trimmed.replaceAll(RegExp(r'[()\-\s]'), '');
    return RegExp(r'^\+?[0-9]{7,15}$').hasMatch(normalized)
        ? null
        : 'Enter a valid phone number.';
  }

  static String? savedAddress(String value) {
    if (value.trim().length > 250) {
      return 'Address must be 250 characters or fewer.';
    }
    return null;
  }
}
