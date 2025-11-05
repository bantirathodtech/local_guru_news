import 'package:connectivity_plus/connectivity_plus.dart';

abstract class NetworkUtils {
  static Future<bool> get isConnected async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false; // Fallback for platforms where connectivity check fails
    }
  }
}
