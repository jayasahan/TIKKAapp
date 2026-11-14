import 'package:flutter_test/flutter_test.dart';
import 'package:tikka/features/services/data/supabase_services_repository.dart';

void main() {
  group('SupabaseServicesRepository', () {
    late SupabaseServicesRepository repository;

    setUp(() {
      repository = SupabaseServicesRepository();
    });

    test('getCategories returns 8 confirmed categories', () async {
      final categories = await repository.getCategories();
      expect(categories.length, equals(8));
      expect(
        categories.map((c) => c.slug),
        containsAll(<String>[
          'plumbing',
          'electrical',
          'cleaning',
          'repairs',
          'painting',
          'handyman',
          'gardening',
          'moving',
        ]),
      );
    });

    test('getServices returns all services when unconstrained', () async {
      final services = await repository.getServices();
      expect(services, isNotEmpty);
      expect(services.any((s) => s.slug == 'plumbing-general'), isTrue);
    });

    test('getServices filters by categoryId correctly', () async {
      final categories = await repository.getCategories();
      final plumbingCategory = categories.firstWhere(
        (c) => c.slug == 'plumbing',
      );

      final plumbingServices = await repository.getServices(
        categoryId: plumbingCategory.id,
      );
      expect(plumbingServices, isNotEmpty);
      expect(
        plumbingServices.every((s) => s.categoryId == plumbingCategory.id),
        isTrue,
      );
    });

    test(
      'getServices filters by search query matching name or common jobs',
      () async {
        final searchResults = await repository.getServices(
          searchQuery: 'leaking taps',
        );
        expect(searchResults, isNotEmpty);
        expect(searchResults.first.name, equals('Plumbing'));

        final electricalResults = await repository.getServices(
          searchQuery: 'chandelier',
        );
        expect(electricalResults, isNotEmpty);
        expect(electricalResults.first.name, equals('Electrical'));
      },
    );

    test(
      'getServiceById returns matching service or null if not found',
      () async {
        final service = await repository.getServiceById(
          's2222222-2222-2222-2222-222222222201',
        );
        expect(service, isNotNull);
        expect(service!.name, equals('Plumbing'));

        final notFound = await repository.getServiceById('non-existent-id');
        expect(notFound, isNull);
      },
    );

    test('getServiceBySlug returns matching service', () async {
      final service = await repository.getServiceBySlug('plumbing-general');
      expect(service, isNotNull);
      expect(service!.commonJobs, contains('Leaking taps and pipes'));
    });
  });
}
