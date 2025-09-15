import 'package:flutter/material.dart';
import '../presentation/screens/no_network_screen.dart';


class GlobalNavigationHandler {
  static final GlobalNavigationHandler _instance = GlobalNavigationHandler._internal();
  factory GlobalNavigationHandler() => _instance;
  GlobalNavigationHandler._internal();

  static GlobalKey<NavigatorState>? _navigatorKey;
  static bool _isOnNoNetworkScreen = false;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  static NavigatorState? get navigator => _navigatorKey?.currentState;

  static void handleConnectivityChange(bool isConnected) {
    if (navigator == null) return;

    if (!isConnected && !_isOnNoNetworkScreen) {
      // Save current route before navigating to no network screen
      _saveCurrentRoute();
      _navigateToNoNetworkScreen();
    } else if (isConnected && _isOnNoNetworkScreen) {
      // Network restored, navigate back to home or last route
      _navigateBackFromNoNetworkScreen();
    }
  }

  static void _saveCurrentRoute() {
    final currentRoute = ModalRoute.of(navigator!.context);
    if (currentRoute?.settings.name != null) {
    }
  }

  static void _navigateToNoNetworkScreen() {
    _isOnNoNetworkScreen = true;
    navigator!.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => const NoNetworkScreen(),
        settings: const RouteSettings(name: '/no-network'),
      ),
      (route) => false, // Remove all previous routes
    );
  }

  static void _navigateBackFromNoNetworkScreen() {
    _isOnNoNetworkScreen = false;
    
    // Always navigate to home screen when network is restored
    navigator!.pushNamedAndRemoveUntil(
      '/home',
      (route) => false,
      arguments: {'shouldRefresh': true}, // Signal to refresh data
    );
  }

  static bool get isOnNoNetworkScreen => _isOnNoNetworkScreen;

  static void resetNavigationState() {
    _isOnNoNetworkScreen = false;
  }

  // Method to manually trigger navigation to no network screen
  static void forceNavigateToNoNetworkScreen() {
    if (!_isOnNoNetworkScreen) {
      _navigateToNoNetworkScreen();
    }
  }

  // Method to check if we should show offline UI elements
  static bool shouldShowOfflineElements(bool isConnected) {
    return !isConnected || _isOnNoNetworkScreen;
  }
}