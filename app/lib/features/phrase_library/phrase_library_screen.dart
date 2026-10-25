import 'package:flutter/material.dart';
import '../../data/phrase_repository.dart';
import '../../models/phrase.dart';
import '../../services/tts_service.dart';

/// Screen displaying catalog of clinical and daily Ethiopian Sign Language phrases.
class PhraseLibraryScreen extends StatefulWidget {
  const PhraseLibraryScreen({super.key});

  @override
  State<PhraseLibraryScreen> createState() => _PhraseLibraryScreenState();
}

class _PhraseLibraryScreenState extends State<PhraseLibraryScreen> {
  final PhraseRepository _phraseRepository = PhraseRepository();
  final TtsService _ttsService = TtsService();
  final TextEditingController _searchController = TextEditingController();

  List<Phrase> _phrases = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadPhrases();
  }

  Future<void> _loadPhrases() async {
    final list = await _phraseRepository.loadPhrases();
    if (mounted) {
      setState(() {
        _phrases = list;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  List<Phrase> get _filteredPhrases {
    var result = _phrases;
    if (_selectedCategory != 'all') {
      result = result.where((p) => p.category == _selectedCategory).toList();
    }
    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((p) =>
          p.en.toLowerCase().contains(query) ||
          p.am.toLowerCase().contains(query)).toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Phrase Library'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search English or Amharic phrases...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                // Category selector
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      'all',
                      'symptoms',
                      'general',
                      'medical_history',
                      'examination',
                      'pharmacy',
                    ].map((cat) {
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(cat.replaceAll('_', ' ').toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() => _selectedCategory = cat);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 8),

                // Phrases list
                Expanded(
                  child: _filteredPhrases.isEmpty
                      ? Center(
                          child: Text(
                            'No phrases found',
                            style: theme.textTheme.titleMedium,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredPhrases.length,
                          separatorBuilder: (_, _) => const Divider(),
                          itemBuilder: (context, index) {
                            final phrase = _filteredPhrases[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              title: Text(
                                phrase.en,
                                style: theme.textTheme.titleMedium,
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  phrase.am,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.volume_up_outlined),
                                tooltip: 'Listen pronunciation',
                                onPressed: () {
                                  // Speak Amharic text via TTS
                                  _ttsService.speak(phrase.am, language: 'am-ET');
                                },
                              ),
                              onTap: () {
                                // TODO: Return phrase to chat or insert into composer
                                Navigator.of(context).pop(phrase);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
