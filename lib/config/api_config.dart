import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  // The IP address where your Node.js server is running
  // For Android emulator: 10.0.2.2
  // For iOS simulator: localhost
  // For physical device: Use your computer's IP address (e.g., 192.168.1.100)
  static String get baseUrl {
    if (kIsWeb) {
      // For web platform, use the same origin as the Flutter web app
      // If your backend is running on a different port, you'll need to use the full URL
      return "http://localhost:5000";
    } else if (Platform.isAndroid) {
      // For Android emulator
      return "http://10.0.2.2:5000";
    } else if (Platform.isIOS) {
      // For iOS simulator
      return "http://localhost:5000";
    } else {
      // For physical devices, use your computer's IP address
      return "http://192.168.11.138:5000"; // Replace with your actual IP address
    }
  }

  static Map<String, String> get headers {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (kIsWeb) 'Access-Control-Allow-Origin': '*',
    };
  }

  static String getImageUrl(String? imagePath) {
    if (imagePath == null) return '';
    if (imagePath.startsWith('http')) return imagePath;
    return '$baseUrl$imagePath';
  }
}
