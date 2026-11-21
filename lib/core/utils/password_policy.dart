import '../config/language/language_manager.dart';

/// The single definition of the backend's password rules.
///
/// A password must contain:
///  * at least 8 characters
///  * one uppercase letter
///  * one lowercase letter
///  * one number
///  * one special character
///
/// Every screen that accepts a new password (registration, change password,
/// reset password) validates through this class so the rules can never drift
/// apart between screens.
class PasswordPolicy {
  const PasswordPolicy._();

  static const int minLength = 8;

  static bool hasMinLength(String value) => value.length >= minLength;

  static bool hasUppercase(String value) => RegExp(r'[A-Z]').hasMatch(value);

  static bool hasLowercase(String value) => RegExp(r'[a-z]').hasMatch(value);

  static bool hasNumber(String value) => RegExp(r'[0-9]').hasMatch(value);

  static bool hasSpecialCharacter(String value) =>
      RegExp(r'[^A-Za-z0-9]').hasMatch(value);

  static bool isValid(String value) =>
      hasMinLength(value) &&
      hasUppercase(value) &&
      hasLowercase(value) &&
      hasNumber(value) &&
      hasSpecialCharacter(value);

  /// Returns the first unmet requirement as a localized message, or `null`
  /// when [value] satisfies every rule.
  static String? validate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password'.tran;
    }
    if (!hasMinLength(value)) {
      return 'Password must be at least 8 characters'.tran;
    }
    if (!hasUppercase(value)) {
      return 'Password must contain an uppercase letter'.tran;
    }
    if (!hasLowercase(value)) {
      return 'Password must contain a lowercase letter'.tran;
    }
    if (!hasNumber(value)) {
      return 'Password must contain a number'.tran;
    }
    if (!hasSpecialCharacter(value)) {
      return 'Password must contain a special character'.tran;
    }
    return null;
  }

  /// The checklist shown under the password field.
  static List<PasswordRequirement> requirements(String value) => [
    PasswordRequirement('At least 8 characters'.tran, hasMinLength(value)),
    PasswordRequirement('At least one uppercase'.tran, hasUppercase(value)),
    PasswordRequirement('At least one lowercase'.tran, hasLowercase(value)),
    PasswordRequirement('At least one number'.tran, hasNumber(value)),
    PasswordRequirement(
      'At least one special character'.tran,
      hasSpecialCharacter(value),
    ),
  ];
}

class PasswordRequirement {
  final String label;
  final bool isMet;

  const PasswordRequirement(this.label, this.isMet);
}
