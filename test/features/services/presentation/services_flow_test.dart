import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/app/app.dart';
import 'package:tikka/app/router/app_routes.dart';
import 'package:tikka/features/services/data/supabase_services_repository.dart';
import 'package:tikka/features/services/presentation/home_screen.dart';
import 'package:tikka/features/services/presentation/service_details_screen.dart';
import 'package:tikka/features/services/presentation/services_screen.dart';

void main() {
  group('Services Presentation Flow', () {
    late SupabaseServicesRepository repository;

    setUp(() {
      repository = SupabaseServicesRepository();
    });

    testWidgets(
      'HomeScreen renders greeting, hero card, and featured services',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: HomeScreen(
                repository: repository,
                customerName: 'Jayasahan',
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Good day, Jayasahan'), findsOneWidget);
        expect(find.text('Ready to get something done?'), findsOneWidget);
        expect(find.text('Home services without the hassle'), findsOneWidget);
        expect(find.text('Request a Service'), findsOneWidget);
        expect(find.text('Services'), findsOneWidget);
        expect(find.text('Plumbing'), findsWidgets);
        expect(find.text('Recent Request'), findsOneWidget);
      },
    );

    testWidgets('ServicesScreen renders category grid and searches services', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: ServicesScreen(repository: repository)),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Search services'), findsOneWidget);
      expect(find.text('Choose what you need'), findsOneWidget);
      expect(find.text('Plumbing'), findsOneWidget);
      expect(find.text('Electrical'), findsOneWidget);
      expect(find.text('Cleaning'), findsOneWidget);

      // Search for "plumbing"
      await tester.enterText(find.byType(TextField), 'drain');
      await tester.pumpAndSettle();

      expect(find.textContaining('Search results'), findsOneWidget);
      expect(find.text('Drainage & Pipe Unclogging'), findsOneWidget);

      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      expect(find.text('Choose what you need'), findsOneWidget);
    });

    testWidgets('ServiceDetailsScreen renders service jobs and request CTA', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          onGenerateRoute: (settings) {
            if (settings.name ==
                AppRoutes.createBooking(
                  's2222222-2222-2222-2222-222222222201',
                )) {
              return MaterialPageRoute<void>(
                builder: (_) =>
                    const Scaffold(body: Text('New Booking Destination')),
              );
            }
            return null;
          },
          home: ServiceDetailsScreen(
            serviceId: 's2222222-2222-2222-2222-222222222201',
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Plumbing'), findsWidgets);
      expect(find.text('PL'), findsOneWidget);
      expect(find.text('Common jobs'), findsOneWidget);
      expect(find.text('Leaking taps and pipes'), findsOneWidget);
      expect(find.text('Blocked sinks and drains'), findsOneWidget);
      expect(find.text('Request Service'), findsOneWidget);

      // Tap Request Service
      await tester.tap(find.text('Request Service'));
      await tester.pumpAndSettle();

      expect(find.text('New Booking Destination'), findsOneWidget);
    });

    testWidgets(
      'Navigation from Home to Services to Service Details works in MyApp',
      (WidgetTester tester) async {
        await tester.pumpWidget(MyApp(servicesRepository: repository));

        await tester.pumpAndSettle();

        // Tap Request a Service hero CTA
        await tester.tap(find.text('Request a Service'));
        await tester.pumpAndSettle();

        // On Services screen
        expect(find.text('Choose what you need'), findsOneWidget);

        // Tap Plumbing category card (shows category filter view)
        await tester.tap(find.text('Plumbing').first);
        await tester.pumpAndSettle();

        expect(find.text('Drainage & Pipe Unclogging'), findsOneWidget);

        // Tap Plumbing service item
        await tester.tap(find.text('Plumbing').last);
        await tester.pumpAndSettle();

        // Now on Plumbing Service Details screen
        expect(find.text('Common jobs'), findsOneWidget);
        expect(find.text('Request Service'), findsOneWidget);
      },
    );
  });
}
