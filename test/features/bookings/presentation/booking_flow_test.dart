import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/app/app.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/features/bookings/data/supabase_bookings_repository.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/presentation/booking_confirmation_screen.dart';
import 'package:tikka/features/bookings/presentation/booking_form_screen.dart';
import 'package:tikka/features/services/data/supabase_services_repository.dart';

void main() {
  group('Customer Booking Flow', () {
    late SupabaseServicesRepository servicesRepo;
    late SupabaseBookingsRepository bookingsRepo;

    setUp(() {
      servicesRepo = SupabaseServicesRepository();
      bookingsRepo = SupabaseBookingsRepository();
    });

    testWidgets(
      'BookingFormScreen renders step 1 form and validates required input',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingFormScreen(
                serviceId: 'plumbing-general',
                servicesRepository: servicesRepo,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Step 1 of 2'), findsOneWidget);
        expect(find.text('Request Plumbing'), findsOneWidget);
        expect(find.text('Problem / job description'), findsOneWidget);
        expect(find.text('Address'), findsOneWidget);
        expect(find.text('Preferred date'), findsOneWidget);
        expect(find.text('Preferred time'), findsOneWidget);
        expect(find.text('Contact name'), findsOneWidget);
        expect(find.text('Phone number'), findsOneWidget);
        expect(find.text('+ Add photo'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);

        // Try submitting without filling problem description
        await tester.ensureVisible(find.text('Continue'));
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();

        expect(
          find.text('Please enter problem or job details'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'BookingFormScreen allows entering details and toggling photo',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingFormScreen(
                serviceId: 'plumbing-general',
                servicesRepository: servicesRepo,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Enter problem description
        final problemField = find.byType(TextFormField).first;
        await tester.enterText(problemField, 'Kitchen tap leaking water');
        await tester.pumpAndSettle();

        // Tap Add photo button
        await tester.ensureVisible(find.text('+ Add photo'));
        await tester.tap(find.text('+ Add photo'));
        await tester.pumpAndSettle();

        expect(find.text('job_photo_attached.jpg'), findsOneWidget);
      },
    );

    testWidgets(
      'BookingConfirmationScreen renders step 2 summary and confirms request',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final draft = BookingDraft(
          serviceId: 'plumbing-general',
          serviceName: 'Plumbing',
          problemDescription: 'Kitchen pipe burst and dripping',
          serviceAddress: 'No. 45, Beach Road, Matara',
          contactName: 'Kasun Herath',
          contactPhone: '+94 77 123 4567',
          preferredDate: DateTime(2026, 12, 10),
          preferredTime: '10:00 AM',
          localPhotoPath: 'leak.jpg',
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BookingConfirmationScreen(
                draft: draft,
                bookingsRepository: bookingsRepo,
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Step 2 of 2'), findsOneWidget);
        expect(find.text('Review request'), findsOneWidget);
        expect(find.text('✓ Request ready to submit'), findsOneWidget);
        expect(find.text('Plumbing'), findsOneWidget);
        expect(find.text('Kitchen pipe burst and dripping'), findsOneWidget);
        expect(find.text('No. 45, Beach Road, Matara'), findsOneWidget);
        expect(find.text('Kasun Herath • +94 77 123 4567'), findsOneWidget);
        expect(find.text('10:00 AM'), findsOneWidget);
        expect(find.text('1 photo attached'), findsOneWidget);
        expect(find.text('Edit'), findsOneWidget);
        expect(find.text('Confirm Request'), findsOneWidget);

        // Tap Confirm Request
        await tester.ensureVisible(find.text('Confirm Request'));
        await tester.tap(find.text('Confirm Request'));
        await tester.pump(); // Start async submit
        await tester.pumpAndSettle(); // Settle dialog

        // Verify confirmation dialog
        expect(find.text('Request Submitted'), findsOneWidget);
        expect(
          find.textContaining('Your request for Plumbing has been received'),
          findsOneWidget,
        );
        expect(find.textContaining('Reference: TK-'), findsOneWidget);
        expect(find.text('Status: NEW (Reviewing)'), findsOneWidget);
        expect(find.text('View Requests'), findsOneWidget);
      },
    );

    testWidgets('End-to-end booking navigation via AppRouter', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        MyApp(
          servicesRepository: servicesRepo,
          bookingsRepository: bookingsRepo,
        ),
      );

      await tester.pumpAndSettle();

      // Navigate to booking form
      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      navigator.pushNamed(AppRoutes.createBooking('plumbing-general'));
      await tester.pumpAndSettle();

      expect(find.text('Request Plumbing'), findsOneWidget);

      // Fill required fields
      final fields = find.byType(TextFormField);
      await tester.enterText(
        fields.at(0),
        'Water pressure too low in bathroom',
      );
      await tester.enterText(fields.at(1), '123 Galle Road, Matara');
      await tester.enterText(fields.at(2), 'Amara Silva');
      await tester.enterText(fields.at(3), '+94 77 987 6543');
      await tester.pumpAndSettle();

      // Tap Continue to Step 2
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Review request'), findsOneWidget);
      expect(find.text('Water pressure too low in bathroom'), findsOneWidget);

      // Tap Edit to go back to Step 1
      await tester.ensureVisible(find.text('Edit'));
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('Request Plumbing'), findsOneWidget);

      // Tap Continue again
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Tap Confirm Request
      await tester.ensureVisible(find.text('Confirm Request'));
      await tester.tap(find.text('Confirm Request'));
      await tester.pumpAndSettle();

      expect(find.text('Request Submitted'), findsOneWidget);

      // Tap View Requests in dialog
      await tester.tap(find.text('View Requests'));
      await tester.pumpAndSettle();

      expect(find.text('Requests'), findsWidgets);
    });
  });
}
