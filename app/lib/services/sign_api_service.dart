// lib/services/sign_api_service.dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class SignResult {
  final String sign;
  final String amharic;
  final double confidence;
  final List<dynamic> top3;

  SignResult({required this.sign, required this.amharic, required this.confidence, required this.top3});

  factory SignResult.fromJson(Map<String, dynamic> json) {
    return SignResult(
      sign: json['sign'] ?? 'IDLE',
      amharic: json['amharic'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      top3: json['top3'] ?? [],
    );
  }
}

class SignApiService {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api/translate';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api/translate';
    return 'http://localhost:5000/api/translate';
  }

  static Future<SignResult?> translateFrames(List<List<double>> frames) async {
    try {
      final res = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'frames': frames}),
      ).timeout(const Duration(seconds: 4));

      if (res.statusCode == 200) {
        final data = jsonDecode(utf8.decode(res.bodyBytes));
        return SignResult.fromJson(data);
      } else {
        debugPrint("API Error: ${res.statusCode} -> ${res.body}");
        return null;
      }
    } catch (e) {
      debugPrint("Network failure calling backend: $e");
      return null;
    }
  }
}