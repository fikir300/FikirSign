import 'package:flutter/material.dart';
import '../../../models/phrase.dart';

/// Horizontal scroll list of quick suggestion chips for common hospital phrases.
class SuggestionChips extends StatelessWidget {
  final List<Phrase> suggestions;
  final ValueChanged<Phrase> onSelected;

  const SuggestionChips({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final phrase = suggestions[index];
          return ActionChip(
            avatar: const Icon(Icons.quickreply_outlined, size: 18),
            label: Text(
              '${phrase.en} / ${phrase.am}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: theme.colorScheme.surface,
            side: BorderSide(color: theme.colorScheme.outlineVariant),
            onPressed: () => onSelected(phrase),
          );
        },
      ),
    );
  }
}
