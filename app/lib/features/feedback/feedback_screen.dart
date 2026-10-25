import 'package:flutter/material.dart';
import '../../data/api_client.dart';

/// Screen allowing hospital staff or deaf patients to report translation accuracy and sign feedback.
class FeedbackScreen extends StatefulWidget {
  final String? initialPhraseId;

  const FeedbackScreen({
    super.key,
    this.initialPhraseId,
  });

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final ApiClient _apiClient = ApiClient();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _phraseIdController = TextEditingController();

  String _rating = 'accurate';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhraseId != null) {
      _phraseIdController.text = widget.initialPhraseId!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _phraseIdController.dispose();
    _apiClient.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    setState(() => _isSubmitting = true);

    // TODO: Include device metadata and landmark confidence payload if reporting a match
    final payload = {
      'phraseId': _phraseIdController.text.trim(),
      'rating': _rating,
      'notes': _notesController.text.trim(),
      'submittedAt': DateTime.now().toIso8601String(),
    };

    final result = await _apiClient.postFeedback(payload);

    if (mounted) {
      setState(() => _isSubmitting = false);
      final hasError = result.containsKey('error');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasError
                ? 'Submission issue: ${result['error']}'
                : 'Thank you! Your feedback helps improve ESL accuracy.',
          ),
        ),
      );

      if (!hasError) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Accuracy Feedback'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help Improve Ethiopian Sign Translation',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your observations help medical staff and deaf patients communicate with higher fidelity.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
            const SizedBox(height: 24),

            // Phrase Reference
            Text('Phrase ID or Topic', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _phraseIdController,
              decoration: InputDecoration(
                hintText: 'e.g. p001 or "Where does it hurt?"',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Rating
            Text('Recognition Quality', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'accurate', label: Text('Accurate')),
                ButtonSegment(value: 'partial', label: Text('Partially Right')),
                ButtonSegment(value: 'incorrect', label: Text('Incorrect')),
              ],
              selected: {_rating},
              onSelectionChanged: (set) {
                setState(() => _rating = set.first);
              },
            ),
            const SizedBox(height: 20),

            // Notes
            Text('Observations / Correction Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe how the gesture was performed or how the Amharic translation should read...',
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.send),
                label: Text(_isSubmitting ? 'Submitting...' : 'Send Feedback'),
                onPressed: _isSubmitting ? null : _submitFeedback,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
