class Validators {
  static String? required(String? value, [String message = 'This field is required']) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleanPhone = value.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (cleanPhone.length < 7 || cleanPhone.length > 15) {
      return 'Enter a valid phone number (7-15 digits)';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? marks(String? value, {double max = 100}) {
    if (value == null || value.trim().isEmpty) {
      return 'Marks required';
    }
    final num = double.tryParse(value.trim());
    if (num == null) {
      return 'Must be a number';
    }
    if (num < 0 || num > max) {
      return 'Range: 0 - ${max.toInt()}';
    }
    return null;
  }
}
