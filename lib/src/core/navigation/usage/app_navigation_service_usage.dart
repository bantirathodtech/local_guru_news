// app_navigation_service_usage.dart

import 'package:flutter/material.dart';

import '../app_navigation_service.dart';

/// Example setup in your root widget or main_screen:
///
/// 1. Create navigator keys for every tab:
final List<GlobalKey<NavigatorState>> navigatorKeys = [
  GlobalKey<NavigatorState>(), // Home tab
  GlobalKey<NavigatorState>(), // Products tab
  GlobalKey<NavigatorState>(), // Cart tab
  GlobalKey<NavigatorState>(), // Orders tab
];

/// 2. In initState of MainScreen or wherever:
void initializeNavigation(BuildContext context) {
  final navService = AppNavigationService();
  navService.setTabNavigatorKeys(navigatorKeys);
  navService.init(context);
}

/// 3. Wire navigator keys to your nested Navigators inside IndexedStack:
///
/// IndexedStack(
///   index: context.watch<TabIndexProvider>().currentIndex,
///   children: [
///     Navigator(key: navigatorKeys[0], onGenerateRoute: ...), // Home
///     Navigator(key: navigatorKeys[1], onGenerateRoute: ...), // Products
///     Navigator(key: navigatorKeys[2], onGenerateRoute: ...), // Cart
///     Navigator(key: navigatorKeys[3], onGenerateRoute: ...), // Orders
///   ],
/// )
///
///
/// ---
///
/// USAGE EXAMPLES:
///

/// Switch to another tab without changing stack (just switch UI tab):
///
/// AppNavigationService().switchTab(2); // e.g., switch to Cart tab

/// Switch and reset tab navigation stack to root:
///
/// AppNavigationService().switchTabAndReset(2);

/// Navigate inside current tab:
///
/// AppNavigationService().pushNamedOnTab(
///   '/product_details',
///   tabIndex: AppNavigationService().currentTabIndex,
///   arguments: {'productId': 123},
/// );

/// Cross-tab navigation with reset stack and push route:
///
/// await AppNavigationService().navigateToTabScreen(
///   tabIndex: 1,
///   routeName: '/product_list',
///   arguments: {'categoryId': 5},
/// );

/// Normal root-level push navigation (outside tabs):
///
/// AppNavigationService().pushNamed('/login');

/// Push replacement root navigation:
///
/// AppNavigationService().pushReplacementNamed('/home');

/// Pop on current tab if possible, returns true if pop happened:
///
/// AppNavigationService().maybePopFromTab();

/// Pop root navigator if possible (outside tabs):
///
/// AppNavigationService().maybePop();

/// Pop tab stack to root (manually):
///
/// AppNavigationService().popToRoot(0); // pop Home tab stack to root

/// Clear all navigation stacks and reset to first tab:
///
/// await AppNavigationService().resetAppNavigation();

/// ---
///
/// Back button handling example in main_screen.dart:
///
/// ```
/// WillPopScope(
///   onWillPop: () async {
///     final navService = AppNavigationService();
///     // Try pop current tab stack
///     if (navService.maybePopFromTab()) return false; // Pop done, no exit
///     // If on first tab root, maybe exit app or double tap exit
///     if (navService.currentTabIndex != 0) {
///       navService.switchTab(0);
///       return false; // Switch to Home tab instead of exit
///     }
///     return true; // Allow app exit
///   },
///   child: ...
/// )
/// ```
///
///
/// This service centralizes navigation logic and is reusable app-wide.
