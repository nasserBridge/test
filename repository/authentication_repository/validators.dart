import 'package:get/get.dart';

class FormValidators {
  FormValidators get instance => Get.find();

  static String? validateLoginEmail(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      return 'E-mail is required';
    }
    return null;
  }

  static String? validateLoginPassword(String? formPassword) {
    if (formPassword == null || formPassword.isEmpty) {
      return 'Password is required';
    }

    return null;
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'First name required';
    }
    return null;
  }

  static String? validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Last name required';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Regular expression pattern for a basic US phone number (###-###-####)
    final phoneRegex = RegExp(r'^\+1 \(\d{3}\) \d{3}-\d{4}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid format +1 (XXX) XXX-XXXX';
    }

    return null; // Return null if validation passes
  }

  static String? validateSignUpEmail(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      return 'E-mail is required';
    }

    String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(formEmail)) {
      return 'Invalid E-mail Address format';
    }
    return null;
  }

  String? validateAddressLine1(String? value) {
    if (value == null || value.isEmpty) {
      return 'Physical address is required';
    }
    return null; // null means valid
  }

  static String? validateAddressLine2(String? value) {
    // Address Line 2 is often optional, so it might not need validation
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'City is required';
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    // Optionally, add more specific validation for the state (e.g., length check or matching state names/abbreviations)
    if (value.length != 2) {
      // Assuming state abbreviation
      return 'Abbreviate';
    }
    return null;
  }

  static String? validateZipcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Required';
    }
    // Basic US Zipcode validation (5 digits or 5+4 format)
    RegExp zipRegEx = RegExp(r'^\d{5}(-\d{4})?$');
    if (!zipRegEx.hasMatch(value)) {
      return 'Invalid ZipCode';
    }
    return null;
  }

  static String? validateSignUpPassword(String? formPassword) {
    if (formPassword == null || formPassword.isEmpty) {
      return 'Password is required';
    }

    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~-]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(formPassword)) {
      return '''Password must be at least 8 characters,
      include an uppcase letter, number, and symbol''';
    }
    return null;
  }

  static String? validateNewFirstName(
    String? oldFirst,
    String? oldLast,
    String? newLast,
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return 'First name required';
    }
    if (oldFirst == value && oldLast == newLast) {
      return 'Change first or last name';
    }
    return null;
  }

  static String? validateNewLastName(
    String? oldLast,
    String? oldFirst,
    String? newFirst,
    String? value,
  ) {
    if (value == null || value.isEmpty) {
      return 'Last name required';
    }
    if (oldLast == value && oldFirst == newFirst) {
      return 'Change first or last name';
    }

    return null;
  }

  static String? validateNewAddressLine1(String? oldAddress1, String? value,
      String? oldAddress2, String? newAddress2) {
    if (value == null || value.isEmpty) {
      return 'Physical address is required';
    }
    if (oldAddress1 == value && oldAddress2 == newAddress2) {
      return 'Physical address did not change';
    }
    return null; // null means valid
  }

  static String? validateNewAddressLine2(String? oldAddress1,
      String? newAddress1, String? oldAddress2, String? value) {
    if (oldAddress1 == newAddress1 && oldAddress2 == value) {
      return 'Physical address did not change';
    }
    return null; // null means valid
  }

  static String? validateNewEmail(String? oldEmail, String? formEmail) {
    return null;
  }

  static String? validateNewPhoneNumber(String? oldPhone, String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (oldPhone == value) {
      return 'Change Phone Number';
    }

    // Regular expression pattern for a basic US phone number (###-###-####)
    final phoneRegex = RegExp(r'^\+1 \(\d{3}\) \d{3}-\d{4}$');

    if (!phoneRegex.hasMatch(value)) {
      return 'Enter a valid format +1 (000) 000-0000';
    }

    return null; // Return null if validation passes
  }

  static String? validateOldPassword(
      String? currentPassword, String? formPassword) {
    if (formPassword == null || formPassword.isEmpty) {
      return 'Password is required';
    }
    if (formPassword != currentPassword) {
      return 'Invalid Password';
    }

    return null;
  }

  static String? validateNewPassword(
      String? oldPassword, String? formPassword) {
    if (formPassword == null || formPassword.isEmpty) {
      return 'Password is required.';
    }

    if (formPassword == oldPassword) {
      return 'New password is same as the prior';
    }

    String pattern =
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~-]).{8,}$';
    RegExp regex = RegExp(pattern);
    if (!regex.hasMatch(formPassword)) {
      return '''Password must be at least 8 characters,
      include an uppcase letter, number, and symbol''';
    }
    return null;
  }

  static String? validateConfirmPassword(
      String? password, String? confirmPassword) {
    if (password == null ||
        confirmPassword == null ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return 'Both password fields are required';
    }

    if (password != confirmPassword) {
      return 'Passwords do not match';
    }

    return null; // Return null if validation passes
  }

  static String? validateForgotPassword(String? formEmail) {
    if (formEmail == null || formEmail.isEmpty) {
      return 'Email is required';
    }
    return null;
  }
}
