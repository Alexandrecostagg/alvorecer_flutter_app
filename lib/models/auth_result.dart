class AuthResult {
  final bool success;
  final String message;
  final bool needsCompleteProfile;
  final dynamic user; // pode ser Map ou UserModel

  AuthResult({
    required this.success,
    this.message = '',
    this.needsCompleteProfile = false,
    this.user,
  });
}