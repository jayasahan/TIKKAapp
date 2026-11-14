class Review {
  const Review({
    required this.id,
    required this.bookingId,
    required this.customerId,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String bookingId;
  final String customerId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      customerId: json['customer_id'] as String,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'booking_id': bookingId,
    'customer_id': customerId,
    'rating': rating,
    'comment': comment,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };
}
