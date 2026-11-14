import 'package:flutter/material.dart';
import 'package:tikka/app/router/app_router.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_session_snapshot.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/services/domain/services_repository.dart';
import 'package:tikka/features/profile/domain/profile_repository.dart';

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    this.authenticationEnabled = false,
    this.authRepository,
    this.servicesRepository,
    this.bookingsRepository,
    this.profileRepository,
    this.configurationMessage,
  });

  final bool authenticationEnabled;
  final AuthRepository? authRepository;
  final ServicesRepository? servicesRepository;
  final BookingsRepository? bookingsRepository;
  final ProfileRepository? profileRepository;
  final String? configurationMessage;

  @override
  Widget build(BuildContext context) {
    if (!authenticationEnabled) {
      return MaterialApp(
        title: 'TIKKA',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.initial,
        onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
          settings,
          servicesRepository: servicesRepository,
          bookingsRepository: bookingsRepository,
          profileRepository: profileRepository,
        ),
        onUnknownRoute: AppRouter.onUnknownRoute,
      );
    }

    return StreamBuilder<AuthSessionSnapshot?>(
      stream: authRepository?.authStateChanges,
      initialData: authRepository?.currentSnapshot,
      builder: (context, streamSnapshot) {
        final session = streamSnapshot.data ?? authRepository?.currentSnapshot;
        final isPasswordRecovery = session?.isPasswordRecovery == true;
        final isAuthenticated = session?.isAuthenticated == true;
        final initialRoute = isPasswordRecovery
            ? AppRoutes.resetPassword
            : isAuthenticated
            ? AppRoutes.home
            : AppRoutes.splash;
        final appKey = isPasswordRecovery
            ? 'password-recovery:${session?.userId ?? ''}'
            : isAuthenticated
            ? 'authenticated:${session?.userId ?? ''}'
            : 'signed-out';

        return MaterialApp(
          key: ValueKey<String>(appKey),
          title: 'TIKKA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          initialRoute: initialRoute,
          onGenerateInitialRoutes: (routeName) => <Route<dynamic>>[
            AppRouter.onGenerateRoute(
              RouteSettings(name: routeName),
              authenticationEnabled: true,
              isAuthenticated: isAuthenticated,
              isPasswordRecovery: isPasswordRecovery,
              authRepository: authRepository,
              servicesRepository: servicesRepository,
              bookingsRepository: bookingsRepository,
              profileRepository: profileRepository,
              configurationMessage: configurationMessage,
            ),
          ],
          onGenerateRoute: (settings) => AppRouter.onGenerateRoute(
            settings,
            authenticationEnabled: true,
            isAuthenticated: isAuthenticated,
            isPasswordRecovery: isPasswordRecovery,
            authRepository: authRepository,
            servicesRepository: servicesRepository,
            bookingsRepository: bookingsRepository,
            profileRepository: profileRepository,
            configurationMessage: configurationMessage,
          ),
          onUnknownRoute: AppRouter.onUnknownRoute,
        );
      },
    );
  }
}
