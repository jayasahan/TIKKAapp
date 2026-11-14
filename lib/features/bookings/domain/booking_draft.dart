class BookingDraft {
  const BookingDraft({
    required this.serviceId,
    required this.serviceName,
    this.serviceDescription,
    this.problemDescription = '',
    this.serviceAddress = '',
    this.contactName = '',
    this.contactPhone = '',
    required this.preferredDate,
    required this.preferredTime,
    this.photoStoragePath,
    this.localPhotoPath,
  });

  final String serviceId;
  final String serviceName;
  final String? serviceDescription;
  final String problemDescription;
  final String serviceAddress;
  final String contactName;
  final String contactPhone;
  final DateTime preferredDate;
  final String preferredTime;
  final String? photoStoragePath;
  final String? localPhotoPath;

  BookingDraft copyWith({
    String? serviceId,
    String? serviceName,
    String? serviceDescription,
    String? problemDescription,
    String? serviceAddress,
    String? contactName,
    String? contactPhone,
    DateTime? preferredDate,
    String? preferredTime,
    String? photoStoragePath,
    String? localPhotoPath,
  }) {
    return BookingDraft(
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceDescription: serviceDescription ?? this.serviceDescription,
      problemDescription: problemDescription ?? this.problemDescription,
      serviceAddress: serviceAddress ?? this.serviceAddress,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      preferredDate: preferredDate ?? this.preferredDate,
      preferredTime: preferredTime ?? this.preferredTime,
      photoStoragePath: photoStoragePath ?? this.photoStoragePath,
      localPhotoPath: localPhotoPath ?? this.localPhotoPath,
    );
  }

  /// Validates step 1 inputs and returns error map (or empty if valid).
  Map<String, String> validate() {
    final errors = <String, String>{};

    if (problemDescription.trim().isEmpty) {
      errors['problemDescription'] =
          'Please describe the problem or required work';
    } else if (problemDescription.trim().length < 5) {
      errors['problemDescription'] =
          'Please provide more details (at least 5 characters)';
    }

    if (serviceAddress.trim().isEmpty) {
      errors['serviceAddress'] = 'Please provide the service location address';
    } else if (serviceAddress.trim().length < 5) {
      errors['serviceAddress'] = 'Address is too short';
    }

    if (contactName.trim().isEmpty) {
      errors['contactName'] = 'Contact name is required';
    }

    if (contactPhone.trim().isEmpty) {
      errors['contactPhone'] = 'Contact phone number is required';
    }

    return errors;
  }

  bool get isValid => validate().isEmpty;
}
