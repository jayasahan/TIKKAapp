import 'package:flutter/material.dart';
import 'package:tikka/app/theme/app_theme.dart';

abstract final class BookingStatusPresentation {
  static const lifecycle = <String>[
    'NEW',
    'REVIEWING',
    'SCHEDULED',
    'ASSIGNED',
    'IN_PROGRESS',
    'COMPLETED',
    'CONFIRMED',
  ];

  static String label(String status) => switch (status) {
    'IN_PROGRESS' => 'IN PROGRESS',
    _ => status,
  };

  static Color color(String status) => switch (status) {
    'NEW' => AppColors.info,
    'REVIEWING' => AppColors.warning,
    'SCHEDULED' => AppColors.brandYellow,
    'ASSIGNED' => AppColors.info,
    'IN_PROGRESS' => AppColors.warning,
    'COMPLETED' || 'CONFIRMED' => AppColors.success,
    'CANCELLED' || 'REJECTED' => AppColors.error,
    _ => AppColors.textSecondary,
  };

  static bool isCompleted(String status) =>
      status == 'COMPLETED' || status == 'CONFIRMED';

  static bool isCancelled(String status) =>
      status == 'CANCELLED' || status == 'REJECTED';
}
