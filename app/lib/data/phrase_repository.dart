import 'dart:convert';
import 'package:flutter/services.dart';
import '../core/constants/app_constants.dart';
import '../models/phrase.dart';

/// Repository responsible for loading and querying phrases from local JSON assets.
class PhraseRepository {
  List<Phrase> _cachedPhrases = const [];

  /// Returns cached phrases or loads them from asset bundle if empty.
  Future<List<Phrase>> loadPhrases() async {
    if (_cachedPhrases.isNotEmpty) {
      return _cachedPhrases;
    }

    try {
      final jsonString = await rootBundle.loadString(AppConstants.phrasesAssetPath);
      final dynamic decoded = jsonDecode(jsonString);

      if (decoded is List) {
        _cachedPhrases = decoded
            .map((item) => Phrase.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return _cachedPhrases;
    } catch (e) {
      // TODO: Add telemetry or structured logging for asset loading failures
      return const [];
    }
  }

  /// Synchronously returns already loaded phrases.
  List<Phrase> get phrases => _cachedPhrases;

  /// Filters cached phrases by medical category.
  List<Phrase> getPhrasesByCategory(String category) {
    // TODO: Support multi-category filtering or tag matching
    return _cachedPhrases
        .where((p) => p.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Searches phrases by matching English or Amharic text.
  List<Phrase> searchPhrases(String query) {
    // TODO: Add phonetic/fuzzy search for Amharic Fidel queries
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return _cachedPhrases;

    return _cachedPhrases
        .where((p) =>
            p.en.toLowerCase().contains(clean) ||
            p.am.toLowerCase().contains(clean))
        .toList();
  }

  /// Finds a specific phrase by its ID.
  Phrase? getPhraseById(String id) {
    // TODO: Add fast map-based index if phrase database grows
    try {
      return _cachedPhrases.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}
