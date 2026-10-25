import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';
import '../../../models/chat_message.dart';

/// Renders an individual chat bubble tailored for staff, deaf patient, or AI responses.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onSpeak;

  const MessageBubble({
    super.key,
    required this.message,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isStaff = message.sender == MessageSender.staff;
    final isDeaf = message.sender == MessageSender.deaf;

    // Sender-specific styling
    final alignment = isStaff
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    final bubbleColor = isStaff
        ? theme.colorScheme.primaryContainer
        : (isDeaf
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest);
    final textColor = isStaff
        ? theme.colorScheme.onPrimaryContainer
        : (isDeaf
            ? theme.colorScheme.onSecondaryContainer
            : theme.colorScheme.onSurfaceVariant);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _senderLabel(message.sender),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.outline,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                AppFormatters.formatTime(message.timestamp),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.78,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.type == MessageType.recognized) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.sign_language, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'ESL Recognized ${AppFormatters.formatConfidence(message.confidence)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  message.text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (onSpeak != null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.volume_up, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      tooltip: 'Speak message',
                      onPressed: onSpeak,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _senderLabel(MessageSender sender) {
    switch (sender) {
      case MessageSender.staff:
        return 'Hospital Staff';
      case MessageSender.deaf:
        return 'Patient (Sign)';
      case MessageSender.ai:
        return 'Fikir AI Assistant';
    }
  }
}
