import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/app/app.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/features/auth/domain/auth_repository.dart';
import 'package:tikka/features/auth/domain/auth_session_snapshot.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/domain/bookings_repository.dart';
import 'package:tikka/features/bookings/presentation/booking_confirmation_screen.dart';
import 'package:tikka/features/profile/domain/customer_profile.dart';
import 'package:tikka/features/profile/domain/profile_repository.dart';
import 'package:tikka/features/reviews/domain/review.dart';
import 'package:tikka/features/reviews/domain/reviews_repository.dart';
import 'package:tikka/features/services/data/supabase_services_repository.dart';

void main() {
  testWidgets(
    'signed-in customer can book, track, review, edit profile, and log out',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final authRepository = _FakeAuthRepository();
      final bookingsRepository = _FakeBookingsRepository();
      final profileRepository = _FakeProfileRepository(
        CustomerProfile(
          id: _customerId,
          fullName: 'Integration Customer',
          phoneNumber: '+94771234567',
          savedAddress: '12 Main Street, Matara',
        ),
      );
      final reviewsRepository = _FakeReviewsRepository();
      addTearDown(authRepository.dispose);

      await tester.pumpWidget(
        MyApp(
          authenticationEnabled: true,
          authRepository: authRepository,
          servicesRepository: SupabaseServicesRepository(),
          bookingsRepository: bookingsRepository,
          profileRepository: profileRepository,
          reviewsRepository: reviewsRepository,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Good day, integration.customer'), findsOneWidget);
      expect(find.text('No recent request'), findsOneWidget);

      await tester.tap(find.text('Request a Service'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plumbing').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Drainage & Pipe Unclogging'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Request Service'));
      await tester.pumpAndSettle();

      expect(find.text('Request Drainage & Pipe Unclogging'), findsOneWidget);
      final formFields = find.byType(TextFormField);
      await tester.enterText(formFields.at(0), 'Leaking kitchen pipe');
      await tester.enterText(formFields.at(1), '12 Main Street, Matara');
      await tester.enterText(formFields.at(2), 'Integration Customer');
      await tester.enterText(formFields.at(3), '+94 77 123 4567');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Review request'), findsOneWidget);
      await tester.ensureVisible(find.text('Confirm Request'));
      await tester.tap(find.text('Confirm Request'));
      await tester.pumpAndSettle();
      expect(find.text('Request Submitted'), findsOneWidget);
      expect(bookingsRepository.createdCustomerId, _customerId);
      expect(bookingsRepository.latestBooking?.status, 'NEW');

      await tester.tap(find.text('View Requests'));
      await tester.pumpAndSettle();
      expect(find.text('Leaking kitchen pipe'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey<String>('nav_home')));
      await tester.pumpAndSettle();
      expect(find.textContaining('TK-2042'), findsOneWidget);
      expect(find.text('NEW'), findsOneWidget);
      await tester.tap(find.text('View request details'));
      await tester.pumpAndSettle();
      expect(find.text('Request tracking'), findsOneWidget);
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      bookingsRepository.completeLatestBooking();
      navigator.pop();
      await tester.pumpAndSettle();
      expect(find.text('COMPLETED'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('nav_requests')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Completed'));
      await tester.pumpAndSettle();
      expect(find.text('Leaking kitchen pipe'), findsOneWidget);

      await tester.tap(find.text('Leaking kitchen pipe'));
      await tester.pumpAndSettle();
      expect(find.text('Request tracking'), findsOneWidget);
      expect(find.text('COMPLETED'), findsWidgets);
      await tester.ensureVisible(find.text('Review service'));
      await tester.tap(find.text('Review service'));
      await tester.pumpAndSettle();
      expect(find.text('How was your service?'), findsOneWidget);

      await tester.tap(find.byTooltip('5 stars'));
      await tester.enterText(find.byType(TextField), 'Great work');
      await tester.tap(find.text('Submit review'));
      await tester.pumpAndSettle();
      expect(find.text('Review submitted'), findsOneWidget);
      expect(reviewsRepository.submittedBookingId, 'booking-42');
      expect(reviewsRepository.submittedCustomerId, _customerId);

      navigator.pop();
      await tester.pumpAndSettle();
      navigator.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('nav_profile')));
      await tester.pumpAndSettle();

      expect(find.text('Integration Customer'), findsOneWidget);
      await tester.tap(find.text('Edit Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Edit profile'), findsOneWidget);
      await tester.ensureVisible(find.text('Save changes'));
      await tester.tap(find.text('Save changes'));
      await tester.pumpAndSettle();
      expect(profileRepository.lastUpdatedCustomerId, _customerId);

      await tester.ensureVisible(find.text('Log out'));
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(authRepository.signOutCalled, isTrue);
      expect(find.text('TIKKA'), findsOneWidget);
      expect(find.text('Get it done.'), findsOneWidget);
    },
  );

  testWidgets('signed-out deep links are redirected to sign in', (
    WidgetTester tester,
  ) async {
    final authRepository = _FakeAuthRepository(signedIn: false);
    addTearDown(authRepository.dispose);

    await tester.pumpWidget(
      MyApp(
        authenticationEnabled: true,
        authRepository: authRepository,
        servicesRepository: SupabaseServicesRepository(),
        bookingsRepository: _FakeBookingsRepository(),
      ),
    );
    await tester.pumpAndSettle();

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.pushNamed<void>(AppRoutes.requests);
    await tester.pumpAndSettle();

    expect(find.text('Welcome to TIKKA'), findsOneWidget);
    expect(find.text('Choose what you need'), findsNothing);
  });

  testWidgets('booking submission stops when the customer session expires', (
    WidgetTester tester,
  ) async {
    final authRepository = _FakeAuthRepository(signedIn: false);
    final bookingsRepository = _FakeBookingsRepository();
    addTearDown(authRepository.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: BookingConfirmationScreen(
          draft: BookingDraft(
            serviceId: 'service-1',
            serviceName: 'Plumbing',
            problemDescription: 'Leaking tap',
            serviceAddress: '12 Main Street',
            contactName: 'Integration Customer',
            contactPhone: '+94771234567',
            preferredDate: DateTime(2026, 12, 1),
            preferredTime: '10:00 AM',
          ),
          bookingsRepository: bookingsRepository,
          authRepository: authRepository,
        ),
      ),
    );

    await tester.tap(find.text('Confirm Request'));
    await tester.pumpAndSettle();

    expect(
      find.text('Your session has expired. Please sign in again.'),
      findsOneWidget,
    );
    expect(bookingsRepository.createdCustomerId, isNull);
    expect(bookingsRepository.latestBooking, isNull);
  });
}

const _customerId = 'auth-customer-42';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({bool signedIn = true})
    : _currentSnapshot = signedIn
          ? const AuthSessionSnapshot(
              userId: _customerId,
              email: 'integration.customer@example.com',
              isEmailVerified: true,
            )
          : null;

  final StreamController<AuthSessionSnapshot?> _events =
      StreamController<AuthSessionSnapshot?>.broadcast(sync: true);
  AuthSessionSnapshot? _currentSnapshot;
  bool signOutCalled = false;

  @override
  AuthSessionSnapshot? get currentSnapshot => _currentSnapshot;

  @override
  Stream<AuthSessionSnapshot?> get authStateChanges => _events.stream;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<bool> signUp({
    required String fullName,
    required String email,
    required String phoneNumber,
    required String password,
  }) async => true;

  @override
  Future<void> resendSignupVerification(String email) async {}

  @override
  Future<void> requestPasswordRecovery(String email) async {}

  @override
  Future<void> updatePassword(String password) async {}

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    _currentSnapshot = null;
    _events.add(null);
  }

  Future<void> dispose() => _events.close();
}

