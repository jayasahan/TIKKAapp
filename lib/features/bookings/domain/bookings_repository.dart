import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';

abstract interface class BookingsRepository {
  Future<Booking> createBooking(
    BookingDraft draft, {
    required String customerId,
  });

  Future<List<Booking>> getCustomerBookings(String customerId);

  Future<Booking?> getBookingById(String bookingId);

  Future<void> cancelBooking(String bookingId, {String? reason});
}
