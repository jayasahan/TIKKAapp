import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/app/theme/app_theme.dart';
import 'package:tikka/features/bookings/data/supabase_bookings_repository.dart';
import 'package:tikka/features/bookings/domain/booking.dart';
import 'package:tikka/features/bookings/domain/booking_draft.dart';
import 'package:tikka/features/bookings/presentation/booking_status.dart';
import 'package:tikka/features/bookings/presentation/booking_tracking_screen.dart';
import 'package:tikka/features/reviews/domain/review_validation.dart';

void main() {
  group('Phase 10 — Administrative & Backend Security Testing', () {
    late SupabaseBookingsRepository repository;

    setUp(() {
      repository = SupabaseBookingsRepository();
    });

    test('1. Valid Booking Lifecycle State Machine Transitions', () async {
      // 1.1 Customer creates booking (initial status: NEW)
      final draft = BookingDraft(
        serviceId: 'plumbing-general',
        serviceName: 'Plumbing',
        problemDescription: 'Leaking water valve under kitchen sink',
        serviceAddress: 'No. 42, Beach Road, Matara',
        contactName: 'Kasun Herath',
        contactPhone: '+94 77 234 5678',
        preferredDate: DateTime.now().add(const Duration(days: 2)),
        preferredTime: '10:00 AM',
      );

      final initial = await repository.createBooking(
        draft,
        customerId: 'customer-1',
      );
      expect(initial.status, 'NEW');
      expect(initial.isCancellable, isTrue);
      expect(initial.isCompleted, isFalse);

      // 1.2 Admin reviews request (NEW -> REVIEWING)
      final reviewing = await repository.adminAdvanceStatus(
        bookingId: initial.id,
        targetStatus: 'REVIEWING',
        adminNotes: 'Operator verified contact information.',
      );
      expect(reviewing.status, 'REVIEWING');
      expect(reviewing.isCancellable, isTrue);
      expect(reviewing.adminNotes, contains('verified contact'));

      // 1.3 Admin schedules request (REVIEWING -> SCHEDULED)
      final scheduledTime = DateTime.now().add(const Duration(days: 1));
      final scheduled = await repository.adminAdvanceStatus(
        bookingId: initial.id,
        targetStatus: 'SCHEDULED',
        scheduledAt: scheduledTime,
      );
      expect(scheduled.status, 'SCHEDULED');
      expect(
        scheduled.isCancellable,
        isFalse,
      ); // Customer can no longer cancel directly
      expect(scheduled.scheduledAt, isNotNull);

      // 1.4 Admin assigns technician (SCHEDULED -> ASSIGNED)
      final assigned = await repository.adminAdvanceStatus(
        bookingId: initial.id,
        targetStatus: 'ASSIGNED',
        workerName: 'Kamal Perera (Senior Plumber)',
      );
      expect(assigned.status, 'ASSIGNED');
      expect(assigned.assignedWorkerName, 'Kamal Perera (Senior Plumber)');

      // 1.5 Technician starts work (ASSIGNED -> IN_PROGRESS)
      final inProgress = await repository.adminAdvanceStatus(
        bookingId: initial.id,
        targetStatus: 'IN_PROGRESS',
      );
      expect(inProgress.status, 'IN_PROGRESS');

      // 1.6 Technician completes work (IN_PROGRESS -> COMPLETED)
      final completed = await repository.adminAdvanceStatus(
        bookingId: initial.id,
        targetStatus: 'COMPLETED',
      );
      expect(completed.status, 'COMPLETED');
      expect(completed.isCompleted, isTrue);

      // 1.7 Customer confirms completion (COMPLETED -> CONFIRMED)
      final confirmed = await repository.adminAdvanceStatus(
        bookingId: initial.id,
        targetStatus: 'CONFIRMED',
      );
      expect(confirmed.status, 'CONFIRMED');
      expect(confirmed.isCompleted, isTrue);
    });

    test('2. Rejection of Invalid State Transitions', () async {
      final draft = BookingDraft(
        serviceId: 'electrical-general',
        serviceName: 'Electrical',
        problemDescription: 'Power socket spark',
        serviceAddress: 'Galle',
        contactName: 'Nimal',
        contactPhone: '+94 71 123 4567',
        preferredDate: DateTime.now().add(const Duration(days: 1)),
        preferredTime: '02:00 PM',
      );

      final booking = await repository.createBooking(
        draft,
        customerId: 'customer-1',
      );
      expect(booking.status, 'NEW');

      // Direct jump from NEW -> COMPLETED is illegal
      expect(
        () => repository.adminAdvanceStatus(
          bookingId: booking.id,
          targetStatus: 'COMPLETED',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Direct jump from NEW -> IN_PROGRESS is illegal
      expect(
        () => repository.adminAdvanceStatus(
          bookingId: booking.id,
          targetStatus: 'IN_PROGRESS',
        ),
        throwsA(isA<ArgumentError>()),
      );

      // Cancel booking (NEW -> CANCELLED)
      await repository.cancelBooking(booking.id, reason: 'No longer needed');
      final cancelled = await repository.getBookingById(booking.id);
      expect(cancelled!.status, 'CANCELLED');

      // Terminal state CANCELLED cannot transition to IN_PROGRESS or COMPLETED
      expect(
        () => repository.adminAdvanceStatus(
          bookingId: booking.id,
          targetStatus: 'IN_PROGRESS',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      '3. Customer Permission Boundaries (Cancellation & Status Mutation)',
      () async {
        // In NEW state: Customer can cancel
        final bookingNew = Booking(
          id: 'test-new',
          bookingReference: 'TK-9001',
          customerId: 'customer-1',
          serviceId: 'plumbing-general',
          status: 'NEW',
          problemDescription: 'Tap leak',
          serviceAddressSnapshot: 'Matara',
          contactNameSnapshot: 'Kasun',
          contactPhoneSnapshot: '+94771234567',
          preferredDate: DateTime.now(),
          preferredTime: '10:00 AM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(bookingNew.isCancellable, isTrue);

        // In REVIEWING state: Customer can still cancel
        final bookingReviewing = Booking(
          id: 'test-reviewing',
          bookingReference: 'TK-9002',
          customerId: 'customer-1',
          serviceId: 'plumbing-general',
          status: 'REVIEWING',
          problemDescription: 'Tap leak',
          serviceAddressSnapshot: 'Matara',
          contactNameSnapshot: 'Kasun',
          contactPhoneSnapshot: '+94771234567',
          preferredDate: DateTime.now(),
          preferredTime: '10:00 AM',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(bookingReviewing.isCancellable, isTrue);

        // In ASSIGNED, IN_PROGRESS, COMPLETED: Customer CANNOT cancel
        final statusesNotCancellable = <String>[
          'SCHEDULED',
          'ASSIGNED',
          'IN_PROGRESS',
          'COMPLETED',
          'CONFIRMED',
          'CANCELLED',
          'REJECTED',
        ];
        for (final st in statusesNotCancellable) {
          final b = Booking(
            id: 'test-$st',
            bookingReference: 'TK-9003',
            customerId: 'customer-1',
            serviceId: 'plumbing-general',
            status: st,
            problemDescription: 'Problem',
            serviceAddressSnapshot: 'Address',
            contactNameSnapshot: 'Name',
            contactPhoneSnapshot: '+94771234567',
            preferredDate: DateTime.now(),
            preferredTime: '10:00 AM',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          expect(
            b.isCancellable,
            isFalse,
            reason: 'Status $st must not be cancellable by customer',
          );
        }
      },
    );

    test('4. Review Eligibility Matrix', () {
      final eligibleStatuses = <String>['COMPLETED', 'CONFIRMED'];
      final ineligibleStatuses = <String>[
        'NEW',
        'REVIEWING',
        'SCHEDULED',
        'ASSIGNED',
        'IN_PROGRESS',
        'CANCELLED',
        'REJECTED',
      ];

      for (final st in eligibleStatuses) {
        expect(
          BookingStatusPresentation.isCompleted(st),
          isTrue,
          reason: 'Status $st must be eligible for customer reviews',
        );
      }

      for (final st in ineligibleStatuses) {
        expect(
          BookingStatusPresentation.isCompleted(st),
          isFalse,
          reason: 'Status $st must NOT be eligible for customer reviews',
        );
      }

      // Review validator checks
      expect(
        ReviewValidation.validate(rating: 0).containsKey('rating'),
        isTrue,
      );
      expect(
        ReviewValidation.validate(rating: 6).containsKey('rating'),
        isTrue,
      );
      expect(ReviewValidation.validate(rating: 5).isEmpty, isTrue);
      expect(ReviewValidation.validate(rating: 1).isEmpty, isTrue);
    });

    testWidgets(
      '5. Booking Tracking Screen reflects status change and worker assignment',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final booking = Booking(
          id: 'tracking-test-1',
          bookingReference: 'TK-1004',
          customerId: 'customer-1',
          serviceId: 'pipe-drainage-repair',
          serviceName: 'Drainage & Pipe Unclogging',
          status: 'ASSIGNED',
          problemDescription: 'Main bathroom floor drain blocked.',
          serviceAddressSnapshot: 'Faculty Quarters, Matara',
          contactNameSnapshot: 'Prof. Jayawardena',
          contactPhoneSnapshot: '+94 77 567 8901',
          preferredDate: DateTime.now(),
          preferredTime: '11:30 AM',
          assignedWorkerName: 'Kamal Perera',
          scheduledAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final repo = SupabaseBookingsRepository(initialBookings: [booking]);

        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: BookingTrackingScreen(
              bookingId: booking.id,
              repository: repo,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Request tracking'), findsOneWidget);
        expect(find.text('Drainage & Pipe Unclogging'), findsOneWidget);
        expect(find.text('ASSIGNED'), findsWidgets);
        expect(find.text('Assigned worker: Kamal Perera'), findsOneWidget);
        expect(find.text('Review service'), findsNothing); // Not completed yet

        // Now advance status to COMPLETED
        await repo.adminAdvanceStatus(
          bookingId: booking.id,
          targetStatus: 'IN_PROGRESS',
        );
        await repo.adminAdvanceStatus(
          bookingId: booking.id,
          targetStatus: 'COMPLETED',
        );

        // Tap refresh in AppBar
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pumpAndSettle();

        expect(find.text('COMPLETED'), findsWidgets);
        expect(
          find.text('Review service'),
          findsOneWidget,
        ); // Now eligible for review!
      },
    );

    test('6. Zero Privileged Secrets in Flutter Codebase Verification', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final dartFiles = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));

      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        // Assert no service-role secrets are bundled in Flutter application
        expect(
          content.contains('service_role'),
          isFalse,
          reason:
              'File ${file.path} contains forbidden reference to service_role',
        );
        expect(
          content.contains('postgres://'),
          isFalse,
          reason: 'File ${file.path} contains database connection string',
        );
        expect(
          content.contains('SUPABASE_SERVICE_KEY'),
          isFalse,
          reason:
              'File ${file.path} contains reference to SUPABASE_SERVICE_KEY',
        );
      }
    });
  });
}
