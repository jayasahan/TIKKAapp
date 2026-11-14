import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_button.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/services/domain/service.dart';
import 'package:tikka/features/services/domain/service_category.dart';
import 'package:tikka/features/services/domain/services_repository.dart';
import 'package:tikka/features/services/presentation/widgets/service_category_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository, this.customerName});

  final ServicesRepository repository;
  final String? customerName;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ServiceCategory> _categories = <ServiceCategory>[];
  List<Service> _services = <Service>[];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categories = await widget.repository.getCategories();
      final services = await widget.repository.getServices();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _services = services;
        _isLoading = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xLarge),
          child: TikkaLoadingState(message: 'Loading home…'),
        ),
      );
    }

    final greetingName =
        widget.customerName != null && widget.customerName!.isNotEmpty
        ? widget.customerName!
        : 'Customer';

    // Featured 4 categories on Home (Figma: Cleaning, Electrical, Plumbing, Repairs)
    final featuredSlugs = <String>{
      'cleaning',
      'electrical',
      'plumbing',
      'repairs',
    };
    final featuredCategories = _categories
        .where((c) => featuredSlugs.contains(c.slug.toLowerCase()))
        .toList();

    final categoriesToDisplay = featuredCategories.isNotEmpty
        ? featuredCategories
        : _categories.take(4).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.large,
        vertical: AppSpacing.medium,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Greeting (Figma: "Good day, [Name]" / "Ready to get something done?")
              Text(
                'Good day, $greetingName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xSmall),
              Text(
                'Ready to get something done?',
                style: Theme.of(context).textTheme.bodySmall
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.large),

              // Hero Card (matching Figma Screen 03)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xLarge),
                decoration: BoxDecoration(
                  color: AppColors.textPrimary,
                  borderRadius: BorderRadius.circular(AppRadii.card),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Home services without the hassle',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.surface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      "Tell us what you need. We'll organize the rest.",
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: const Color(0xFFD4D4D0)),
                    ),
                    const SizedBox(height: AppSpacing.large),
                    TikkaButton(
                      label: 'Request a Service',
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.services);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xLarge),

              // Services Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Services',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.services);
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                    ),
                    child: const Text('View all'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.small),

              // 2x2 Featured Category Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categoriesToDisplay.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.medium,
                  crossAxisSpacing: AppSpacing.medium,
                  childAspectRatio: 1.15,
                ),
                itemBuilder: (context, index) {
                  final category = categoriesToDisplay[index];
                  return ServiceCategoryCard(
                    category: category,
                    onTap: () {
                      final matchingServices = _services
                          .where((s) => s.categoryId == category.id)
                          .toList();
                      if (matchingServices.length == 1) {
                        Navigator.of(context).pushNamed(
                          AppRoutes.serviceDetails(matchingServices.first.id),
                        );
                      } else {
                        Navigator.of(context).pushNamed(AppRoutes.services);
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xLarge),

              // Active Request Preview Card (matching Figma Screen 03)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Recent Request',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.small,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.brandYellow,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SCHEDULED',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.small),
                    Text(
                      'Plumbing • #TK-1042',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '12 Oct • 10:00 AM',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.medium),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.requests);
                      },
                      child: Row(
                        children: <Widget>[
                          Text(
                            'View request details',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
