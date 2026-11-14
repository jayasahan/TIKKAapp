import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/bookings_failure.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/bookings/presentation/booking_status.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key, required this.repository});

  final BookingsRepository repository;

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  List<Booking> _bookings = <Booking>[];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _error;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings({bool refresh = false}) async {
    setState(() {
      if (refresh) {
        _isRefreshing = true;
      } else {
        _isLoading = true;
      }
      _error = null;
    });
    try {
      final bookings = await widget.repository.getCurrentCustomerBookings();
      if (!mounted) return;
      setState(() {
        _bookings = bookings;
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

  List<Booking> get _visibleBookings {
    return _bookings.where((booking) {
      if (_selectedTab == 1) {
        return BookingStatusPresentation.isCompleted(booking.status);
      }
      if (_selectedTab == 2) {
        return BookingStatusPresentation.isCancelled(booking.status);
      }
      return !BookingStatusPresentation.isCompleted(booking.status) &&
          !BookingStatusPresentation.isCancelled(booking.status);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: TikkaLoadingState(message: 'Loading your requests…'),
      );
    }
    if (_error != null && _bookings.isEmpty) {
      return Center(
        child: TikkaErrorState(message: _error!, onRetry: _loadBookings),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _loadBookings(refresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.large,
          AppSpacing.medium,
          AppSpacing.large,
          AppSpacing.xLarge,
        ),
        children: <Widget>[
          SegmentedButton<int>(
            segments: const <ButtonSegment<int>>[
              ButtonSegment<int>(value: 0, label: Text('Active')),
              ButtonSegment<int>(value: 1, label: Text('Completed')),
              ButtonSegment<int>(value: 2, label: Text('Cancelled')),
            ],
            selected: <int>{_selectedTab},
            onSelectionChanged: (selection) {
              setState(() => _selectedTab = selection.first);
            },
          ),
          if (_isRefreshing)
            const Padding(
              padding: EdgeInsets.only(top: AppSpacing.medium),
              child: LinearProgressIndicator(),
            ),
          if (_error != null) ...<Widget>[
            const SizedBox(height: AppSpacing.medium),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: AppSpacing.large),
          if (_visibleBookings.isEmpty)
            TikkaEmptyState(
              title: _selectedTab == 0 ? 'No requests yet' : 'Nothing here yet',
              message: _selectedTab == 0
                  ? 'Your service requests will appear here.'
                  : 'Requests in this category will appear here.',
            )
          else
            ..._visibleBookings.map(
              (booking) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.medium),
                child: _BookingCard(booking: booking),
              ),
            ),
        ],
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadii.card),
        onTap: () =>
            Navigator.of(context)
                .pushNamed(AppRoutes.requestTracking(booking.id)),
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _StatusBadge(status: booking.status),
                ],
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                booking.problemDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.medium),
              Text(
                _scheduleLabel(booking),
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Reference ${booking.bookingReference}',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) => _StatusBadge(status: status);
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = BookingStatusPresentation.color(status);
    final foreground = status == 'SCHEDULED'
        ? AppColors.textPrimary
        : AppColors.surface;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.small,
        vertical: AppSpacing.xSmall,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadii.button),
      ),
      child: Text(
        BookingStatusPresentation.label(status),
        style: Theme.of(context).textTheme.bodySmall
            ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

String _scheduleLabel(Booking booking) {
  final scheduledAt = booking.scheduledAt;
  if (scheduledAt != null) {
    return 'Scheduled ${_formatDate(scheduledAt)} • '
        '${scheduledAt.hour.toString().padLeft(2, '0')}:'
        '${scheduledAt.minute.toString().padLeft(2, '0')}';
  }
  return 'Requested ${_formatDate(booking.preferredDate)} • '
      '${booking.preferredTime}';
}
