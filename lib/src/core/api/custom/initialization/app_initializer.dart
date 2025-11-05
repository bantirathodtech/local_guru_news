// lib/core/initialization/app_initializer_enhanced.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/viewmodel/auth_provider.dart';
import '../../../data/local/shared_prefs.dart';
import 'orchestration/api_orchestrator.dart';
import 'orchestration/api_registry.dart';

class AppInitializer {
  static Future<void> initializeApp(BuildContext context) async {
    try {
      // Load essential data that doesn't require authentication
      await _loadPublicData(context);

      // Check authentication status
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isLoggedIn = await authProvider.isLoggedInPersistent();
      final customerId = await SharedPrefs.getUserId();

      // If user is logged in, load user-specific data
      if (isLoggedIn && customerId != null) {
        await _loadPrivateData(context, customerId);
      }
    } catch (e) {
      debugPrint('App initialization completed with errors: $e');
    }
  }

  static Future<void> _loadPublicData(BuildContext context) async {
    // final bannerProvider = Provider.of<BannerProvider>(context, listen: false);
    // final categoryProvider =
    //     Provider.of<CategoryProvider>(context, listen: false);
    // final areaProvider = Provider.of<AreaProvider>(context, listen: false);

    // Load public data in parallel with orchestration
    // await Future.wait([
    //   ApiOrchestrator.call(
    //     context: context,
    //     apiIdentifier: ApiRegistry.banners,
    //     apiCall: bannerProvider.fetchBanners,
    //     callType: ApiCallType.onAppStart,
    //   ),
    //   ApiOrchestrator.call(
    //     context: context,
    //     apiIdentifier: ApiRegistry.mainCategories,
    //     apiCall: categoryProvider.loadMainCategories,
    //     callType: ApiCallType.onAppStart,
    //   ),
    //   ApiOrchestrator.call(
    //     context: context,
    //     apiIdentifier: ApiRegistry.areas,
    //     apiCall: areaProvider.fetchAreas,
    //     callType: ApiCallType.onAppStart,
    //   ),
    // ]);
  }

  static Future<void> _loadPrivateData(
      BuildContext context, String customerId) async {
    // final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load private data in parallel with orchestration
    await Future.wait([
      ApiOrchestrator.call(
        context: context,
        apiIdentifier: ApiRegistry.userProfile,
        apiCall: authProvider.refreshUserData,
        callType: ApiCallType.onAppStart,
      ),
      // ApiOrchestrator.call(
      //   context: context,
      //   apiIdentifier: ApiRegistry.cartItems,
      //   apiCall: () => cartProvider.loadCartItems(customerId),
      //   callType: ApiCallType.onAppStart,
      // ),
    ]);
  }

  // Method to refresh specific data on demand
  static Future<void> refreshData({
    required BuildContext context,
    required List<String> apiIdentifiers,
    bool forceRefresh = true,
  }) async {
    final tasks = <Future>[];

    for (final apiId in apiIdentifiers) {
      tasks.add(_refreshSingleApi(context, apiId, forceRefresh));
    }

    await Future.wait(tasks);
  }

  static Future<void> _refreshSingleApi(
    BuildContext context,
    String apiIdentifier,
    bool forceRefresh,
  ) async {
    switch (apiIdentifier) {
      // case ApiRegistry.banners:
      //   final provider = Provider.of<BannerProvider>(context, listen: false);
      //   await ApiOrchestrator.call(
      //     context: context,
      //     apiIdentifier: apiIdentifier,
      //     apiCall: provider.fetchBanners,
      //     callType: ApiCallType.onManualRefresh,
      //     forceRefresh: forceRefresh,
      //   );
      //   break;

      // case ApiRegistry.mainCategories:
      //   final provider = Provider.of<CategoryProvider>(context, listen: false);
      //   await ApiOrchestrator.call(
      //     context: context,
      //     apiIdentifier: apiIdentifier,
      //     apiCall: provider.loadMainCategories,
      //     callType: ApiCallType.onManualRefresh,
      //     forceRefresh: forceRefresh,
      //   );
      //   break;

      // Add more cases for other API identifiers as needed
    }
  }
}
