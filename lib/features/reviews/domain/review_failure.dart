class ReviewFailure implements Exception {
  const ReviewFailure(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}
