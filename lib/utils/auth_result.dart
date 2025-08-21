class AuthResult {
  final bool success;
  final String? message;
  final bool requires2FA;
  final bool requiresEmailVerification;
  final String? phoneNumber;

  AuthResult({
    required this.success,
    this.message,
    this.requires2FA = false,
    this.requiresEmailVerification = false,
    this.phoneNumber,
  });

  // Convert to Map for backward compatibility
  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'requires2FA': requires2FA,
      'requiresEmailVerification': requiresEmailVerification,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
    };
  }

  // Success factory constructors
  static AuthResult createSuccess({String? message}) {
    return AuthResult(success: true, message: message);
  }

  static AuthResult createSuccessWith2FA({
    required String phoneNumber,
    String? message,
  }) {
    return AuthResult(
      success: true,
      requires2FA: true,
      phoneNumber: phoneNumber,
      message: message,
    );
  }

  static AuthResult createSuccessWithEmailVerification({String? message}) {
    return AuthResult(
      success: false,
      requiresEmailVerification: true,
      message: message,
    );
  }

  // Error factory constructor
  static AuthResult createError(String message) {
    return AuthResult(success: false, message: message);
  }
}
