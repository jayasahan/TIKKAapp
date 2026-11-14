import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/reviews/domain/review.dart';
import 'package:tikka/features/reviews/domain/review_failure.dart';
import 'package:tikka/features/reviews/domain/review_validation.dart';
import 'package:tikka/features/reviews/domain/reviews_repository.dart';
import 'package:tikka/features/reviews/data/supabase_reviews_repository.dart';
import 'package:tikka/features/reviews/presentation/review_screen.dart';

void main() {
  test('review model preserves nullable comment and timestamps', () {
    final review = Review(
      id: 'review-1',
      bookingId: 'booking-1',
      customerId: 'customer-1',
      rating: 5,
      comment: null,
      createdAt: DateTime(2026, 12, 1),
      updatedAt: DateTime(2026, 12, 2),
    );

    final restored = Review.fromJson(review.toJson());

    expect(restored.id, review.id);
    expect(restored.bookingId, review.bookingId);
    expect(restored.rating, 5);
    expect(restored.comment, isNull);
    expect(restored.updatedAt, review.updatedAt);
  });

  test('review validation requires a rating and trims optional comments', () {
    expect(
      ReviewValidation.validate(comment: '  '),
      containsPair('rating', 'Please select a rating.'),
    );
    expect(ReviewValidation.validate(rating: 0), contains('rating'));
    expect(ReviewValidation.validate(rating: 5, comment: '  '), isEmpty);
    expect(
      ReviewValidation.normalizedComment('  Great service  '),
      'Great service',
    );
    expect(ReviewValidation.normalizedComment('  '), isNull);
  });

  test(
    'Supabase review repository requires an authenticated session',
    () async {
      final client = SupabaseClient(
        'https://tikka-test.supabase.co',
        'test-anon-key',
      );
      final repository = SupabaseReviewsRepository(client);

      await expectLater(
        repository.getReviewForBooking('booking-1'),
        throwsA(isA<ReviewFailure>()),
      );
      await client.dispose();
    },
  );

  testWidgets('review screen submits a selected rating and optional comment', (
    WidgetTester tester,
  ) async {
    final reviews = _FakeReviewsRepository();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ReviewScreen(
          bookingId: 'booking-1',
          bookingsRepository: _FakeBookingsRepository(),
          reviewsRepository: reviews,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('How was your service?'), findsOneWidget);
    await tester.tap(find.byTooltip('5 stars'));
    await tester.enterText(find.byType(TextField), '  Excellent service  ');
    await tester.tap(find.text('Submit review'));
    await tester.pumpAndSettle();

    expect(reviews.submittedRating, 5);
    expect(reviews.submittedComment, 'Excellent service');
    expect(find.text('Review submitted'), findsOneWidget);
  });
}

Booking _booking() => Booking(
  id: 'booking-1',
  bookingReference: 'TK-1001',
  customerId: 'customer-1',
  serviceId: 'service-1',
  serviceName: 'Plumbing',
  status: 'COMPLETED',
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
  @override
  Future<Booking> createBooking(
    BookingDraft draft, {
    required String customerId,
  }) async => throw UnimplementedError();

  @override
  Future<List<Booking>> getCustomerBookings(String customerId) async =>
      <Booking>[_booking()];

  @override
  Future<Booking?> getBookingById(String bookingId) async => _booking();

  @override
  Future<List<Booking>> getCurrentCustomerBookings() async => <Booking>[
    _booking(),
  ];

  @override
  Future<Booking?> getCurrentCustomerBookingById(String bookingId) async =>
      bookingId == 'booking-1' ? _booking() : null;

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {}
}

class _FakeReviewsRepository implements ReviewsRepository {
  int? submittedRating;
  String? submittedComment;

  @override
  Future<Review?> getReviewForBooking(String bookingId) async => null;

  @override
  Future<Review> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    submittedRating = rating;
    submittedComment = comment?.trim();
    return Review(
      id: 'review-1',
      bookingId: bookingId,
      customerId: 'customer-1',
      rating: rating,
      comment: submittedComment,
      createdAt: DateTime(2026, 12, 1),
    );
  }
}
