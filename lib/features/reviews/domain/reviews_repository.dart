import 'review.dart';

abstract interface class ReviewsRepository {
  Future<Review?> getReviewForBooking(String bookingId);

  Future<Review> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  });
}
