// lib/core/api/orchestration/api_registry.dart
class ApiRegistry {
  // API Identifiers
  static const String banners = 'banners';
  static const String mainCategories = 'main_categories';
  static const String categories = 'categories';
  static const String subCategories = 'sub_categories';
  static const String userProfile = 'user_profile';
  static const String cartItems = 'cart_items';
  static const String orders = 'orders';
  static const String products = 'products';
  static const String notifications = 'notifications';
  static const String areas = 'areas';

  // API Configuration
  static const Map<String, ApiConfig> _apiConfigs = {
    banners: ApiConfig(
      cacheDuration: Duration(hours: 1),
      minRefreshInterval: Duration(minutes: 5),
    ),
    mainCategories: ApiConfig(
      cacheDuration: Duration(hours: 2),
      minRefreshInterval: Duration(hours: 1),
    ),
    categories: ApiConfig(
      cacheDuration: Duration(hours: 3),
      minRefreshInterval: Duration(minutes: 30),
    ),
    subCategories: ApiConfig(
      cacheDuration: Duration(hours: 2),
      minRefreshInterval: Duration(minutes: 15),
    ),
    userProfile: ApiConfig(
      cacheDuration: Duration(hours: 6),
      minRefreshInterval: Duration(hours: 2),
    ),
    cartItems: ApiConfig(
      cacheDuration: Duration(minutes: 15),
      minRefreshInterval: Duration(minutes: 2),
    ),
    orders: ApiConfig(
      cacheDuration: Duration(minutes: 10),
      minRefreshInterval: Duration(minutes: 5),
    ),
    products: ApiConfig(
      cacheDuration: Duration(minutes: 30),
      minRefreshInterval: Duration(minutes: 10),
    ),
    notifications: ApiConfig(
      cacheDuration: Duration(minutes: 5),
      minRefreshInterval: Duration(minutes: 1),
    ),
    areas: ApiConfig(
      cacheDuration: Duration(hours: 24),
      minRefreshInterval: Duration(hours: 12),
    ),
  };

  static ApiConfig getConfig(String apiIdentifier) {
    return _apiConfigs[apiIdentifier] ?? ApiConfig();
  }
}

class ApiConfig {
  final Duration cacheDuration;
  final Duration minRefreshInterval;

  const ApiConfig({
    this.cacheDuration = const Duration(minutes: 30),
    this.minRefreshInterval = const Duration(minutes: 5),
  });
}
