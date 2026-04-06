class ExceptionHandling {
  final String message;

  const ExceptionHandling([this.message = 'An Unknown error occurred.']);

  factory ExceptionHandling.code(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const ExceptionHandling(
            'The email address is already in use by another account');
      case 'invalid-credential':
        return const ExceptionHandling('Invalid credentials.');
      case 'INVALID_LOGIN_CREDENTIALS':
        return const ExceptionHandling('Invalid credentials.');
      case 'too-many-requests':
        return const ExceptionHandling('Too many attemps.');
      case 'weak-password':
        return const ExceptionHandling('Please enter a stronger password.');
      case 'invalid-email':
        return const ExceptionHandling('Invalid email.');
      case 'email-already-taken':
        return const ExceptionHandling(
            'An account already exist for that email.');
      case 'operation-not-allowed':
        return const ExceptionHandling(
            'Operation is not allowed. Please contact support.');
      case 'user-disabled':
        return const ExceptionHandling(
            'This user is disabled. Please contact support for help');
      case 'user-token-expired':
        return const ExceptionHandling('Code expired');
      case 'second-factor-required':
        return const ExceptionHandling('Second factor authentication required');
      case 'invalid-verification-code':
        return const ExceptionHandling('Invalid Code');  
      case 'requires-recent-login':
        return const ExceptionHandling('Requires a more recent login');
      case 'multi-factor-info-not-found':
        return const ExceptionHandling('Unable to confirm previous MFA info');
      case 'enroll-failed':
        return const ExceptionHandling('Failed to enroll');
      case 'resolve-signin-failed':
        return const ExceptionHandling('Invalid Code');
      default:
        return const ExceptionHandling();
    }
  }
}

