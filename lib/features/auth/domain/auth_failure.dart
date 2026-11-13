class AuthFailure implements Exception {
  const AuthFailure(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}
