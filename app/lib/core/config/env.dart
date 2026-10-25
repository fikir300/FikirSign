import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads environment variables loaded from the local `.env` file.
class Env {
  Env._();

  /// Base URL for backend API requests (AWS API Gateway or local proxy).
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ??
      'https://example.execute-api.region.amazonaws.com/prod';

  /// API key passed in `x-api-key` header for authorized requests.
  static String get apiKey => dotenv.env['API_KEY'] ?? 'changeme';

  /// Whether to use local mock API data instead of actual network calls.
  static bool get useMockApi {
    final value = dotenv.env['USE_MOCK_API']?.toLowerCase().trim();
    return value == 'true' || value == '1';
  }
}
