class ProfileFailure implements Exception {
  const ProfileFailure(this.userMessage);

  final String userMessage;

  @override
  String toString() => userMessage;
}
