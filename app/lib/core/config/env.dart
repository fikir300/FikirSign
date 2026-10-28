// app/lib/core/config/env.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

class Env {
  // If your phone is on the same Wi-Fi, change this to your laptop's local IP (e.g. 192.168.1.15)
  static const String _customHost = "";

  static String get backendUrl {
    if (_customHost.isNotEmpty) {
      return "http://$_customHost:5000/api/translate";
    }
    if (kIsWeb) {
      return "http://localhost:5000/api/translate";
    }
    if (Platform.isAndroid) {
      return "http://10.0.2.2:5000/api/translate"; // Android Emulator to Laptop Host
    }
    return "http://localhost:5000/api/translate";
  }
}