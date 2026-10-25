import 'package:intl/intl.dart';

/// Formatting helpers for timestamps and confidence scores.
class AppFormatters {
  AppFormatters._();

  /// Formats a [DateTime] into a localized time string (e.g. 10:45 AM).
  static String formatTime(DateTime dateTime) {
    return DateFormat.jm().format(dateTime);
  }

  /// Formats a confidence score (0.0 to 1.0) into a percentage display string.
  static String formatConfidence(double? confidence) {
    if (confidence == null) return '';
    return '${(confidence * 100).toStringAsFixed(0)}%';
  }
}
