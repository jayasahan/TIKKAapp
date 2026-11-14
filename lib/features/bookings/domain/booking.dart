class Booking {
  const Booking({
    required this.id,
    required this.bookingReference,
    required this.customerId,
    required this.serviceId,
    required this.status,
    required this.problemDescription,
    required this.serviceAddressSnapshot,
    required this.contactNameSnapshot,
    required this.contactPhoneSnapshot,
    required this.preferredDate,
    required this.preferredTime,
    this.serviceName,
    this.photoStoragePath,
    this.assignedWorkerName,
    this.scheduledAt,
    this.cancellationReason,
    this.rejectionReason,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String bookingReference;
  final String customerId;
  final String serviceId;
  final String status;
  final String problemDescription;
  final String serviceAddressSnapshot;
  final String contactNameSnapshot;
  final String contactPhoneSnapshot;
  final DateTime preferredDate;
  final String preferredTime;
  final String? serviceName;
  final String? photoStoragePath;
  final String? assignedWorkerName;
  final DateTime? scheduledAt;
  final String? cancellationReason;
  final String? rejectionReason;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isCancellable => status == 'NEW' || status == 'REVIEWING';
  bool get isCompleted => status == 'COMPLETED' || status == 'CONFIRMED';

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      bookingReference: json['booking_reference'] as String? ?? 'TK-0000',
      customerId: json['customer_id'] as String,
      serviceId: json['service_id'] as String,
      status: json['status'] as String? ?? 'NEW',
      problemDescription: json['problem_description'] as String,
      serviceAddressSnapshot: json['service_address_snapshot'] as String,
      contactNameSnapshot: json['contact_name_snapshot'] as String,
      contactPhoneSnapshot: json['contact_phone_snapshot'] as String,
      preferredDate: json['preferred_date'] is String
          ? DateTime.parse(json['preferred_date'] as String)
          : json['preferred_date'] as DateTime? ?? DateTime.now(),
      preferredTime: json['preferred_time'] as String,
      serviceName: json['service_name'] as String?,
      photoStoragePath: json['photo_storage_path'] as String?,
      assignedWorkerName: json['assigned_worker_name'] as String?,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.tryParse(json['scheduled_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      adminNotes: json['admin_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'booking_reference': bookingReference,
    'customer_id': customerId,
    'service_id': serviceId,
    'status': status,
    'problem_description': problemDescription,
    'service_address_snapshot': serviceAddressSnapshot,
    'contact_name_snapshot': contactNameSnapshot,
    'contact_phone_snapshot': contactPhoneSnapshot,
    'preferred_date': preferredDate.toIso8601String().split('T').first,
    'preferred_time': preferredTime,
    'photo_storage_path': photoStoragePath,
    'assigned_worker_name': assignedWorkerName,
    'scheduled_at': scheduledAt?.toIso8601String(),
    'cancellation_reason': cancellationReason,
    'rejection_reason': rejectionReason,
    'admin_notes': adminNotes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}
