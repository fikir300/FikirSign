/// Result returned by Ethiopian Sign Language recognition processing.
class RecognitionResult {
  final String phraseId;
  final double confidence;

  const RecognitionResult({
    required this.phraseId,
    required this.confidence,
  });

  Map<String, dynamic> toMap() {
    return {
      'phraseId': phraseId,
      'confidence': confidence,
    };
  }
}

/// Abstract contract for Ethiopian Sign Language recognition services.
abstract class RecognitionService {
  /// Processes camera video frames / landmarks and returns recognized phrase and confidence.
  Future<RecognitionResult> recognizeSign(dynamic inputData);

  void dispose();
}

/// Stub implementation of [RecognitionService] for early UI testing and prototyping.
class StubRecognitionService implements RecognitionService {
  @override
  Future<RecognitionResult> recognizeSign(dynamic inputData) async {
    // TODO: Integrate on-device MediaPipe landmark detector and TFLite model
    // or forward landmark sequence to the backend POST /match endpoint.
    await Future.delayed(const Duration(milliseconds: 500));

    return const RecognitionResult(
      phraseId: 'p001',
      confidence: 0.92,
    );
  }

  @override
  void dispose() {
    // TODO: Clean up ML interpreters or camera streams when implemented
  }
}
