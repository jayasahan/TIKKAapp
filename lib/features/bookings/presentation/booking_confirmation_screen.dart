import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_app_bar.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';

class BookingConfirmationScreen extends StatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.draft,
    required this.bookingsRepository,
    this.authRepository,
  });

  final BookingDraft draft;
  final BookingsRepository bookingsRepository;
  final AuthRepository? authRepository;

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  bool _isSubmitting = false;
  String? _errorMessage;

  Future<void> _onConfirmRequest() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final customerId =
        widget.authRepository?.currentSnapshot?.userId ?? 'demo-customer-uuid';

    try {
      final booking = await widget.bookingsRepository.createBooking(
        widget.draft,
        customerId: customerId,
      );

      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });

      // Show confirmation dialog then navigate to requests
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.card),
          ),
          title: Row(
            children: const <Widget>[
              Icon(Icons.check_circle, color: AppColors.success, size: 28),
              SizedBox(width: AppSpacing.medium),
              Text('Request Submitted'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Your request for ${booking.serviceName ?? widget.draft.serviceName} has been received.',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: AppSpacing.small),
              Text(
                'Reference: ${booking.bookingReference}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              const Text(
                'Status: NEW (Reviewing)',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                // Navigate to Requests list, clearing booking wizard
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.requests,
                  (route) => route.settings.name == AppRoutes.home,
                );
              },
              child: const Text('View Requests'),
            ),
          ],
        ),
      );
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage =
            'Failed to submit booking: ${e.toString().replaceAll('Exception:', '').trim()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final dateFormatted =
        '${draft.preferredDate.day} ${_monthName(draft.preferredDate.month)} ${draft.preferredDate.year}';

    return Scaffold(
      appBar: TikkaAppBar(
        eyebrow: 'Step 2 of 2',
        title: 'Review request',
        onBackPressed: () => Navigator.of(context).maybePop(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.page,
            vertical: AppSpacing.large,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (_errorMessage != null) ...<Widget>[
                    TikkaErrorState(
                      title: 'Submission failed',
                      message: _errorMessage!,
                      onRetry: _onConfirmRequest,
                    ),
                    const SizedBox(height: AppSpacing.large),
                  ],

                  // Summary Card (Figma Screen 07)
                  Container(
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
                        // Service Name Header
                        Text(
                          draft.serviceName,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const Divider(height: AppSpacing.large),

                        // Job/Problem
                        _SummaryItem(
                          label: 'Job',
                          value: draft.problemDescription,
                        ),
                        const SizedBox(height: AppSpacing.medium),

                        // Address
                        _SummaryItem(
                          label: 'Address',
                          value: draft.serviceAddress,
                        ),
                        const SizedBox(height: AppSpacing.medium),

                        // Date & Time
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _SummaryItem(
                                label: 'Date',
                                value: dateFormatted,
                              ),
                            ),
                            Expanded(
                              child: _SummaryItem(
                                label: 'Time',
                                value: draft.preferredTime,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.medium),

                        // Customer info
                        _SummaryItem(
                          label: 'Customer',
                          value: '${draft.contactName} • ${draft.contactPhone}',
                        ),

                        // Attached Photo
                        if (draft.localPhotoPath != null) ...<Widget>[
                          const SizedBox(height: AppSpacing.medium),
                          _SummaryItem(
                            label: 'Photo',
                            value: '1 photo attached',
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.large),

                  // Notice Card: "Request ready to submit" (matching Figma Screen 07)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.large),
                    decoration: BoxDecoration(
                      color: AppColors.brandYellow,
                      borderRadius: BorderRadius.circular(AppRadii.card),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          '✓ Request ready to submit',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.xSmall),
                        Text(
                          'You can track progress after confirmation.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xLarge),

                  // Action Buttons: Edit and Confirm Request (Figma Screen 07)
                  if (_isSubmitting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.medium),
                        child: TikkaLoadingState(
                          message: 'Submitting your request…',
                        ),
                      ),
                    )
                  else
                    Row(
                      children: <Widget>[
                        // Edit button (pops back to step 1)
                        Expanded(
                          child: TikkaButton(
                            label: 'Edit',
                            style: TikkaButtonStyle.secondary,
                            fullWidth: true,
                            onPressed: () => Navigator.of(context).maybePop(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.medium),

                        // Confirm Request button
                        Expanded(
                          flex: 2,
                          child: TikkaButton(
                            label: 'Confirm Request',
                            fullWidth: true,
                            onPressed: _onConfirmRequest,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = <String>[
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
    ];
    return months[month - 1];
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: AppColors.textSecondary, fontSize: 12),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
