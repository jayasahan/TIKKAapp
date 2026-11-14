class CustomerProfile {
  const CustomerProfile({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.savedAddress,
    this.avatarUrl,
  });

  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? savedAddress;
  final String? avatarUrl;

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      savedAddress: json['saved_address'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'full_name': fullName,
    'phone_number': phoneNumber,
    'saved_address': savedAddress,
    'avatar_url': avatarUrl,
  };

  CustomerProfile copyWith({
    String? fullName,
    String? phoneNumber,
    String? savedAddress,
    String? avatarUrl,
  }) {
    return CustomerProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      savedAddress: savedAddress ?? this.savedAddress,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }
}
