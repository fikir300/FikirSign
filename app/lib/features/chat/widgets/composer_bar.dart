import 'package:flutter/material.dart';

/// Bottom message composer supporting text input, sign camera trigger, and voice STT.
class ComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isListening;
  final VoidCallback onSend;
  final VoidCallback onSignInput;
  final VoidCallback onMicToggle;

  const ComposerBar({
    super.key,
    required this.controller,
    required this.isListening,
    required this.onSend,
    required this.onSignInput,
    required this.onMicToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Sign camera trigger
            IconButton(
              icon: const Icon(Icons.videocam_rounded),
              tooltip: 'Sign Camera Input',
              color: theme.colorScheme.primary,
              onPressed: onSignInput,
            ),

            // Speech-to-text microphone button
            IconButton(
              icon: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: isListening ? Colors.red : theme.colorScheme.primary,
              ),
              tooltip: isListening ? 'Stop Listening' : 'Voice Input',
              onPressed: onMicToggle,
            ),

            // Text input
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Type message or sign response...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Send button
            IconButton.filled(
              icon: const Icon(Icons.send_rounded),
              tooltip: 'Send',
              onPressed: onSend,
            ),
          ],
        ),
      ),
    );
  }
}
