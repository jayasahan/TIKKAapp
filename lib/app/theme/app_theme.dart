import 'package:flutter/material.dart';

abstract final class AppColors {
  static const brandYellow = Color(0xFFFCE314);
  static const textPrimary = Color(0xFF000000);
  static const textSecondary = Color(0xFF777770);
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF7F7F5);
  static const border = Color(0xFFD4D4D0);
  static const success = Color(0xFF17803D);
  static const warning = Color(0xFFB85C00);
  static const error = Color(0xFFC92A2A);
  static const info = Color(0xFF1F66D1);
  static const disabledButton = Color(0xFFEFEFED);
  static const disabledField = Color(0xFFF1F1EF);
}

abstract final class AppSpacing {
  static const xSmall = 4.0;
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const page = 20.0;
  static const xLarge = 24.0;
}

abstract final class AppRadii {
  static const input = 12.0;
  static const button = 14.0;
  static const card = 16.0;
  static const navigation = 20.0;
}

abstract final class AppTheme {
  static const _fontFamily = 'Inter';
  static const _display = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    height: 44 / 36,
    fontWeight: FontWeight.w700,
    fontVariations: <FontVariation>[
      FontVariation('wght', 700),
      FontVariation('opsz', 32),
    ],
  );
  static const _heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    fontVariations: <FontVariation>[
      FontVariation('wght', 700),
      FontVariation('opsz', 28),
    ],
  );
  static const _heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    height: 30 / 22,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[
      FontVariation('wght', 600),
      FontVariation('opsz', 22),
    ],
  );
  static const _heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    height: 26 / 18,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[
      FontVariation('wght', 600),
      FontVariation('opsz', 18),
    ],
  );
  static const _body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[
      FontVariation('wght', 400),
      FontVariation('opsz', 16),
    ],
  );
  static const _bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[
      FontVariation('wght', 400),
      FontVariation('opsz', 14),
    ],
  );
  static const _label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    fontVariations: <FontVariation>[
      FontVariation('wght', 500),
      FontVariation('opsz', 14),
    ],
  );
  static const _caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[
      FontVariation('wght', 400),
      FontVariation('opsz', 14),
    ],
  );
  static const buttonLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontVariations: <FontVariation>[
      FontVariation('wght', 600),
      FontVariation('opsz', 14),
    ],
  );
  static const stateLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w500,
    fontVariations: <FontVariation>[
      FontVariation('wght', 500),
      FontVariation('opsz', 14),
    ],
  );
  static const navigationLabel = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    height: 12 / 10,
    fontWeight: FontWeight.w400,
    fontVariations: <FontVariation>[
      FontVariation('wght', 400),
      FontVariation('opsz', 14),
    ],
  );
  static const textTheme = TextTheme(
    displayLarge: _display,
    headlineLarge: _heading1,
    headlineMedium: _heading2,
    headlineSmall: _heading3,
    bodyLarge: _body,
    bodyMedium: _bodySmall,
    bodySmall: _caption,
    labelLarge: _label,
  );

  static ThemeData get light {
    const inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadii.input)),
      borderSide: BorderSide(color: AppColors.border),
    );
    return ThemeData(
      useMaterial3: true,
      fontFamily: _fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandYellow,
        onPrimary: AppColors.textPrimary,
        secondary: AppColors.success,
        onSecondary: AppColors.surface,
        error: AppColors.error,
        onError: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        outline: AppColors.border,
      ),
      scaffoldBackgroundColor: AppColors.background,
      dividerColor: AppColors.border,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        toolbarHeight: 60,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        labelStyle: _caption,
        hintStyle: _bodySmall,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.input)),
          borderSide: BorderSide(color: AppColors.textPrimary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.input)),
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.input)),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: inputBorder,
      ),
    );
  }
}
