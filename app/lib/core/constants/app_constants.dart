/// Application-wide constants including route paths, timeouts, and headers.
class AppConstants {
  AppConstants._();

  static const String appName = 'FikirSign';
  static const Duration apiTimeout = Duration(seconds: 3);
  static const String apiKeyHeader = 'x-api-key';
  static const String phrasesAssetPath = 'assets/phrases.json';

  // Navigation Routes
  static const String routeConsent = '/consent';
  static const String routeChat = '/chat';
  static const String routePhraseLibrary = '/phrase-library';
  static const String routeFeedback = '/feedback';
  static const String routeSettings = '/settings';
}
