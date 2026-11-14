import 'package:tikka/features/services/domain/service.dart';
import 'package:tikka/features/services/domain/service_category.dart';

abstract interface class ServicesRepository {
  Future<List<ServiceCategory>> getCategories();

  Future<List<Service>> getServices({String? categoryId, String? searchQuery});

  Future<Service?> getServiceById(String serviceId);

  Future<Service?> getServiceBySlug(String slug);
}
