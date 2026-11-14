abstract final class ReviewValidation {
  static Map<String, String> validate({int? rating, String? comment}) {
    final errors = <String, String>{};
    if (rating == null) {
      errors['rating'] = 'Please select a rating.';
    } else if (rating < 1 || rating > 5) {
      errors['rating'] = 'Rating must be between 1 and 5 stars.';
    }

    return errors;
  }

  static String? normalizedComment(String? comment) {
    final trimmed = comment?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
