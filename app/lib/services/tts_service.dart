import 'package:flutter_tts/flutter_tts.dart';

/// Thin service wrapper over FlutterTts for text-to-speech synthesis.
class TtsService {
  final FlutterTts _flutterTts;
  bool _isInitialized = false;

  TtsService({FlutterTts? flutterTts}) : _flutterTts = flutterTts ?? FlutterTts();

  /// Initializes TTS configuration and voice parameters.
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Default to Amharic if supported on device, fallback to English
      await _flutterTts.setLanguage('am-ET');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isInitialized = true;
    } catch (e) {
      // TODO: Fallback to en-US when am-ET voice is unavailable on device engine
      await _flutterTts.setLanguage('en-US');
      _isInitialized = true;
    }
  }

  /// Synthesizes and plays the provided text aloud.
  Future<void> speak(String text, {String? language}) async {
    if (!_isInitialized) {
      await init();
    }
    if (language != null) {
      await _flutterTts.setLanguage(language);
    }
    // TODO: Handle TTS completion callbacks and audio interruption events
    await _flutterTts.speak(text);
  }

  /// Stops current speech output.
  Future<void> stop() async {
    await _flutterTts.stop();
  }

  /// Releases TTS native resources.
  void dispose() {
    // TODO: Add cancellation or listener cleanup if listeners are attached
    _flutterTts.stop();
  }
}
