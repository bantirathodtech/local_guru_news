import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  // ============================
  // 🔐 Login API
  // ============================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://localguru.in/_api_v1/user/login_api.php'),
        body: {
          'email': email,
          'password': password,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'Failed',
          'message': 'Network error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'Failed', 'message': 'Error: $e'};
    }
  }

  // ============================
  // 📝 Registration API
  // ============================
  static Future<Map<String, dynamic>> register({
    required String name,
    required String contact,
    required String email,
    required String password,
    required String role,
    required String aadharNumber,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://erpapp.in/mart_print/mart_print_apis/registration_api.php'),
        body: {
          'name': name,
          'contact': contact,
          'email': email,
          'password': password,
          'role': role,
          'aadhar_number': aadharNumber,
          'address': address,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'Failed',
          'message': 'Network error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'Failed', 'message': 'Error: $e'};
    }
  }

  // ============================
  // 🔑 Forgot Password API
  // ============================
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://localguru.in/_api_v1/user/forgot_password_api.php'),
        body: {
          'email': email,
          'role': role,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'Failed',
          'message': 'Network error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'Failed', 'message': 'Error: $e'};
    }
  }

  // ============================
  // 🔄 Reset Password API
  // ============================
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String role,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://localguru.in/_api_v1/user/reset_password_api.php'),
        body: {
          'email': email,
          'role': role,
          'otp': otp,
          'new_password': newPassword,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'status': 'Failed',
          'message': 'Network error: ${response.statusCode}'
        };
      }
    } catch (e) {
      return {'status': 'Failed', 'message': 'Error: $e'};
    }
  }
}
