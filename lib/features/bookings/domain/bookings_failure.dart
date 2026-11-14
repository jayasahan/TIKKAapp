class BookingsFailure implements Exception {
  const BookingsFailure(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}
