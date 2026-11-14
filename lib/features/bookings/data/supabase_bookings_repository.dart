import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';

class SupabaseBookingsRepository implements BookingsRepository {
  SupabaseBookingsRepository({this.client});

  final SupabaseClient? client;

  // In-memory backing store for local testing and offline fallback
  final List<Booking> _inMemoryBookings = <Booking>[];
  int _sequenceCounter = 1042;

  @override
  Future<Booking> createBooking(
    BookingDraft draft, {
    required String customerId,
  }) async {
    final activeClient = client;

    if (activeClient != null) {
      try {
        final payload = <String, dynamic>{
          'customer_id': customerId,
          'service_id': draft.serviceId,
          'status': 'NEW',
          'problem_description': draft.problemDescription.trim(),
          'service_address_snapshot': draft.serviceAddress.trim(),
          'contact_name_snapshot': draft.contactName.trim(),
          'contact_phone_snapshot': draft.contactPhone.trim(),
          'preferred_date': draft.preferredDate
              .toIso8601String()
              .split('T')
              .first,
          'preferred_time': draft.preferredTime.trim(),
          if (draft.photoStoragePath != null &&
              draft.photoStoragePath!.isNotEmpty)
            'photo_storage_path': draft.photoStoragePath,
        };

        final response = await activeClient
            .from('bookings')
            .insert(payload)
            .select()
            .single();

        final booking = Booking.fromJson(response);
        _inMemoryBookings.insert(0, booking);
        return booking;
      } on Object {
        // Fallback to local simulation if live Supabase is not reachable
        return _createLocalBooking(draft, customerId);
      }
    }

    return _createLocalBooking(draft, customerId);
  }

  @override
  Future<List<Booking>> getCustomerBookings(String customerId) async {
    final activeClient = client;

    if (activeClient != null) {
      try {
        final response = await activeClient
            .from('bookings')
            .select()
            .eq('customer_id', customerId)
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((item) => Booking.fromJson(item as Map<String, dynamic>))
            .toList();

        return list;
      } on Object {
        return _inMemoryBookings
            .where((b) => b.customerId == customerId)
            .toList();
      }
    }

    return _inMemoryBookings.where((b) => b.customerId == customerId).toList();
  }

  @override
  Future<Booking?> getBookingById(String bookingId) async {
    final activeClient = client;

    if (activeClient != null) {
      try {
        final response = await activeClient
            .from('bookings')
            .select()
            .eq('id', bookingId)
            .maybeSingle();

        if (response != null) {
          return Booking.fromJson(response);
        }
      } on Object {
        // continue to in-memory lookup
      }
    }

    return _inMemoryBookings
        .where((b) => b.id == bookingId || b.bookingReference == bookingId)
        .firstOrNull;
  }

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    final activeClient = client;

    if (activeClient != null) {
      try {
        await activeClient
            .from('bookings')
            .update({
              'status': 'CANCELLED',
              'cancellation_reason': ?reason,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', bookingId);
      } on Object {
        // continue to in-memory update
      }
    }

    final index = _inMemoryBookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final existing = _inMemoryBookings[index];
      _inMemoryBookings[index] = Booking(
        id: existing.id,
        bookingReference: existing.bookingReference,
        customerId: existing.customerId,
        serviceId: existing.serviceId,
        serviceName: existing.serviceName,
        status: 'CANCELLED',
        problemDescription: existing.problemDescription,
        serviceAddressSnapshot: existing.serviceAddressSnapshot,
        contactNameSnapshot: existing.contactNameSnapshot,
        contactPhoneSnapshot: existing.contactPhoneSnapshot,
        preferredDate: existing.preferredDate,
        preferredTime: existing.preferredTime,
        photoStoragePath: existing.photoStoragePath,
        assignedWorkerName: existing.assignedWorkerName,
        scheduledAt: existing.scheduledAt,
        cancellationReason: reason ?? existing.cancellationReason,
        rejectionReason: existing.rejectionReason,
        adminNotes: existing.adminNotes,
        createdAt: existing.createdAt,
        updatedAt: DateTime.now(),
      );
    }
  }

  Booking _createLocalBooking(BookingDraft draft, String customerId) {
    _sequenceCounter++;
    final now = DateTime.now();
    final booking = Booking(
      id: 'b${DateTime.now().millisecondsSinceEpoch}',
      bookingReference: 'TK-$_sequenceCounter',
      customerId: customerId,
      serviceId: draft.serviceId,
      serviceName: draft.serviceName,
      status: 'NEW',
      problemDescription: draft.problemDescription.trim(),
      serviceAddressSnapshot: draft.serviceAddress.trim(),
      contactNameSnapshot: draft.contactName.trim(),
      contactPhoneSnapshot: draft.contactPhone.trim(),
      preferredDate: draft.preferredDate,
      preferredTime: draft.preferredTime.trim(),
      photoStoragePath: draft.photoStoragePath,
      createdAt: now,
      updatedAt: now,
    );
    _inMemoryBookings.insert(0, booking);
    return booking;
  }
}
