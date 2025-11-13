import 'dart:io';

import 'package:local_guru_all/src/core/api/custom/endpoints/sundeep/api_endpoints.dart';
import 'package:local_guru_all/src/core/api/shared/config/api_service_config.dart';
import 'package:local_guru_all/src/core/api/shared/service/api_service.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository({ApiService? apiService})
      : _apiService = apiService ??
            ApiService(config: ApiServiceConfig.fromEnvironment());

  // Sign in (email/password/role)
  Future<dynamic> login({
    required String email,
    required String password,
    required String role,
  }) async {
    return _apiService.post(
      ApiEndpoints.loginV1,
      {
        'email': email,
        'password': password,
        'role': role,
      },
      caller: 'AuthRepository.login',
      // The API expects form-data; our core will handle multipart when needed
      forceFormData: true,
    );
  }

  // Send OTP to phone
  // Future<dynamic> requestOtp({
  //   required String mobile,
  // }) async {
  //   return _apiService.post(
  //     ApiEndpoints.phoneAuthApi,
  //     {
  //       'mobile': mobile,
  //     },
  //     caller: 'AuthRepository.requestOtp',
  //     forceFormData: true,
  //   );
  // }

  // Registration (v1) - expects form-data based on role
  Future<dynamic> register({
    required String role, // 'user' or 'editor'
    required String name,
    required String contact,
    required String email,
    required String password,
    required String aadharNumber,
    required String address,
  }) async {
    return _apiService.post(
      ApiEndpoints.registrationV1,
      {
        'role': role,
        'name': name,
        'contact': contact,
        'email': email,
        'password': password,
        'aadhar_number': aadharNumber,
        'address': address,
      },
      caller: 'AuthRepository.register',
      forceFormData: true,
    );
  }

  // Verify OTP and user
  // Future<dynamic> verifyUser({
  //   required String id,
  //   required String mobile,
  //   required String otp,
  //   required String token,
  // }) async {
  //   return _apiService.post(
  //     ApiEndpoints.verifyUserApi,
  //     {
  //       'id': id,
  //       'mobile': mobile,
  //       'otp': otp,
  //       'token': token,
  //     },
  //     caller: 'AuthRepository.verifyUser',
  //     forceFormData: true,
  //   );
  // }

  // Expire OTP
  // Future<dynamic> expireOtp({
  //   required String id,
  //   required String mobile,
  //   required String otp,
  // }) async {
  //   return _apiService.post(
  //     ApiEndpoints.expireOtpApi,
  //     {
  //       'id': id,
  //       'mobile': mobile,
  //       'otp': otp,
  //     },
  //     caller: 'AuthRepository.expireOtp',
  //     forceFormData: true,
  //   );
  // }

  // Forgot password (v1)
  Future<dynamic> forgotPassword({
    required String email,
    required String role,
  }) async {
    return _apiService.post(
      ApiEndpoints.forgotPasswordV1,
      {
        'email': email,
        'role': role,
      },
      caller: 'AuthRepository.forgotPassword',
      forceFormData: true,
    );
  }

  // Reset password (v1)
  Future<dynamic> resetPassword({
    required String email,
    required String role,
    required String otp,
    required String newPassword,
  }) async {
    return _apiService.post(
      ApiEndpoints.resetPasswordV1,
      {
        'email': email,
        'role': role,
        'otp': otp,
        'new_password': newPassword,
      },
      caller: 'AuthRepository.resetPassword',
      forceFormData: true,
    );
  }

  // Update profile (v1) - supports optional image upload
  Future<dynamic> updateProfile({
    required String id,
    required String name,
    required String email,
    required String role,
    required String aadharNumber,
    required String address,
    required String contact,
    File? image,
  }) async {
    final fields = <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'aadhar_number': aadharNumber,
      'address': address,
      'contact': contact,
    };

    if (image != null) {
      return _apiService.postWithFile(
        ApiEndpoints.updateProfileV1,
        fields,
        image,
        'image',
        caller: 'AuthRepository.updateProfile.multipart',
      );
    }

    return _apiService.post(
      ApiEndpoints.updateProfileV1,
      fields,
      caller: 'AuthRepository.updateProfile',
      forceFormData: true,
    );
  }
}
