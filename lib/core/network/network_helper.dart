import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkHelper {
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      // If there's an error checking connectivity, assume we're connected
      // and let the actual API request handle any real connectivity issues
      return true;
    }
  }
}