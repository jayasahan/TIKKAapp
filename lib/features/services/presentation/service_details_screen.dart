import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_app_bar.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/services/domain/service.dart';
import 'package:tikka/features/services/domain/service_category.dart';
import 'package:tikka/features/services/domain/services_repository.dart';

class ServiceDetailsScreen extends StatefulWidget {
  const ServiceDetailsScreen({
    super.key,
    required this.serviceId,
    required this.repository,
  });

  final String serviceId;
  final ServicesRepository repository;

  @override
  State<ServiceDetailsScreen> createState() => _ServiceDetailsScreenState();
}

class _ServiceDetailsScreenState extends State<ServiceDetailsScreen> {
  Service? _service;
  ServiceCategory? _category;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadService();
  }

  Future<void> _loadService() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final service = await widget.repository.getServiceById(widget.serviceId);
      ServiceCategory? category;
      if (service != null) {
        final categories = await widget.repository.getCategories();
        category = categories
            .where((c) => c.id == service.categoryId)
            .firstOrNull;
      }

      if (!mounted) return;
      setState(() {
        _service = service;
        _category = category;
        _isLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Could not load service details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        appBar: TikkaAppBar(eyebrow: 'TIKKA', title: 'Service Details'),
        body: Center(child: TikkaLoadingState(message: 'Loading details…')),
      );
    }

    if (_errorMessage != null || _service == null) {
      return Scaffold(
        appBar: const TikkaAppBar(eyebrow: 'TIKKA', title: 'Service Details'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.large),
            child: TikkaEmptyState(
              title: 'Service not found',
              message:
                  _errorMessage ??
                  'The requested service could not be located.',
            ),
          ),
        ),
      );
    }

    final service = _service!;
    final categoryCode =
        _category?.code ??
        (service.name.length >= 2
            ? service.name.substring(0, 2).toUpperCase()
            : 'SR');

    return Scaffold(
      appBar: TikkaAppBar(
        eyebrow: 'TIKKA',
        title: service.name,
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
                  // Category Circular Badge (matching Figma Screen 05)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: AppColors.brandYellow,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      categoryCode,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.medium),

                  // Service Name
                  Text(
                    service.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.small),

                  // Description
                  Text(
                    service.description,
                    style: Theme.of(context).textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: AppSpacing.xLarge),

                  // Common Jobs Card
                  if (service.commonJobs.isNotEmpty) ...<Widget>[
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
                          Text(
                            'Common jobs',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.medium),
                          ...service.commonJobs.map(
                            (job) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.small,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Text(
                                    '• ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      job,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                  ],

                  // Indicative Pricing note if present
                  if (service.basePrice != null) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.medium),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(AppRadii.input),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: AppSpacing.small),
                          Expanded(
                            child: Text(
                              'Standard rate starts around ${service.currency} ${service.basePrice!.toStringAsFixed(0)}. Payment is handled offline after service completion.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xLarge),
                  ],

                  // Action Button (Figma: "Request Service")
                  TikkaButton(
                    label: 'Request Service',
                    fullWidth: true,
                    onPressed: () {
                      Navigator.of(context)
                          .pushNamed(AppRoutes.createBooking(service.id));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
