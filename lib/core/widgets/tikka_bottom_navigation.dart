import 'package:flutter/material.dart';
import 'package:tikka/app/navigation/customer_destination.dart';
import 'package:tikka/app/theme/app_theme.dart';

class TikkaBottomNavigation extends StatelessWidget {
  const TikkaBottomNavigation({
    super.key,
    required this.selectedDestination,
    required this.onDestinationSelected,
  });

  final CustomerDestination selectedDestination;
  final ValueChanged<CustomerDestination> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadii.navigation),
      ),
      child: Row(
        children: CustomerDestination.values
            .map((destination) {
              final selected = destination == selectedDestination;
              return Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 76),
                    child: Semantics(
                      key: ValueKey<String>('nav_${destination.name}'),
                      button: true,
                      selected: selected,
                      label: destination.label,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(AppRadii.button),
                        onTap: () => onDestinationSelected(destination),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          height: 52,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.brandYellow
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              AppRadii.button,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                destination.icon,
                                size: 18,
                                color: selected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                destination.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.navigationLabel.copyWith(
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  fontVariations: <FontVariation>[
                                    FontVariation('wght', selected ? 600 : 400),
                                    const FontVariation('opsz', 14),
                                  ],
                                  color: selected
                                      ? AppColors.textPrimary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            })
            .toList(growable: false),
      ),
    );
  }
}
