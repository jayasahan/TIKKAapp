import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/core/widgets/tikka_states.dart';
import 'package:tikka/features/services/domain/service.dart';
import 'package:tikka/features/services/domain/service_category.dart';
import 'package:tikka/features/services/domain/services_repository.dart';
import 'package:tikka/features/services/presentation/widgets/service_category_card.dart';
import 'package:tikka/features/services/presentation/widgets/service_item_card.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({
    super.key,
    required this.repository,
    this.initialCategoryId,
  });

  final ServicesRepository repository;
  final String? initialCategoryId;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<ServiceCategory> _categories = <ServiceCategory>[];
  List<Service> _services = <Service>[];
  String? _selectedCategoryId;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {});
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
        _errorMessage = 'Could not load service catalog. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onCategoryTapped(ServiceCategory category) {
    final categoryServices = _services
        .where((s) => s.categoryId == category.id)
        .toList();
    if (categoryServices.length == 1) {
      Navigator.of(context)
          .pushNamed(AppRoutes.serviceDetails(categoryServices.first.id));
      return;
    }

    setState(() {
      _selectedCategoryId = _selectedCategoryId == category.id
          ? null
          : category.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xLarge),
          child: TikkaLoadingState(message: 'Loading services…'),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.large),
          child: TikkaErrorState(
            title: 'Failed to load services',
            message: _errorMessage!,
            onRetry: _loadData,
          ),
        ),
      );
    }

    final searchQuery = _searchController.text.trim().toLowerCase();
    final isSearching = searchQuery.isNotEmpty;

    // Filter services if searching or if category selected
    List<Service> displayedServices = _services;
    if (isSearching) {
      displayedServices = displayedServices.where((s) {
        final nameMatch = s.name.toLowerCase().contains(searchQuery);
        final descMatch = s.description.toLowerCase().contains(searchQuery);
        final jobMatch = s.commonJobs.any(
          (j) => j.toLowerCase().contains(searchQuery),
        );
        return nameMatch || descMatch || jobMatch;
      }).toList();
    } else if (_selectedCategoryId != null) {
      displayedServices = displayedServices
          .where((s) => s.categoryId == _selectedCategoryId)
          .toList();
    }

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
              // Search Input (Figma: "Search services" / "Enter search services")
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search services',
                  hintText: 'Enter search services',
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: isSearching
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                          ),
                          onPressed: () => _searchController.clear(),
                        )
                      : null,
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.input),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadii.input),
                    borderSide: const BorderSide(
                      color: AppColors.brandYellow,
                      width: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.large),

              // When searching, show search results
              if (isSearching) ...<Widget>[
                Text(
                  'Search results (${displayedServices.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.medium),
                if (displayedServices.isEmpty)
                  const TikkaEmptyState(
                    title: 'No services found',
                    message: 'Try searching for another keyword like plumbing, electrical, or cleaning.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedServices.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: AppSpacing.medium),
                    itemBuilder: (context, index) {
                      final service = displayedServices[index];
                      return ServiceItemCard(
                        service: service,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.serviceDetails(service.id)),
                      );
                    },
                  ),
              ] else if (_selectedCategoryId != null) ...<Widget>[
                // Category Filter active view
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      _categories
                          .firstWhere(
                            (c) => c.id == _selectedCategoryId,
                            orElse: () => const ServiceCategory(
                              id: '',
                              slug: '',
                              name: 'Category',
                            ),
                          )
                          .name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () =>
                          setState(() => _selectedCategoryId = null),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Show all'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.medium),
                if (displayedServices.isEmpty)
                  const TikkaEmptyState(
                    title: 'No services in this category',
                    message: 'Services for this category are being updated.',
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: displayedServices.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: AppSpacing.medium),
                    itemBuilder: (context, index) {
                      final service = displayedServices[index];
                      return ServiceItemCard(
                        service: service,
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.serviceDetails(service.id)),
                      );
                    },
                  ),
              ] else ...<Widget>[
                // Default View: Categories Grid (Figma Screen 04: "Choose what you need")
                Text(
                  'Choose what you need',
                  style: Theme.of(context).textTheme.bodySmall
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.medium),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _categories.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.medium,
                    crossAxisSpacing: AppSpacing.medium,
                    childAspectRatio: 1.15,
                  ),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ServiceCategoryCard(
                      category: category,
                      isSelected: _selectedCategoryId == category.id,
                      onTap: () => _onCategoryTapped(category),
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
