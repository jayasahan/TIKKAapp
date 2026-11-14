class Service {
  const Service({
    required this.id,
    required this.categoryId,
    required this.slug,
    required this.name,
    required this.description,
    this.commonJobs = const <String>[],
    this.basePrice,
    this.currency = 'LKR',
    this.iconName,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String id;
  final String categoryId;
  final String slug;
  final String name;
  final String description;
  final List<String> commonJobs;
  final double? basePrice;
  final String currency;
  final String? iconName;
  final bool isActive;
  final int sortOrder;

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as String,
      categoryId: json['category_id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      commonJobs:
          (json['common_jobs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const <String>[],
      basePrice: (json['base_price'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'LKR',
      iconName: json['icon_name'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category_id': categoryId,
    'slug': slug,
    'name': name,
    'description': description,
    'common_jobs': commonJobs,
    'base_price': basePrice,
    'currency': currency,
    'icon_name': iconName,
    'is_active': isActive,
    'sort_order': sortOrder,
  };
}
