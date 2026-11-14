class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
    this.iconName,
    this.sortOrder = 0,
    this.isActive = true,
    this.categoryCode,
  });

  final String id;
  final String slug;
  final String name;
  final String? description;
  final String? iconName;
  final int sortOrder;
  final bool isActive;
  final String? categoryCode;

  /// Two-letter category code used for badges in Figma (e.g. PL, EL, CL).
  String get code {
    if (categoryCode != null && categoryCode!.isNotEmpty) {
      return categoryCode!;
    }
    return switch (slug) {
      'plumbing' => 'PL',
      'electrical' => 'EL',
      'cleaning' => 'CL',
      'repairs' => 'RP',
      'painting' => 'PT',
      'handyman' => 'HM',
      'gardening' => 'GD',
      'moving' => 'MV',
      _ =>
        name.length >= 2
            ? name.substring(0, 2).toUpperCase()
            : name.toUpperCase(),
    };
  }

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] as String,
      slug: json['slug'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      categoryCode: json['category_code'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'slug': slug,
    'name': name,
    'description': description,
    'icon_name': iconName,
    'sort_order': sortOrder,
    'is_active': isActive,
    'category_code': categoryCode,
  };
}
