import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:tikka/features/services/data/mock_services_data.dart';
import 'package:tikka/features/services/domain/service.dart';
import 'package:tikka/features/services/domain/service_category.dart';
import 'package:tikka/features/services/domain/services_repository.dart';

class SupabaseServicesRepository implements ServicesRepository {
  SupabaseServicesRepository({this.client});

  final SupabaseClient? client;

  @override
  Future<List<ServiceCategory>> getCategories() async {
    final activeClient = client;
    if (activeClient == null) {
      return MockServicesData.categories;
    }

    try {
      final response = await activeClient
          .from('service_categories')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final list = (response as List<dynamic>)
          .map((item) => ServiceCategory.fromJson(item as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        return MockServicesData.categories;
      }
      return list;
    } on Object {
      return MockServicesData.categories;
    }
  }

  @override
  Future<List<Service>> getServices({
    String? categoryId,
    String? searchQuery,
  }) async {
    final activeClient = client;
    if (activeClient == null) {
      return _filterMockServices(categoryId, searchQuery);
    }

    try {
      var query = activeClient.from('services').select().eq('is_active', true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.eq('category_id', categoryId);
      }

      final response = await query.order('sort_order', ascending: true);
      var list = (response as List<dynamic>)
          .map((item) => Service.fromJson(item as Map<String, dynamic>))
          .toList();

      if (list.isEmpty) {
        list = _filterMockServices(categoryId, null);
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final queryLower = searchQuery.trim().toLowerCase();
        list = list.where((s) {
          final nameMatch = s.name.toLowerCase().contains(queryLower);
          final descMatch = s.description.toLowerCase().contains(queryLower);
          final jobsMatch = s.commonJobs.any(
            (j) => j.toLowerCase().contains(queryLower),
          );
          return nameMatch || descMatch || jobsMatch;
        }).toList();
      }

      return list;
    } on Object {
      return _filterMockServices(categoryId, searchQuery);
    }
  }

  @override
  Future<Service?> getServiceById(String serviceId) async {
    final activeClient = client;
    if (activeClient == null) {
      return _findMockService(serviceId);
    }

    try {
      final response = await activeClient
          .from('services')
          .select()
          .eq('id', serviceId)
          .maybeSingle();

      if (response != null) {
        return Service.fromJson(response);
      }
      return _findMockService(serviceId);
    } on Object {
      return _findMockService(serviceId);
    }
  }

  @override
  Future<Service?> getServiceBySlug(String slug) async {
    final activeClient = client;
    if (activeClient == null) {
      try {
        return MockServicesData.services.firstWhere((s) => s.slug == slug);
      } on StateError {
        return null;
      }
    }

    try {
      final response = await activeClient
          .from('services')
          .select()
          .eq('slug', slug)
          .maybeSingle();

      if (response != null) {
        return Service.fromJson(response);
      }
      return MockServicesData.services.where((s) => s.slug == slug).firstOrNull;
    } on Object {
      return MockServicesData.services.where((s) => s.slug == slug).firstOrNull;
    }
  }

  List<Service> _filterMockServices(String? categoryId, String? searchQuery) {
    var result = MockServicesData.services;
    if (categoryId != null && categoryId.isNotEmpty) {
      result = result.where((s) => s.categoryId == categoryId).toList();
    }
    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      final queryLower = searchQuery.trim().toLowerCase();
      result = result.where((s) {
        final nameMatch = s.name.toLowerCase().contains(queryLower);
        final descMatch = s.description.toLowerCase().contains(queryLower);
        final jobsMatch = s.commonJobs.any(
          (j) => j.toLowerCase().contains(queryLower),
        );
        return nameMatch || descMatch || jobsMatch;
      }).toList();
    }
    return result;
  }

  Service? _findMockService(String serviceIdOrSlug) {
    return MockServicesData.services
        .where((s) => s.id == serviceIdOrSlug || s.slug == serviceIdOrSlug)
        .firstOrNull;
  }
}
