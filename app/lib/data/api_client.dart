// app/lib/data/api_client.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';

class PredictionResult {
  final String sign;
  final String amharic;
  final double confidence;
  final List<dynamic> top3;

  PredictionResult({
    required this.sign,
    required this.amharic,
    required this.confidence,
    required this.top3,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      sign: json['sign'] ?? 'IDLE',
      amharic: json['amharic'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      top3: json['top3'] ?? [],
    );
  }
}

class ApiClient {
  static Future<PredictionResult?> sendFrames(List<List<double>> frames) async {
    try {
      final url = Uri.parse(Env.backendUrl);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'frames': frames}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return PredictionResult.fromJson(data);
      } else {
        debugPrint("Backend responded with error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      debugPrint("Network error calling ${Env.backendUrl}: $e");
      return null;
    }
  }
}