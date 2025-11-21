import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_guru_all/src/core/data/local/shared_prefs.dart';
import 'package:local_guru_all/src/features/auth/data/model/userModel.dart';
import 'package:local_guru_all/src/features/auth/data/repository/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? AuthRepository();

  // Core state
  bool _isLoading = false;
  String? _error;

  // Auth-specific state
  UserModel? _currentUser;
  // MobileAuth? _lastOtp;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserModel? get currentUser => _currentUser;
  // MobileAuth? get lastOtp => _lastOtp;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _error = message;
    notifyListeners();
  }

  void _setUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  // void _setOtp(MobileAuth? otp) {
  //   _lastOtp = otp;
  //   notifyListeners();
  // }

  Future<void> _persistUser(UserModel user) async {
    // Save to SharedPreferences (for AuthProvider)
    if (user.id != null) {
      await SharedPrefs.setUserId(user.id!);
      await SharedPrefs.setLoggedIn(true);
    }
    if (user.name != null) {
      await SharedPrefs.setUserName(user.name!);
    }
    if (user.contact != null) {
      await SharedPrefs.setUserPhone(user.contact!);
    }
    if (user.profile != null) {
      await SharedPrefs.setUserImageUrl(user.profile!);
    }
    if (user.email != null) {
      await SharedPrefs.setUserEmail(user.email!);
    }
    if (user.aadharNumber != null) {
      await SharedPrefs.setString('userAadharNumber', user.aadharNumber!);
    }
    if (user.address != null) {
      await SharedPrefs.setString('userAddress', user.address!);
    }
    if (user.role != null) {
      await SharedPrefs.setString('userRole', user.role!);
    }
    
    // Also save to Hive box (for userIdProvider and other Riverpod providers)
    try {
      final box = Hive.box<String>('user');
      if (user.id != null) {
        box.put('id', user.id!);
      }
      if (user.name != null) {
        box.put('name', user.name!);
      }
      if (user.email != null) {
        box.put('email', user.email!);
      }
      if (user.role != null) {
        box.put('role', user.role!);
      }
      if (user.contact != null) {
        box.put('contact', user.contact!);
      }
    } catch (e) {
      // Silently handle Hive errors - SharedPreferences is the primary storage
      debugPrint('Error saving to Hive: $e');
    }
  }

  // Public: Persistent auth checks used by AppInitializer
  Future<bool> isLoggedInPersistent() async {
    final loggedIn = await SharedPrefs.isLoggedIn();
    if (!loggedIn) return false;
    final id = await SharedPrefs.getUserId();
    if (id == null) return false;

    // Hydrate in-memory user if missing
    if (_currentUser == null) {
      final name = await SharedPrefs.getUserName();
      final contact = await SharedPrefs.getUserPhone();
      final profile = await SharedPrefs.getUserImageUrl();
      final email = await SharedPrefs.getUserEmail();
      final aadharNumber = await SharedPrefs.getString('userAadharNumber');
      final address = await SharedPrefs.getUserAddress();
      final role = await SharedPrefs.getString('userRole');
      _setUser(UserModel(
        id: id,
        name: name,
        contact: contact,
        profile: profile,
        email: email,
        aadharNumber: aadharNumber,
        address: address,
        role: role,
      ));
    }
    return true;
  }

  Future<void> refreshUserData() async {
    final id = await SharedPrefs.getUserId();
    if (id == null) return;
    final name = await SharedPrefs.getUserName();
    final contact = await SharedPrefs.getUserPhone();
    final profile = await SharedPrefs.getUserImageUrl();
    final email = await SharedPrefs.getUserEmail();
    final aadharNumber = await SharedPrefs.getString('userAadharNumber');
    final address = await SharedPrefs.getUserAddress();
    final role = await SharedPrefs.getString('userRole');
    
    final user = UserModel(
      id: id,
      name: name,
      contact: contact,
      profile: profile,
      email: email,
      aadharNumber: aadharNumber,
      address: address,
      role: role,
    );
    
    _setUser(user);
    
    // Sync to Hive box for Riverpod providers
    try {
      final box = Hive.box<String>('user');
      box.put('id', id);
      if (name != null) box.put('name', name);
      if (email != null) box.put('email', email);
      if (role != null) box.put('role', role);
      if (contact != null) box.put('contact', contact);
    } catch (e) {
      debugPrint('Error syncing to Hive: $e');
    }
  }

  // Sign in
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _repository.login(
        email: email,
        password: password,
        role: role,
      );

      // Flexible parsing: supports either Map or List payloads
      if (response is Map<String, dynamic>) {
        if (response.containsKey('id')) {
          final user = UserModel.fromJson(response);
          _setUser(user);
          await _persistUser(user);
        }
      } else if (response is List &&
          response.isNotEmpty &&
          response.first is Map) {
        final first = response.first as Map<String, dynamic>;
        if (first['id'] != null) {
          final user = UserModel.fromJson(first);
          _setUser(user);
          await _persistUser(user);
        }
      }

      return response as Map<String, dynamic>? ?? {'status': 'OK'};
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Request OTP
  // Future<dynamic> sendOtp({
  //   required String mobile,
  // }) async {
  //   _setLoading(true);
  //   _setError(null);
  //   try {
  //     final response = await _repository.requestOtp(mobile: mobile);

  //     // Handle list payload [ { mobile, otp, id } ]
  //     if (response is List && response.isNotEmpty && response.first is Map) {
  //       _setOtp(MobileAuth.fromJson(response.first as Map<String, dynamic>));
  //     } else if (response is Map<String, dynamic>) {
  //       // Some APIs may return object
  //       _setOtp(MobileAuth.fromJson(response));
  //     }

  //     return response;
  //   } catch (e) {
  //     _setError(e.toString());
  //     rethrow;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Verify user with OTP
  // Future<dynamic> verifyUser({
  //   required String id,
  //   required String mobile,
  //   required String otp,
  //   required String token,
  // }) async {
  //   _setLoading(true);
  //   _setError(null);
  //   try {
  //     final response = await _repository.verifyUser(
  //       id: id,
  //       mobile: mobile,
  //       otp: otp,
  //       token: token,
  //     );

  //     if (response is List && response.isNotEmpty && response.first is Map) {
  //       final first = response.first as Map<String, dynamic>;
  //       if (first['id'] != null) {
  //         final user = UserModel.fromJson(first);
  //         _setUser(user);
  //         await _persistUser(user);
  //       }
  //     } else if (response is Map<String, dynamic>) {
  //       if (response.containsKey('id')) {
  //         final user = UserModel.fromJson(response);
  //         _setUser(user);
  //         await _persistUser(user);
  //       }
  //     }

  //     return response;
  //   } catch (e) {
  //     _setError(e.toString());
  //     rethrow;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Expire OTP
  // Future<dynamic> expireOtp({
  //   required String id,
  //   required String mobile,
  //   required String otp,
  // }) async {
  //   _setLoading(true);
  //   _setError(null);
  //   try {
  //     final response = await _repository.expireOtp(
  //       id: id,
  //       mobile: mobile,
  //       otp: otp,
  //     );
  //     return response;
  //   } catch (e) {
  //     _setError(e.toString());
  //     rethrow;
  //   } finally {
  //     _setLoading(false);
  //   }
  // }

  // Sign up
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
    required String contact,
    required String aadharNumber,
    required String address,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _repository.register(
        email: email,
        password: password,
        role: role,
        name: name,
        contact: contact,
        aadharNumber: aadharNumber,
        address: address,
      );

      return response as Map<String, dynamic>? ?? {'status': 'OK'};
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword({
    required String email,
    required String role,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _repository.forgotPassword(
        email: email,
        role: role,
      );
      return response as Map<String, dynamic>? ?? {'status': 'OK'};
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String role,
    required String otp,
    required String newPassword,
  }) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _repository.resetPassword(
        email: email,
        role: role,
        otp: otp,
        newPassword: newPassword,
      );
      return response as Map<String, dynamic>? ?? {'status': 'OK'};
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile (with optional image)
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
    _setLoading(true);
    _setError(null);
    try {
      final response = await _repository.updateProfile(
        id: id,
        name: name,
        email: email,
        role: role,
        aadharNumber: aadharNumber,
        address: address,
        contact: contact,
        image: image,
      );

      // When backend returns updated user
      if (response is List && response.isNotEmpty && response.first is Map) {
        final first = response.first as Map<String, dynamic>;
        if (first['id'] != null) {
          final user = UserModel.fromJson(first);
          _setUser(user);
          await _persistUser(user);
        }
      } else if (response is Map<String, dynamic>) {
        if (response.containsKey('id')) {
          final user = UserModel.fromJson(response);
          _setUser(user);
          await _persistUser(user);
        }
      }

      return response;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    try {
      // Clear local storage
      await SharedPrefs.setLoggedIn(false);
      await SharedPrefs.setUserId('');
      await SharedPrefs.setUserName('');
      await SharedPrefs.setUserPhone('');
      await SharedPrefs.setUserImageUrl('');
      await SharedPrefs.setUserEmail('');
      await SharedPrefs.remove('userAadharNumber');
      await SharedPrefs.remove('userAddress');
      await SharedPrefs.remove('userRole');
      
      // Clear in-memory user
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }

  // Clear errors
  void clearError() => _setError(null);
}
