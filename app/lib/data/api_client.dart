import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/env.dart';
import '../core/constants/app_constants.dart';

/// HTTP client for interacting with the FikirSign backend services.
class ApiClient {
  final http.Client _httpClient;

  ApiClient({http.Client? httpClient}) : _httpClient = httpClient ?? http.Client();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        AppConstants.apiKeyHeader: Env.apiKey,
      };

  /// POST /match: Submits sign landmarks or speech input to receive matched phrase & confidence.
  Future<Map<String, dynamic>> postMatch(Map<String, dynamic> payload) async {
    if (Env.useMockApi) {
      // Return simulated match result in mock mode
      await Future.delayed(const Duration(milliseconds: 300));
      return {
        'phraseId': payload['phraseId'] ?? 'p001',
        'confidence': 0.94,
        'matchedText': 'Where does it hurt?',
        'amharicText': 'የት ነው የሚያመዎት?',
        'status': 'mock_success',
      };
    }

    final url = Uri.parse('${Env.apiBaseUrl}/match');
    try {
      final response = await _httpClient
          .post(
            url,
            headers: _headers,
            body: jsonEncode(payload),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // TODO: Handle HTTP error status codes and error payload parsing
        return {
          'error': 'Server error: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      // TODO: Handle network timeouts, connection drops, and offline states
      return {
        'error': 'Network error: $e',
      };
    }
  }

  /// POST /feedback: Submits user feedback or correction for a recognized sign or phrase.
  Future<Map<String, dynamic>> postFeedback(Map<String, dynamic> feedback) async {
    if (Env.useMockApi) {
      // Return simulated feedback response in mock mode
      await Future.delayed(const Duration(milliseconds: 200));
      return {
        'success': true,
        'message': 'Feedback accepted in mock mode',
      };
    }

    final url = Uri.parse('${Env.apiBaseUrl}/feedback');
    try {
      final response = await _httpClient
          .post(
            url,
            headers: _headers,
            body: jsonEncode(feedback),
          )
          .timeout(AppConstants.apiTimeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        // TODO: Implement retry logic or offline queueing for feedback
        return {
          'error': 'Server error: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      // TODO: Queue feedback locally when offline
      return {
        'error': 'Network error: $e',
      };
    }
  }

  void dispose() {
    _httpClient.close();
  }
}
