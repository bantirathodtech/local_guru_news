class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'Phone number is required';
    if (!RegExp(r'^\d{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit phone number';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Name is required';
    if (value.length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  // static String? validate10NumberUsername(String? value) {
  //   if (value == null || value.isEmpty) {
  //     return 'Phone number is required';
  //   }
  //
  //   // More lenient validation - just check it's all numbers
  //   if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
  //     return 'Only numbers are allowed';
  //   }
  //
  //   return null;
  // }

  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }

    // Check if it's a phone number (all digits)
    final bool isPhone = RegExp(r'^[0-9]+$').hasMatch(value);

    // Check if it's an email
    final bool isEmail =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value);

    if (!isPhone && !isEmail) {
      return 'Enter a valid email or phone number';
    }

    // Additional validation for phone numbers
    if (isPhone && value.length < 10) {
      return 'Phone number must be at least 10 digits';
    }

    return null;
  }

  static String? validateUsernamePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 4) return 'Password must be at least 6 characters';
    return null;
  }
}
