import 'package:flutter/material.dart';
import '../../services/recognition_service.dart';

/// Modal bottom sheet placeholder for capturing Ethiopian Sign Language video input.
class SignInputSheet extends StatefulWidget {
  final ValueChanged<RecognitionResult>? onSignRecognized;

  const SignInputSheet({
    super.key,
    this.onSignRecognized,
  });

  /// Helper to display the sheet from any context.
  static Future<RecognitionResult?> show(BuildContext context) {
    return showModalBottomSheet<RecognitionResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const SignInputSheet(),
    );
  }

  @override
  State<SignInputSheet> createState() => _SignInputSheetState();
}

class _SignInputSheetState extends State<SignInputSheet> {
  final RecognitionService _recognitionService = StubRecognitionService();
  bool _isRecognizing = false;

  @override
  void dispose() {
    _recognitionService.dispose();
    super.dispose();
  }

  Future<void> _handleCapture() async {
    setState(() => _isRecognizing = true);

    // TODO: Connect actual CameraController feed and extract landmark coordinates
    final result = await _recognitionService.recognizeSign(null);

    if (mounted) {
      setState(() => _isRecognizing = false);
      widget.onSignRecognized?.call(result);
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(4),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ethiopian Sign Input',
                  style: theme.textTheme.titleLarge,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const Divider(),

          // Camera Viewport Placeholder
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withAlpha(200),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Position hands & face inside frame',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'TODO: Stream CameraController frames to ESL model',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  if (_isRecognizing)
                    Container(
                      color: Colors.black54,
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Recognizing Ethiopian Sign...',
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Action controls
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.auto_awesome),
                label: Text(_isRecognizing ? 'Processing...' : 'Capture & Recognize Sign'),
                onPressed: _isRecognizing ? null : _handleCapture,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
