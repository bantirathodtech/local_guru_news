// lib/core/db/shared_prefs.dart
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences helper class for persistent local storage
/// Acts as a simple key-value store for persisting data between app sessions
class SharedPrefs {
  // Initialize SharedPreferences instance
  static Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // --- User Authentication Data ---

  /// Saves user ID to persistent storage
  static Future<void> setUserId(String userId) async {
    final prefs = await _prefs;
    await prefs.setString('userId', userId);
  }

  /// Retrieves user ID from persistent storage
  /// Returns null if no user ID is stored
  static Future<String?> getUserId() async {
    final prefs = await _prefs;
    return prefs.getString('userId');
  }

  /// Saves order ID to persistent storage
  static Future<void> setOrderId(String orderId) async {
    final prefs = await _prefs;
    await prefs.setString('order_id', orderId);
  }

  /// Retrieves order ID from persistent storage
  static Future<String?> getOrderId() async {
    final prefs = await _prefs;
    return prefs.getString('order_id');
  }

  /// Saves login status to persistent storage
  static Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await _prefs;
    await prefs.setBool('isLoggedIn', isLoggedIn);
  }

  /// Checks if user is logged in based on persistent storage
  /// Returns false if no login status is stored
  static Future<bool> isLoggedIn() async {
    final prefs = await _prefs;
    return prefs.getBool('isLoggedIn') ?? false;
  }

  // --- User Profile Data ---

  /// Saves user email to persistent storage
  static Future<void> setUserEmail(String email) async {
    final prefs = await _prefs;
    await prefs.setString('userEmail', email);
  }

  /// Retrieves user email from persistent storage
  static Future<String?> getUserEmail() async {
    final prefs = await _prefs;
    return prefs.getString('userEmail');
  }

  /// Saves user name to persistent storage
  static Future<void> setUserName(String name) async {
    final prefs = await _prefs;
    await prefs.setString('userName', name);
  }

  /// Retrieves user name from persistent storage
  static Future<String?> getUserName() async {
    final prefs = await _prefs;
    return prefs.getString('userName');
  }

  /// Saves user phone number to persistent storage
  static Future<void> setUserPhone(String phone) async {
    final prefs = await _prefs;
    await prefs.setString('userPhone', phone);
  }

  /// Retrieves user phone number from persistent storage
  static Future<String?> getUserPhone() async {
    final prefs = await _prefs;
    return prefs.getString('userPhone');
  }

  /// Saves user area ID to persistent storage
  static Future<void> setUserAreaId(String areaId) async {
    final prefs = await _prefs;
    await prefs.setString('userAreaId', areaId);
  }

  /// Retrieves user area ID from persistent storage
  static Future<String?> getUserAreaId() async {
    final prefs = await _prefs;
    return prefs.getString('userAreaId');
  }

  /// Saves user image URL to persistent storage
  static Future<void> setUserImageUrl(String imageUrl) async {
    final prefs = await _prefs;
    await prefs.setString('userImageUrl', imageUrl);
  }

  /// Retrieves user image URL from persistent storage
  static Future<String?> getUserImageUrl() async {
    final prefs = await _prefs;
    return prefs.getString('userImageUrl');
  }

  /// Removes user image URL from persistent storage
  static Future<void> clearUserImageUrl() async {
    final prefs = await _prefs;
    await prefs.remove('userImageUrl');
  }

  // --- Comprehensive User Data Methods ---

  /// Saves multiple user details to persistent storage in a single operation
  static Future<void> setUserDetails({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String pincode,
  }) async {
    final prefs = await _prefs;
    await Future.wait([
      prefs.setString('userName', name),
      prefs.setString('userEmail', email),
      prefs.setString('userPhone', phone),
      prefs.setString('userAddress', address),
      prefs.setString('userPincode', pincode),
    ]);
  }

  /// Retrieves user address from persistent storage
  static Future<String?> getUserAddress() async {
    final prefs = await _prefs;
    return prefs.getString('userAddress');
  }

  /// Retrieves user pincode from persistent storage
  static Future<String?> getUserPincode() async {
    final prefs = await _prefs;
    return prefs.getString('userPincode');
  }

  // --- Generic Storage Methods ---

  /// Generic method to save any string value with a custom key
  static Future<void> setString(String key, String value) async {
    final prefs = await _prefs;
    await prefs.setString(key, value);
  }

  /// Generic method to retrieve any string value with a custom key
  static Future<String?> getString(String key) async {
    final prefs = await _prefs;
    return prefs.getString(key);
  }

  /// Removes a specific key-value pair from persistent storage
  static Future<void> remove(String key) async {
    final prefs = await _prefs;
    await prefs.remove(key);
  }
}
