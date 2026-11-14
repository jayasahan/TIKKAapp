import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/reviews/domain/review.dart';
import 'package:tikka/features/reviews/domain/review_failure.dart';
import 'package:tikka/features/reviews/domain/review_validation.dart';
import 'package:tikka/features/reviews/domain/reviews_repository.dart';

class SupabaseReviewsRepository implements ReviewsRepository {
  const SupabaseReviewsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Review?> getReviewForBooking(String bookingId) async {
    final user = _requireUser();
    try {
      final response = await _client
          .from('reviews')
          .select()
          .eq('booking_id', bookingId)
          .eq('customer_id', user.id)
          .maybeSingle();
      return response == null ? null : Review.fromJson(response);
    } on ReviewFailure {
      rethrow;
    } on PostgrestException {
      throw const ReviewFailure(
        'We could not load the review. Check your connection and try again.',
      );
    } on Object {
      throw const ReviewFailure(
        'We could not load the review. Check your connection and try again.',
      );
    }
  }

  @override
  Future<Review> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    final validationErrors = ReviewValidation.validate(
      rating: rating,
      comment: comment,
    );
    if (validationErrors.isNotEmpty) {
      throw ReviewFailure(validationErrors.values.first);
    }

    final user = _requireUser();
    try {
      final bookingResponse = await _client
          .from('bookings')
          .select('id, status')
          .eq('id', bookingId)
          .eq('customer_id', user.id)
          .maybeSingle();
      if (bookingResponse == null) {
        throw const ReviewFailure('This request is not available for review.');
      }

      final status = bookingResponse['status'] as String?;
      if (status != 'COMPLETED' && status != 'CONFIRMED') {
        throw const ReviewFailure(
          'You can review a request after it is completed.',
        );
      }

      final response = await _client
          .from('reviews')
          .insert(<String, dynamic>{
            'booking_id': bookingId,
            'customer_id': user.id,
            'rating': rating,
            'comment': ReviewValidation.normalizedComment(comment),
          })
          .select()
          .single();
      return Review.fromJson(response);
    } on ReviewFailure {
      rethrow;
    } on PostgrestException catch (error) {
      if (error.code == '23505' ||
          error.message.toLowerCase().contains('duplicate')) {
        throw const ReviewFailure('This request has already been reviewed.');
      }
      if (error.code == '42501' ||
          error.message.toLowerCase().contains('permission') ||
          error.message.toLowerCase().contains('row-level')) {
        throw const ReviewFailure(
          'You are not allowed to review this request.',
        );
      }
      throw const ReviewFailure(
        'We could not submit your review. Please try again.',
      );
    } on Object {
      throw const ReviewFailure(
        'We could not submit your review. Check your connection and try again.',
      );
    }
  }

  User _requireUser() {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const ReviewFailure(
        'Your session has expired. Please sign in again.',
      );
    }
    return user;
  }
}
