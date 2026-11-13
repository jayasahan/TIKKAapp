import 'package:tikka/app/navigation/customer_destination.dart';

abstract final class AppRoutes {
  static const initial = home;

  static const splash = '/splash';
  static const login = '/auth/login';
  static const register = '/auth/register';
  static const verifyEmail = '/auth/verify-email';
  static const forgotPassword = '/auth/forgot-password';
  static const resetPassword = '/auth/reset-password';

  static const home = '/home';
  static const services = '/services';
  static const requests = '/requests';
  static const profile = '/profile';
  static const bookingConfirmation = '/bookings/confirm';
  static const editProfile = '/profile/edit';

  static const Set<String> publicRoutes = <String>{
    splash,
    login,
    register,
    verifyEmail,
    forgotPassword,
    resetPassword,
  };

  static String forDestination(CustomerDestination destination) =>
      switch (destination) {
        CustomerDestination.home => home,
        CustomerDestination.services => services,
        CustomerDestination.requests => requests,
        CustomerDestination.profile => profile,
      };

  static String serviceDetails(String serviceId) =>
      '/services/${Uri.encodeComponent(serviceId)}';

  static String createBooking(String serviceId) =>
      '/bookings/new/${Uri.encodeComponent(serviceId)}';

  static String requestTracking(String requestId) =>
      '/requests/${Uri.encodeComponent(requestId)}';

  static String writeReview(String requestId) =>
      '/requests/${Uri.encodeComponent(requestId)}/review';
}
