List<String> validatePassword(
    {required String password, String? passwordConfirmation}) {
  List<String> errors = [];

  if (password.isEmpty) {
    errors.add("Password is required.");
    return errors;
  }

  if (password.length < 8) {
    errors.add("Password must be at least 8 characters long.");
  }

  if (!password.contains(RegExp(r'[A-Z]'))) {
    errors.add("Password must contain at least one uppercase letter.");
  }

  if (!password.contains(RegExp(r'[a-z]'))) {
    errors.add("Password must contain at least one lowercase letter.");
  }

  if (!password.contains(RegExp(r'[0-9]'))) {
    errors.add("Password must contain at least one number.");
  }

  if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
    errors.add("Password must contain at least one special character.");
  }

  if (password != passwordConfirmation) {
    errors.add("Password confirmation does not match.");
  }

  return errors;
}