class _FakeBookingsRepository implements BookingsRepository {
  final List<Booking> _bookings = <Booking>[];
  String? createdCustomerId;

  Booking? get latestBooking => _bookings.isEmpty ? null : _bookings.first;

  void completeLatestBooking() {
    final booking = latestBooking!;
    _bookings[0] = _copyBooking(booking, status: 'COMPLETED');
  }

  @override
  Future<Booking> createBooking(
    BookingDraft draft, {
    required String customerId,
  }) async {
    createdCustomerId = customerId;
    final booking = Booking(
      id: 'booking-42',
      bookingReference: 'TK-2042',
      customerId: customerId,
      serviceId: draft.serviceId,
      serviceName: draft.serviceName,
      status: 'NEW',
      problemDescription: draft.problemDescription,
      serviceAddressSnapshot: draft.serviceAddress,
      contactNameSnapshot: draft.contactName,
      contactPhoneSnapshot: draft.contactPhone,
      preferredDate: draft.preferredDate,
      preferredTime: draft.preferredTime,
      createdAt: DateTime(2026, 11, 15),
      updatedAt: DateTime(2026, 11, 15),
    );
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<List<Booking>> getCustomerBookings(String customerId) async =>
      _bookings.where((booking) => booking.customerId == customerId).toList();

  @override
  Future<Booking?> getBookingById(String bookingId) async =>
      _bookings.where((booking) => booking.id == bookingId).firstOrNull;

  @override
  Future<List<Booking>> getCurrentCustomerBookings() async =>
      _bookings.where((booking) => booking.customerId == _customerId).toList();

  @override
  Future<Booking?> getCurrentCustomerBookingById(String bookingId) async =>
      _bookings
          .where(
            (booking) =>
                booking.id == bookingId && booking.customerId == _customerId,
          )
          .firstOrNull;

  @override
  Future<void> cancelBooking(String bookingId, {String? reason}) async {}
}

class _FakeProfileRepository implements ProfileRepository {
  _FakeProfileRepository(this.profile);

