import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/core/widgets/tikka_text_field.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/bookings_failure.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/reviews/domain/review.dart';
import 'package:tikka/features/reviews/domain/review_failure.dart';
import 'package:tikka/features/reviews/domain/review_validation.dart';
import 'package:tikka/features/reviews/domain/reviews_repository.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
    required this.bookingId,
    required this.bookingsRepository,
    required this.reviewsRepository,
  });

  final String bookingId;
  final BookingsRepository bookingsRepository;
  final ReviewsRepository reviewsRepository;

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final _commentController = TextEditingController();
  Booking? _booking;
  Review? _existingReview;
  String? _error;
  String? _ratingError;
  String? _commentError;
  int? _rating;
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadReview();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadReview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final booking = await widget.bookingsRepository
          .getCurrentCustomerBookingById(widget.bookingId);
      if (booking == null) {
        throw const ReviewFailure('This request is not available for review.');
      }
      if (!booking.isCompleted) {
        throw const ReviewFailure(
          'You can review a request after it is completed.',
        );
      }
      final review = await widget.reviewsRepository.getReviewForBooking(
        booking.id,
      );
      if (!mounted) return;
      setState(() {
        _booking = booking;
        _existingReview = review;
        _isLoading = false;
      });
    } on BookingsFailure catch (failure) {
      _setError(failure.userMessage);
    } on ReviewFailure catch (failure) {
      _setError(failure.userMessage);
    } on Object {
      _setError('We could not load the review. Please try again.');
    }
  }

  Future<void> _submit() async {
    final errors = ReviewValidation.validate(
      rating: _rating,
      comment: _commentController.text,
    );
    setState(() {
      _ratingError = errors['rating'];
      _commentError = errors['comment'];
    });
    if (errors.isNotEmpty || _booking == null || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    try {
      final review = await widget.reviewsRepository.submitReview(
        bookingId: _booking!.id,
        rating: _rating!,
        comment: _commentController.text,
      );
      if (!mounted) return;
      setState(() {
        _existingReview = review;
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your review was submitted.')),
      );
    } on ReviewFailure catch (failure) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(failure.userMessage)));
    } on Object {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('We could not submit your review. Please try again.'),
        ),
      );
    }
  }

  void _setError(String message) {
    if (!mounted) return;
    setState(() {
      _error = message;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: TikkaLoadingState(message: 'Loading review…')),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Review service')),
        body: Center(child: TikkaErrorState(message: _error!)),
      );
    }

    final booking = _booking;
    if (booking == null) {
      return const Scaffold(
        body: Center(
          child: TikkaEmptyState(
            title: 'Review unavailable',
            message: 'This request could not be found.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Review service'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.large),
        children: <Widget>[
          Text(
            booking.serviceName ?? 'Service request',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSpacing.xSmall),
          Text(
            'Reference ${booking.bookingReference}',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xLarge),
          if (_existingReview != null)
            _SubmittedReview(review: _existingReview!)
          else
            _ReviewForm(
              rating: _rating,
              ratingError: _ratingError,
              commentController: _commentController,
              commentError: _commentError,
              isSubmitting: _isSubmitting,
              onRatingSelected: (rating) => setState(() {
                _rating = rating;
                _ratingError = null;
              }),
              onCommentChanged: (_) {
                if (_commentError != null) {
                  setState(() => _commentError = null);
                }
              },
              onSubmit: _submit,
            ),
        ],
      ),
    );
  }
}

class _ReviewForm extends StatelessWidget {
  const _ReviewForm({
    required this.rating,
    required this.ratingError,
    required this.commentController,
    required this.commentError,
    required this.isSubmitting,
    required this.onRatingSelected,
    required this.onCommentChanged,
    required this.onSubmit,
  });

  final int? rating;
  final String? ratingError;
  final TextEditingController commentController;
  final String? commentError;
  final bool isSubmitting;
  final ValueChanged<int> onRatingSelected;
  final ValueChanged<String> onCommentChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'How was your service?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.medium),
        Semantics(
          label: 'Rating, ${rating ?? 0} of 5 stars selected',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List<Widget>.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: isSubmitting ? null : () => onRatingSelected(value),
                tooltip: '$value star${value == 1 ? '' : 's'}',
                icon: Icon(
                  value <= (rating ?? 0) ? Icons.star : Icons.star_border,
                  color: AppColors.brandYellow,
                  size: 38,
                ),
              );
            }),
          ),
        ),
        if (ratingError != null)
          Text(
            ratingError!,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.error),
          ),
        const SizedBox(height: AppSpacing.medium),
        TikkaTextField(
          label: 'Review (optional)',
          hintText: 'Tell us about your experience',
          controller: commentController,
          enabled: !isSubmitting,
          maxLines: 4,
          height: 140,
          textInputAction: TextInputAction.newline,
          onChanged: onCommentChanged,
          errorText: commentError,
        ),
        const SizedBox(height: AppSpacing.large),
        TikkaButton(
          label: isSubmitting ? 'Submitting…' : 'Submit review',
          onPressed: isSubmitting ? null : onSubmit,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _SubmittedReview extends StatelessWidget {
  const _SubmittedReview({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Review submitted',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.medium),
            _RatingStars(rating: review.rating),
            if (review.comment != null) ...<Widget>[
              const SizedBox(height: AppSpacing.medium),
              Text(review.comment!),
            ],
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  const _RatingStars({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) => Row(
    children: List<Widget>.generate(
      5,
      (index) => Icon(
        index < rating ? Icons.star : Icons.star_border,
        color: AppColors.brandYellow,
      ),
    ),
  );
}
