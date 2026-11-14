import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/features/bookings/data/supabase_bookings_repository.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';

void main() {
  group('SupabaseBookingsRepository', () {
    late SupabaseBookingsRepository repository;

    setUp(() {
      repository = SupabaseBookingsRepository();
    });

    test(
      'creates booking with status NEW and formatted booking reference',
      () async {
        final draft = BookingDraft(
          serviceId: 'plumbing-general',
          serviceName: 'Plumbing',
          problemDescription: 'Leaking water pipe under the kitchen sink',
          serviceAddress: 'No. 12, Main Street, Matara',
          contactName: 'Kasun Perera',
          contactPhone: '+94 77 123 4567',
          preferredDate: DateTime(2026, 12, 1),
          preferredTime: '10:00 AM',
        );

        final booking = await repository.createBooking(
          draft,
          customerId: 'customer-123',
        );

        expect(booking.id, isNotEmpty);
        expect(booking.bookingReference, startsWith('TK-'));
        expect(booking.status, 'NEW');
        expect(booking.serviceId, 'plumbing-general');
        expect(
          booking.problemDescription,
          'Leaking water pipe under the kitchen sink',
        );
        expect(booking.serviceAddressSnapshot, 'No. 12, Main Street, Matara');
        expect(booking.contactNameSnapshot, 'Kasun Perera');
        expect(booking.contactPhoneSnapshot, '+94 77 123 4567');
        expect(booking.preferredTime, '10:00 AM');
        expect(booking.isCancellable, isTrue);
        expect(booking.isCompleted, isFalse);
      },
    );

    test(
      'getCustomerBookings retrieves customer bookings in descending order',
      () async {
        final draft1 = BookingDraft(
          serviceId: 'plumbing-general',
          serviceName: 'Plumbing',
          problemDescription: 'First issue',
          serviceAddress: 'Matara',
          contactName: 'Kasun',
          contactPhone: '+94 77 111 2222',
          preferredDate: DateTime(2026, 12, 1),
          preferredTime: '09:00 AM',
        );

        final draft2 = BookingDraft(
          serviceId: 'electrical-repairs',
          serviceName: 'Electrical',
          problemDescription: 'Second issue',
          serviceAddress: 'Galle',
          contactName: 'Kasun',
          contactPhone: '+94 77 111 2222',
          preferredDate: DateTime(2026, 12, 2),
          preferredTime: '02:00 PM',
        );

        await repository.createBooking(draft1, customerId: 'cust-A');
        await repository.createBooking(draft2, customerId: 'cust-A');
        await repository.createBooking(draft1, customerId: 'cust-B');

        final custABookings = await repository.getCustomerBookings('cust-A');
        expect(custABookings.length, 2);
        expect(custABookings.first.serviceId, 'electrical-repairs');

        final custBBookings = await repository.getCustomerBookings('cust-B');
        expect(custBBookings.length, 1);
        expect(custBBookings.first.customerId, 'cust-B');
      },
    );

    test('getBookingById and cancelBooking update status correctly', () async {
      final draft = BookingDraft(
        serviceId: 'cleaning-deep',
        serviceName: 'Deep Cleaning',
        problemDescription: 'Full house deep cleaning required',
        serviceAddress: 'Colombo 07',
        contactName: 'Nimal',
        contactPhone: '+94 71 999 8888',
        preferredDate: DateTime(2026, 12, 5),
        preferredTime: '11:30 AM',
      );

      final booking = await repository.createBooking(
        draft,
        customerId: 'customer-456',
      );

      final fetched = await repository.getBookingById(booking.id);
      expect(fetched, isNotNull);
      expect(fetched!.id, booking.id);
      expect(fetched.status, 'NEW');

      await repository.cancelBooking(booking.id, reason: 'Need to reschedule');
      final cancelled = await repository.getBookingById(booking.id);
      expect(cancelled!.status, 'CANCELLED');
      expect(cancelled.cancellationReason, 'Need to reschedule');
      expect(cancelled.isCancellable, isFalse);
    });

    test('BookingDraft validates required fields', () {
      final emptyDraft = BookingDraft(
        serviceId: 'test',
        serviceName: 'Test Service',
        preferredDate: DateTime.now(),
        preferredTime: '10:00 AM',
      );

      final errors = emptyDraft.validate();
      expect(errors.containsKey('problemDescription'), isTrue);
      expect(errors.containsKey('serviceAddress'), isTrue);
      expect(errors.containsKey('contactName'), isTrue);
      expect(errors.containsKey('contactPhone'), isTrue);
      expect(emptyDraft.isValid, isFalse);

      final validDraft = emptyDraft.copyWith(
        problemDescription: 'Valid problem description here',
        serviceAddress: '123 Test Street, City',
        contactName: 'Test User',
        contactPhone: '+94 77 123 4567',
      );
      expect(validDraft.isValid, isTrue);
      expect(validDraft.validate().isEmpty, isTrue);
    });
  });
}