  CustomerProfile profile;
  String? lastUpdatedCustomerId;

  @override
  Future<CustomerProfile> getCurrentProfile() async => profile;

  @override
  Future<CustomerProfile> updateCurrentProfile({
    required String fullName,
    String? phoneNumber,
    String? savedAddress,
  }) async {
    lastUpdatedCustomerId = profile.id;
    profile = profile.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      savedAddress: savedAddress,
    );
    return profile;
  }
}

class _FakeReviewsRepository implements ReviewsRepository {
  String? submittedBookingId;
  String? submittedCustomerId;

  @override
  Future<Review?> getReviewForBooking(String bookingId) async => null;

  @override
  Future<Review> submitReview({
    required String bookingId,
    required int rating,
    String? comment,
  }) async {
    submittedBookingId = bookingId;
    submittedCustomerId = _customerId;
    return Review(
      id: 'review-42',
      bookingId: bookingId,
      customerId: _customerId,
      rating: rating,
      comment: comment,
      createdAt: DateTime(2026, 11, 15),
    );
  }
}

Booking _copyBooking(Booking booking, {required String status}) => Booking(
  id: booking.id,
  bookingReference: booking.bookingReference,
  customerId: booking.customerId,
  serviceId: booking.serviceId,
  serviceName: booking.serviceName,
  status: status,
  problemDescription: booking.problemDescription,
  serviceAddressSnapshot: booking.serviceAddressSnapshot,
  contactNameSnapshot: booking.contactNameSnapshot,
  contactPhoneSnapshot: booking.contactPhoneSnapshot,
  preferredDate: booking.preferredDate,
  preferredTime: booking.preferredTime,
  photoStoragePath: booking.photoStoragePath,
  assignedWorkerName: booking.assignedWorkerName,
  scheduledAt: booking.scheduledAt,
  cancellationReason: booking.cancellationReason,
  rejectionReason: booking.rejectionReason,
  adminNotes: booking.adminNotes,
  createdAt: booking.createdAt,
  updatedAt: DateTime(2026, 11, 15),
);
