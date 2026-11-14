class AuthSessionSnapshot {
  const AuthSessionSnapshot({
    required this.userId,
    required this.email,
    required this.isEmailVerified,
    this.isPasswordRecovery = false,
  });

  final String userId;
  final String? email;
  final bool isEmailVerified;
  final bool isPasswordRecovery;

  bool get isAuthenticated => isEmailVerified && !isPasswordRecovery;
}
