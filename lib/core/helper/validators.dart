abstract class AppValidators {
  AppValidators._();

  static bool isEmail(String email) => RegExp(
        "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$",
      ).hasMatch(email);

  static String? isValidEmail(String? email) {
    if (RegExp(
      "^[a-zA-Z0-9.!#\$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*\$",
    ).hasMatch(email ?? "")) {
      return null;
    }
    return 'This is not a valid email address';
  }

  static String? isNotEmptyValidator(String? title) {
    if (title?.isEmpty ?? true) {
      return 'This field is required';
    }
    return null;
  }

  static String? isNumberValidator(String? title) {
    if (title?.isEmpty ?? true) {
      return 'This field is required';
    }
    if ((num.tryParse(title ?? "") ?? 0.0).isNegative) {
      return 'This field is not negative';
    }
    return null;
  }

  static String? isValidPrice(String? title) {
    if (title?.isEmpty ?? true) {
      return 'This field is required';
    } else if ((num.tryParse(title ?? "0") ?? 0) <= 0) {
      return 'This field is not negative';
    }
    return null;
  }

  static String? isValidPassword(String? password) {
    if (password?.isEmpty ?? true) {
      return 'This field is required';
    } else if ((password?.length ?? 0) < 5) {
      return 'Password must be at least 5 characters';
    }
    return null;
  }

  static String? isValidConfirmPassword(
      String password, String? confirmPassword) {
    if (confirmPassword?.isEmpty ?? true) {
      return 'This field is required';
    } else if (confirmPassword != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? isValidIban(String? iban) {
    if (iban?.isEmpty ?? true) {
      return 'This field is required';
    } else if (iban!.length < 15 || iban.length > 34) {
      return 'IBAN must be between 15 and 34 characters';
    } else if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(iban)) {
      return 'IBAN should only contain alphanumeric characters';
    }
    return null;
  }
}
