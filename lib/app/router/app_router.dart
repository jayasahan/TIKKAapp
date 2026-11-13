import 'package:flutter/material.dart';
import 'package:tikka/app/navigation/app_shell.dart';
import 'package:tikka/app/navigation/customer_destination.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/core/widgets/feature_placeholder.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? AppRoutes.initial;
    final uri = Uri.tryParse(routeName);
    final path = uri?.path ?? '/not-found';

    switch (path) {
      case '/':
      case AppRoutes.splash:
        return _placeholder(
          settings,
          title: 'Welcome to TIKKA',
          message:
              'A welcome screen will be provided with the authentication flow.',
          showAppBar: false,
        );
      case AppRoutes.login:
        return _placeholder(
          settings,
          title: 'Sign in',
          message: 'The sign-in form will be implemented with customer authentication.',
        );
      case AppRoutes.register:
        return _placeholder(
          settings,
          title: 'Create account',
          message:
              'Registration will be implemented with customer authentication.',
        );
      case AppRoutes.verifyEmail:
        return _placeholder(
          settings,
          title: 'Verify email',
          message: 'Email verification guidance will be implemented with authentication.',
        );
      case AppRoutes.forgotPassword:
        return _placeholder(
          settings,
          title: 'Forgot password',
          message: 'Password recovery will be implemented with customer authentication.',
        );
      case AppRoutes.resetPassword:
        return _placeholder(
          settings,
          title: 'Reset password',
          message: 'Password reset will be implemented with customer authentication.',
        );
      case AppRoutes.home:
        return _shell(settings, CustomerDestination.home);
      case AppRoutes.services:
        return _shell(settings, CustomerDestination.services);
      case AppRoutes.requests:
        return _shell(settings, CustomerDestination.requests);
      case AppRoutes.profile:
        return _shell(settings, CustomerDestination.profile);
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
    CustomerDestination destination,
  ) {
    return MaterialPageRoute<void>(
      settings: settings,
      builder: (_) => AppShell(destination: destination),
    );
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
