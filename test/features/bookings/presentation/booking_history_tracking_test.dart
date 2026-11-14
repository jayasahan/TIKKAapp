import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/bookings/presentation/booking_history_screen.dart';
import 'package:tikka/features/bookings/presentation/booking_tracking_screen.dart';

void main() {
  test('booking model preserves tracking fields during serialization', () {
    final booking = _booking(id: 'booking-1', status: 'ASSIGNED');

    final restored = Booking.fromJson(booking.toJson());

    expect(restored.id, booking.id);
    expect(restored.status, 'ASSIGNED');
    expect(restored.preferredDate, booking.preferredDate);
    expect(restored.updatedAt, booking.updatedAt);
  });

  testWidgets('booking history filters requests by lifecycle state', (
    WidgetTester tester,
  ) async {
    final repository = _FakeBookingsRepository(<Booking>[
      _booking(id: 'active', status: 'SCHEDULED'),
      _booking(id: 'completed', status: 'COMPLETED'),
      _booking(id: 'cancelled', status: 'CANCELLED'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: BookingHistoryScreen(repository: repository)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Plumbing'), findsOneWidget);
    expect(find.text('SCHEDULED'), findsOneWidget);
    expect(find.text('COMPLETED'), findsNothing);

    await tester.tap(find.text('Completed'));
    await tester.pumpAndSettle();
    expect(find.text('COMPLETED'), findsOneWidget);
    expect(find.text('SCHEDULED'), findsNothing);

    await tester.tap(find.text('Cancelled'));
    await tester.pumpAndSettle();
    expect(find.text('CANCELLED'), findsOneWidget);
  });

  testWidgets('tracking screen displays progress and review action', (
    WidgetTester tester,
  ) async {
    final repository = _FakeBookingsRepository(<Booking>[
      _booking(id: 'completed', status: 'COMPLETED'),
    ]);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: BookingTrackingScreen(
          bookingId: 'completed',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Request tracking'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('IN PROGRESS'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Review service'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Review service'), findsOneWidget);
  });
}

Booking _booking({required String id, required String status}) => Booking(
  id: id,
  bookingReference: 'TK-1001',
  customerId: 'customer-1',
  serviceId: 'service-1',
  serviceName: 'Plumbing',
  status: status,
  problemDescription: 'Leaking pipe',
  serviceAddressSnapshot: '12 Main Street',
  contactNameSnapshot: 'Customer',
  contactPhoneSnapshot: '+94771234567',
  preferredDate: DateTime(2026, 12, 1),
  preferredTime: '10:00 AM',
  createdAt: DateTime(2026, 11, 14),
  updatedAt: DateTime(2026, 11, 14),
);

class _FakeBookingsRepository implements BookingsRepository {
  _FakeBookingsRepository(this.bookings);

  final List<Booking> bookings;

  @override
  Future<Booking> createBooking(
    BookingDraft draft, {
    required String customerId,
  }) async => throw UnimplementedError();

  @override
  Future<List<Booking>> getCustomerBookings(String customerId) async =>
      bookings;

  @override
  Future<Booking?> getBookingById(String bookingId) async =>
      bookings.where((booking) => booking.id == bookingId).firstOrNull;

  @override
  Future<List<Booking>> getCurrentCustomerBookings() async => bookings;

  @override
  Future<Booking?> getCurrentCustomerBookingById(String bookingId) async =>
      bookings.where((booking) => booking.id == bookingId).firstOrNull;

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {}
}
