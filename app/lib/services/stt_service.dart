import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Thin service wrapper over SpeechToText for speech recognition.
class SttService {
  final stt.SpeechToText _speechToText;
  bool _isAvailable = false;

  SttService({stt.SpeechToText? speechToText})
      : _speechToText = speechToText ?? stt.SpeechToText();

  bool get isAvailable => _isAvailable;
  bool get isListening => _speechToText.isListening;

  /// Initializes the speech recognition engine and requests microphone permissions.
  Future<bool> init({
    Function(String status)? onStatus,
    Function(dynamic error)? onError,
  }) async {
    try {
      _isAvailable = await _speechToText.initialize(
        onStatus: (status) {
          // TODO: Propagate listening status updates to UI state
          onStatus?.call(status);
        },
        onError: (errorNotification) {
          // TODO: Handle speech recognition error types and permission denials
          onError?.call(errorNotification);
        },
      );
      return _isAvailable;
    } catch (e) {
      // TODO: Log permission denial or microphone initialization errors
      _isAvailable = false;
      return false;
    }
  }

  /// Starts listening for speech input and invokes [onResult] with transcription.
  Future<void> listen({
    required Function(String recognizedWords) onResult,
    String? localeId,
  }) async {
    if (!_isAvailable) {
      final ready = await init();
      if (!ready) return;
    }

    // TODO: Add locale selector for Amharic (am_ET) or English (en_US)
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords);
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: localeId,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  /// Stops listening and commits recognized words.
  Future<void> stop() async {
    await _speechToText.stop();
  }

  /// Cancels speech listening session without committing words.
  Future<void> cancel() async {
    await _speechToText.cancel();
  }
}
