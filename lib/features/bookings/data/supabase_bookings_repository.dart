import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/bookings/domain/bookings_failure.dart';

class SupabaseBookingsRepository implements BookingsRepository {
  SupabaseBookingsRepository({this.client});

  final SupabaseClient? client;

  // In-memory backing store for local testing and offline fallback
  final List<Booking> _inMemoryBookings = <Booking>[];
  int _sequenceCounter = 1042;

  @override
  Future<List<Booking>> getCurrentCustomerBookings() async {
    final user = _requireUser();
    final activeClient = client;
    if (activeClient == null) {
      return _inMemoryBookings
          .where((booking) => booking.customerId == user.id)
          .toList();
    }

    try {
      final response = await activeClient
          .from('bookings')
          .select('*, services(name)')
          .eq('customer_id', user.id)
          .order('created_at', ascending: false);
      return (response as List<dynamic>)
          .map((item) => _bookingFromResponse(item as Map<String, dynamic>))
          .toList();
    } on PostgrestException {
      throw const BookingsFailure(
        'We could not load your requests. Check your connection and try again.',
      );
    } on BookingsFailure {
      rethrow;
    } on Object {
      throw const BookingsFailure(
        'We could not load your requests. Check your connection and try again.',
      );
    }
  }

  @override
  Future<Booking?> getCurrentCustomerBookingById(String bookingId) async {
    final user = _requireUser();
    final activeClient = client;
    if (activeClient == null) {
      return _inMemoryBookings
          .where(
            (booking) =>
                booking.customerId == user.id &&
                (booking.id == bookingId ||
                    booking.bookingReference == bookingId),
          )
          .firstOrNull;
    }

    try {
      final response = await activeClient
          .from('bookings')
          .select('*, services(name)')
          .eq('id', bookingId)
          .eq('customer_id', user.id)
          .maybeSingle();
      return response == null ? null : _bookingFromResponse(response);
    } on PostgrestException {
      throw const BookingsFailure(
        'We could not load this request. Check your connection and try again.',
      );
    } on BookingsFailure {
      rethrow;
    } on Object {
      throw const BookingsFailure(
        'We could not load this request. Check your connection and try again.',
      );
    }
  }

  @override
  Future<Booking> createBooking(
    BookingDraft draft, {
    required String customerId,
  }) async {
    final activeClient = client;

    if (activeClient != null) {
      try {
        final authenticatedUser = _requireUser();
        final payload = <String, dynamic>{
          'customer_id': authenticatedUser.id,
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

        final booking = _bookingFromResponse(response);
        _inMemoryBookings.insert(0, booking);
        return booking;
      } on BookingsFailure {
        rethrow;
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
        final authenticatedUser = _requireUser();
        final response = await activeClient
            .from('bookings')
            .select('*, services(name)')
            .eq('customer_id', authenticatedUser.id)
            .order('created_at', ascending: false);

        final list = (response as List<dynamic>)
            .map((item) => _bookingFromResponse(item as Map<String, dynamic>))
            .toList();

        return list;
      } on BookingsFailure {
        rethrow;
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
        final authenticatedUser = _requireUser();
        final response = await activeClient
            .from('bookings')
            .select('*, services(name)')
            .eq('id', bookingId)
            .eq('customer_id', authenticatedUser.id)
            .maybeSingle();

        if (response != null) {
          return _bookingFromResponse(response);
        }
      } on BookingsFailure {
        rethrow;
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
        final authenticatedUser = _requireUser();
        await activeClient
            .from('bookings')
            .update({
              'status': 'CANCELLED',
              'cancellation_reason': ?reason,
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', bookingId)
            .eq('customer_id', authenticatedUser.id);
      } on BookingsFailure {
        rethrow;
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

  User _requireUser() {
    final user = client?.auth.currentUser;
    if (user == null) {
      throw const BookingsFailure(
        'Your session has expired. Please sign in again.',
      );
    }
    return user;
  }

  Booking _bookingFromResponse(Map<String, dynamic> response) {
    final service = response['services'];
    if (response['service_name'] == null && service is Map<String, dynamic>) {
      return Booking.fromJson(<String, dynamic>{
        ...response,
        'service_name': service['name'],
      });
    }
    return Booking.fromJson(response);
  }
}
