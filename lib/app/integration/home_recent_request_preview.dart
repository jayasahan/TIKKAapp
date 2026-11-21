import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_route_observer.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/bookings_failure.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/bookings/presentation/booking_history_screen.dart';

class HomeRecentRequestPreview extends StatefulWidget {
  const HomeRecentRequestPreview({super.key, required this.repository});

  final BookingsRepository repository;

  @override
  State<HomeRecentRequestPreview> createState() =>
      _HomeRecentRequestPreviewState();
}

class _HomeRecentRequestPreviewState extends State<HomeRecentRequestPreview>
    with RouteAware {
  Booking? _booking;
  bool _isLoading = true;
  String? _error;
  PageRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _loadLatestRequest();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _route) {
      if (_route != null) {
        appRouteObserver.unsubscribe(this);
      }
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    _loadLatestRequest(showLoading: false);
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadLatestRequest({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }
    try {
      final bookings = await widget.repository.getCurrentCustomerBookings();
      if (!mounted) return;
      setState(() {
        _booking = bookings.isEmpty ? null : bookings.first;
        _error = null;
        _isLoading = false;
      });
    } on BookingsFailure catch (failure) {
      if (!mounted) return;
      setState(() {
        _error = failure.userMessage;
        _isLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _error = 'We could not load your latest request.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const TikkaLoadingState(message: 'Loading your latest request…');
    }
    if (_error != null) {
      return TikkaErrorState(message: _error!, onRetry: _loadLatestRequest);
    }

    final booking = _booking;
    if (booking == null) {
      return const TikkaEmptyState(
        title: 'No recent request',
        message: 'Your service requests will appear here.',
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.large),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Recent Request',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              StatusBadge(status: booking.status),
            ],
          ),
          const SizedBox(height: AppSpacing.small),
          Text(
            '${booking.serviceName ?? 'Service'} • #${booking.bookingReference}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${_dateLabel(booking.preferredDate)} • ${booking.preferredTime}',
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.medium),
          InkWell(
            onTap: () =>
                Navigator.of(context)
                    .pushNamed(AppRoutes.requestTracking(booking.id)),
            child: Row(
              children: <Widget>[
                Text(
                  'View request details',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(width: AppSpacing.xSmall),
                const Icon(Icons.arrow_forward, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) =>
      '${date.day} ${_monthName(date.month)} ${date.year}';

  String _monthName(int month) => const <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ][month - 1];
}
