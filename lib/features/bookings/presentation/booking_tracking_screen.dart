import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/bookings_failure.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/bookings/presentation/booking_history_screen.dart';
import 'package:tikka/features/bookings/presentation/booking_status.dart';

class BookingTrackingScreen extends StatefulWidget {
  const BookingTrackingScreen({
    super.key,
    required this.bookingId,
    required this.repository,
  });

  final String bookingId;
  final BookingsRepository repository;

  @override
  State<BookingTrackingScreen> createState() => _BookingTrackingScreenState();
}

class _BookingTrackingScreenState extends State<BookingTrackingScreen> {
  Booking? _booking;
  String? _error;
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking({bool refresh = false}) async {
    setState(() {
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });
    try {
      final booking = await widget.repository.getCurrentCustomerBookingById(
        widget.bookingId,
      );
      if (!mounted) return;
      setState(() {
        _booking = booking;
        _isLoading = false;
        _isRefreshing = false;
      });
    } on BookingsFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.userMessage;
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: TikkaLoadingState(message: 'Loading request…')),
      );
    }
    if (_error != null && _booking == null) {
      return Scaffold(
        body: Center(
          child: TikkaErrorState(message: _error!, onRetry: _loadBooking),
        ),
      );
    }
    final booking = _booking;
    if (booking == null) {
      return const Scaffold(
        body: Center(
          child: TikkaEmptyState(
            title: 'Request unavailable',
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
        title: const Text('Request tracking'),
        actions: <Widget>[
          IconButton(
            onPressed: _isRefreshing ? null : () => _loadBooking(refresh: true),
            tooltip: 'Refresh request',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadBooking(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.large),
          children: <Widget>[
            if (_isRefreshing) const LinearProgressIndicator(),
            if (_error != null) ...<Widget>[
              const SizedBox(height: AppSpacing.small),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.error),
              ),
            ],
            _BookingSummary(booking: booking),
            const SizedBox(height: AppSpacing.large),
            _StatusTimeline(status: booking.status),
            const SizedBox(height: AppSpacing.large),
            if (booking.assignedWorkerName == null &&
                !BookingStatusPresentation.isCancelled(booking.status))
              const Text(
                'Worker not assigned yet',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else if (booking.assignedWorkerName != null)
              Text('Assigned worker: ${booking.assignedWorkerName}'),
            if (BookingStatusPresentation.isCompleted(
              booking.status,
            )) ...<Widget>[
              const SizedBox(height: AppSpacing.large),
              OutlinedButton.icon(
                onPressed: () =>
                    Navigator.of(context)
                        .pushNamed(AppRoutes.writeReview(booking.id)),
                icon: const Icon(Icons.star_outline),
                label: const Text('Review service'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  const _BookingSummary({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) => Card(
    margin: EdgeInsets.zero,
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
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  booking.serviceName ?? 'Service request',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              StatusBadge(status: booking.status),
            ],
          ),
          const Divider(height: AppSpacing.xLarge),
          _SummaryDetail(label: 'Reference', value: booking.bookingReference),
          _SummaryDetail(label: 'Job', value: booking.problemDescription),
          _SummaryDetail(
            label: 'Address',
            value: booking.serviceAddressSnapshot,
          ),
          _SummaryDetail(
            label: 'Preferred schedule',
            value: _scheduleLabel(booking),
          ),
        ],
      ),
    ),
  );
}

class _SummaryDetail extends StatelessWidget {
  const _SummaryDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.medium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xSmall),
        Text(value, style: Theme.of(context).textTheme.bodyLarge),
      ],
    ),
  );
}

class _StatusTimeline extends StatelessWidget {
  const _StatusTimeline({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final currentIndex = BookingStatusPresentation.lifecycle.indexOf(status);
    final isTerminal = BookingStatusPresentation.isCancelled(status);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Progress', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.medium),
        if (isTerminal)
          _TimelineItem(
            label: BookingStatusPresentation.label(status),
            isCurrent: true,
            isComplete: false,
            isLast: true,
          )
        else
          ...BookingStatusPresentation.lifecycle.asMap().entries.map(
            (entry) => _TimelineItem(
              label: BookingStatusPresentation.label(entry.value),
              isCurrent: entry.value == status,
              isComplete: currentIndex > entry.key,
              isLast:
                  entry.key == BookingStatusPresentation.lifecycle.length - 1,
            ),
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.label,
    required this.isCurrent,
    required this.isComplete,
    required this.isLast,
  });

  final String label;
  final bool isCurrent;
  final bool isComplete;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isCurrent || isComplete
        ? AppColors.success
        : AppColors.border;
    return SizedBox(
      height: isLast ? 46 : 58,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 28,
            child: Column(
              children: <Widget>[
                Icon(
                  isComplete
                      ? Icons.check_circle
                      : isCurrent
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 22,
                  color: color,
                ),
                if (!isLast) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.small, top: 2),
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
                color: isCurrent
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _scheduleLabel(Booking booking) {
  final scheduledAt = booking.scheduledAt;
  if (scheduledAt != null) {
    return '${_formatDate(scheduledAt)} • '
        '${scheduledAt.hour.toString().padLeft(2, '0')}:'
        '${scheduledAt.minute.toString().padLeft(2, '0')}';
  }
  return '${_formatDate(booking.preferredDate)} • ${booking.preferredTime}';
}
