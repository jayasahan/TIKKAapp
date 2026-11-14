import 'package:flutter/material.dart';
import 'package:tikka/app/navigation/app_shell.dart';
import 'package:tikka/app/navigation/customer_destination.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/core/widgets/feature_placeholder.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/presentation/forgot_password_screen.dart';
import 'package:tikka/features/auth/presentation/login_screen.dart';
import 'package:tikka/features/auth/presentation/profile_logout_action.dart';
import 'package:tikka/features/auth/presentation/register_screen.dart';
import 'package:tikka/features/auth/presentation/reset_password_screen.dart';
import 'package:tikka/features/auth/presentation/splash_screen.dart';
import 'package:tikka/features/auth/presentation/verify_email_screen.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(
    RouteSettings settings, {
    bool authenticationEnabled = false,
    bool isAuthenticated = false,
    bool isPasswordRecovery = false,
    AuthRepository? authRepository,
    String? configurationMessage,
  }) {
    final routeName = settings.name ?? AppRoutes.initial;
    final uri = Uri.tryParse(routeName);
    final path = uri?.path ?? '/not-found';

    if (authenticationEnabled) {
      if (isPasswordRecovery && path != AppRoutes.resetPassword) {
        return _authScreen(
          RouteSettings(name: AppRoutes.resetPassword),
          ResetPasswordScreen(
            repository: authRepository,
            configurationMessage: configurationMessage,
          ),
        );
      }
      if (path == AppRoutes.resetPassword && !isPasswordRecovery) {
        return _loginScreen(
          RouteSettings(name: AppRoutes.login),
          authRepository,
          configurationMessage,
        );
      }
      if (!isAuthenticated && !AppRoutes.publicRoutes.contains(path)) {
        return _loginScreen(
          RouteSettings(name: AppRoutes.login),
          authRepository,
          configurationMessage,
        );
      }
      if (isAuthenticated && AppRoutes.publicRoutes.contains(path)) {
        return _shell(
          RouteSettings(name: AppRoutes.home),
          CustomerDestination.home,
        );
      }
    }

    switch (path) {
      case '/':
      case AppRoutes.splash:
        if (authenticationEnabled) {
          return _authScreen(settings, const SplashScreen());
        }
        return _placeholder(
          settings,
          title: 'Welcome to TIKKA',
          message:
              'A welcome screen will be provided with the authentication flow.',
          showAppBar: false,
        );
      case AppRoutes.login:
        if (authenticationEnabled) {
          return _loginScreen(settings, authRepository, configurationMessage);
        }
        return _placeholder(
          settings,
          title: 'Sign in',
          message: 'The sign-in form will be implemented with customer authentication.',
        );
      case AppRoutes.register:
        if (authenticationEnabled) {
          return _authScreen(
            settings,
            RegisterScreen(
              repository: authRepository,
              configurationMessage: configurationMessage,
            ),
          );
        }
        return _placeholder(
          settings,
          title: 'Create account',
          message:
              'Registration will be implemented with customer authentication.',
        );
      case AppRoutes.verifyEmail:
        if (authenticationEnabled) {
          return _authScreen(
            settings,
            VerifyEmailScreen(
              email: settings.arguments is String
                  ? settings.arguments! as String
                  : null,
              repository: authRepository,
              configurationMessage: configurationMessage,
            ),
          );
        }
        return _placeholder(
          settings,
          title: 'Verify email',
          message: 'Email verification guidance will be implemented with authentication.',
        );
      case AppRoutes.forgotPassword:
        if (authenticationEnabled) {
          return _authScreen(
            settings,
            ForgotPasswordScreen(
              repository: authRepository,
              configurationMessage: configurationMessage,
            ),
          );
        }
        return _placeholder(
          settings,
          title: 'Forgot password',
          message: 'Password recovery will be implemented with customer authentication.',
        );
      case AppRoutes.resetPassword:
        if (authenticationEnabled) {
          return _authScreen(
            settings,
            ResetPasswordScreen(
              repository: authRepository,
              configurationMessage: configurationMessage,
            ),
          );
        }
        return _placeholder(
          settings,
          title: 'Reset password',
          message: 'Password reset will be implemented with customer authentication.',
        );
      case AppRoutes.home:
        return _shell(
          settings,
          CustomerDestination.home,
          accountAction: _logoutAction(authenticationEnabled, authRepository),
        );
      case AppRoutes.services:
        return _shell(
          settings,
          CustomerDestination.services,
          accountAction: _logoutAction(authenticationEnabled, authRepository),
        );
      case AppRoutes.requests:
        return _shell(
          settings,
          CustomerDestination.requests,
          accountAction: _logoutAction(authenticationEnabled, authRepository),
        );
      case AppRoutes.profile:
        return _shell(
          settings,
          CustomerDestination.profile,
          accountAction: _logoutAction(authenticationEnabled, authRepository),
        );
      case AppRoutes.bookingConfirmation:
        return _placeholder(
          settings,
          title: 'Booking confirmation',
          message:
              'Booking screens will be added by the booking feature owner.',
        );
      case AppRoutes.editProfile:
        return _placeholder(
          settings,
          title: 'Edit profile',
          message:
              'Profile editing will be added by the profile feature owner.',
        );
    }

    final segments = uri?.pathSegments ?? const <String>[];
    if (segments.length == 2 && segments.first == 'services') {
      return _placeholder(
        settings,
        title: 'Service details',
        message: 'Service details will be added by the services feature owner.',
      );
    }
    if (segments.length == 3 &&
        segments[0] == 'bookings' &&
        segments[1] == 'new') {
      return _placeholder(
        settings,
        title: 'New booking',
        message: 'The booking flow will be added by the booking feature owner.',
      );
    }
    if (segments.length == 3 &&
        segments[0] == 'requests' &&
        segments[2] == 'review') {
      return _placeholder(
        settings,
        title: 'Review a request',
        message:
            'Ratings and reviews will be added by the review feature owner.',
      );
    }
    if (segments.length == 2 && segments.first == 'requests') {
      return _placeholder(
        settings,
        title: 'Request tracking',
        message:
            'Request tracking will be added by the tracking feature owner.',
      );
    }

    return _placeholder(
      settings,
      title: 'Page not found',
      message: 'This route is not part of the TIKKA application.',
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) => _placeholder(
    settings,
    title: 'Page not found',
    message: 'This route is not part of the TIKKA application.',
  );

  static MaterialPageRoute<void> _shell(
    RouteSettings settings,
    CustomerDestination destination, {
    Widget? accountAction,
  }) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) =>
          AppShell(destination: destination, accountAction: accountAction),
    );
  }

  static MaterialPageRoute<void> _loginScreen(
    RouteSettings settings,
    AuthRepository? repository,
    String? configurationMessage,
  ) {
    return _authScreen(
      settings,
      LoginScreen(
        repository: repository,
        configurationMessage: configurationMessage,
      ),
    );
  }

  static MaterialPageRoute<void> _authScreen(
    RouteSettings settings,
    Widget screen,
  ) {
    return MaterialPageRoute<void>(settings: settings, builder: (_) => screen);
  }

  static Widget? _logoutAction(
    bool authenticationEnabled,
    AuthRepository? repository,
  ) {
    if (!authenticationEnabled || repository == null) {
      return null;
    }
    return ProfileLogoutAction(repository: repository);
  }

  static MaterialPageRoute<void> _placeholder(
    RouteSettings settings, {
    required String title,
    required String message,
    bool showAppBar = true,
  }) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => FeaturePlaceholderScreen(
        title: title,
        message: message,
        showAppBar: showAppBar,
      ),
    );
  }
}
