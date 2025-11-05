import 'package:flutter/material.dart';
import 'package:local_guru_all/src/core/navigation/tab_provider/tab_index_provider.dart';
import 'package:provider/provider.dart';

class AppNavigationService {
  static final AppNavigationService _instance =
      AppNavigationService._internal();
  factory AppNavigationService() => _instance;
  AppNavigationService._internal();

  /// Root navigator key for global navigation outside tabs
  final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>();

  /// Navigator keys for nested tab navigators, set after widget build
  late List<GlobalKey<NavigatorState>> tabNavigatorKeys;

  /// Provider reference for tab index management
  TabIndexProvider? _tabIndexProvider;

  /// Initialize provider and current index using context
  void init(BuildContext context) {
    _tabIndexProvider = Provider.of<TabIndexProvider>(context, listen: false);
  }

  void setTabNavigatorKeys(List<GlobalKey<NavigatorState>> keys) {
    tabNavigatorKeys = keys;
  }

  /// Get NavigatorState for specific tab, or null if unavailable
  NavigatorState? _getTabNavigator(int tabIndex) {
    if (tabNavigatorKeys.isEmpty ||
        tabIndex < 0 ||
        tabIndex >= tabNavigatorKeys.length) {
      return null;
    }
    return tabNavigatorKeys[tabIndex].currentState;
  }

  int get currentTabIndex => _tabIndexProvider?.currentIndex ?? 0;

  /// Set current tab index (changes UI tab)
  void switchTab(int index) {
    if (_tabIndexProvider == null) return;

    if (_tabIndexProvider!.currentIndex == index) {
      // On re-select, pop to root inside this tab
      popToRoot(index);
    } else {
      _tabIndexProvider!.setIndex(index);
    }
  }

  /// Switch tab and reset tab's navigation stack
  void switchTabAndReset(int index) {
    if (_tabIndexProvider == null) return;

    _tabIndexProvider!.setIndex(index);
    popToRoot(index);
  }

  /// Pop all routes to root in specified tab navigator
  void popToRoot(int tabIndex) {
    final nav = _getTabNavigator(tabIndex);
    if (nav != null && nav.canPop()) {
      nav.popUntil((route) => route.isFirst);
    }
  }

  /// Generic push on a tab navigator (stacked inside a tab)
// Push route on tab navigator
  Future<T?> pushNamedOnTab<T>(
    String routeName, {
    required int tabIndex,
    Object? arguments,
  }) {
    final nav = _getTabNavigator(tabIndex);
    if (nav != null) {
      return nav.pushNamed<T>(routeName, arguments: arguments);
    }
    // Fallback: Navigator.push returns Future<dynamic>, cast to Future<T?>
    return rootNavigatorKey.currentState
            ?.pushNamed<T>(routeName, arguments: arguments) ??
        Future.value(null);
  }

  /// Push replacement on tab navigator
  Future<T?> pushReplacementNamedOnTab<T, TO extends Object?>(
    String routeName, {
    required int tabIndex,
    Object? arguments,
    TO? result,
  }) {
    final nav = _getTabNavigator(tabIndex);
    if (nav != null) {
      return nav.pushReplacementNamed<T, TO>(routeName,
          arguments: arguments, result: result);
    }
    // fallback return
    return rootNavigatorKey.currentState?.pushReplacementNamed<T, TO>(routeName,
            arguments: arguments, result: result) ??
        Future.value(null);
  }

  /// Pop route from specified tab navigator (default current tab)
  bool maybePopFromTab({int? tabIndex}) {
    final index = tabIndex ?? currentTabIndex;
    final nav = _getTabNavigator(index);
    if (nav != null && nav.canPop()) {
      nav.pop();
      return true;
    }
    return false;
  }

  /// Root push navigation for general routes (outside tab navigation)
  Future<T?> pushNamed<T>(String routeName, {Object? arguments}) {
    return rootNavigatorKey.currentState
            ?.pushNamed<T>(routeName, arguments: arguments) ??
        Future.value(null);
  }

  /// Root push replacement
  Future<T?> pushReplacementNamed<T, TO extends Object?>(
    String routeName, {
    Object? arguments,
    TO? result,
  }) {
    return rootNavigatorKey.currentState?.pushReplacementNamed<T, TO>(routeName,
            arguments: arguments, result: result) ??
        Future.value(null);
  }

  /// Root pop
  bool maybePop() {
    if (rootNavigatorKey.currentState?.canPop() ?? false) {
      rootNavigatorKey.currentState?.pop();
      return true;
    }
    return false;
  }

  /// Cross-tab navigation and resetting

  Future<T?> navigateToTabScreen<T>({
    required int tabIndex,
    required String routeName,
    Object? arguments,
  }) async {
    if (_tabIndexProvider == null) return null;
    _tabIndexProvider!.setIndex(tabIndex);
    popToRoot(tabIndex);
    final nav = _getTabNavigator(tabIndex);
    if (nav != null) {
      return nav.pushNamed<T>(routeName, arguments: arguments);
    }
    return null;
  }

  /// Clear all stacks and reset root and tabs if needed
  Future<void> resetAppNavigation() async {
    // Pop root navigator completely
    while (maybePop()) {}
    // Pop all tab navigators to root
    for (var i = 0; i < tabNavigatorKeys.length; i++) {
      popToRoot(i);
    }
    // Reset current tab to first
    _tabIndexProvider?.setIndex(0);
  }
}
