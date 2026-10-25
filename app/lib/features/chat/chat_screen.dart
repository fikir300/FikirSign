import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../data/phrase_repository.dart';
import '../../models/chat_message.dart';
import '../../models/phrase.dart';
import '../../services/stt_service.dart';
import '../../services/tts_service.dart';
import '../sign_input/sign_input_sheet.dart';
import 'widgets/composer_bar.dart';
import 'widgets/message_bubble.dart';
import 'widgets/suggestion_chips.dart';

/// Main conversation interface enabling bilingual communication between hospital staff and deaf patients.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _composerController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final PhraseRepository _phraseRepository = PhraseRepository();
  final TtsService _ttsService = TtsService();
  final SttService _sttService = SttService();

  List<ChatMessage> _messages = [];
  List<Phrase> _suggestedPhrases = [];
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final phrases = await _phraseRepository.loadPhrases();
    if (mounted) {
      setState(() {
        _suggestedPhrases = phrases;
        // Starter chat seed for demonstration
        _messages = [
          ChatMessage(
            id: 'msg_0',
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            sender: MessageSender.ai,
            type: MessageType.text,
            text: 'Welcome to FikirSign hospital interpreter session. You can speak, type, or use the camera for Ethiopian Sign Language.',
          ),
          ChatMessage(
            id: 'msg_1',
            timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
            sender: MessageSender.staff,
            type: MessageType.text,
            text: 'Hello, please take a seat. How can I help you today?',
          ),
          ChatMessage(
            id: 'msg_2',
            timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
            sender: MessageSender.deaf,
            type: MessageType.recognized,
            text: 'Where does it hurt? / የት ነው የሚያመዎት?',
            phraseId: 'p001',
            confidence: 0.94,
          ),
        ];
      });
    }
  }

  @override
  void dispose() {
    _composerController.dispose();
    _scrollController.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage({
    required String text,
    MessageSender sender = MessageSender.staff,
    MessageType type = MessageType.text,
    String? phraseId,
    double? confidence,
  }) {
    if (text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      timestamp: DateTime.now(),
      sender: sender,
      type: type,
      text: text.trim(),
      phraseId: phraseId,
      confidence: confidence,
    );

    setState(() {
      _messages.add(newMessage);
    });
    _composerController.clear();
    _scrollToBottom();
  }

  Future<void> _openSignCamera() async {
    final result = await SignInputSheet.show(context);
    if (result != null && mounted) {
      // Find matching phrase if available
      final matched = _phraseRepository.getPhraseById(result.phraseId);
      final text = matched != null
          ? '${matched.en} / ${matched.am}'
          : 'Recognized Sign Gesture (ID: ${result.phraseId})';

      _sendMessage(
        text: text,
        sender: MessageSender.deaf,
        type: MessageType.recognized,
        phraseId: result.phraseId,
        confidence: result.confidence,
      );
    }
  }

  Future<void> _toggleMic() async {
    if (_isListening) {
      await _sttService.stop();
      setState(() => _isListening = false);
    } else {
      setState(() => _isListening = true);
      await _sttService.listen(
        onResult: (spokenWords) {
          if (mounted) {
            setState(() {
              _composerController.text = spokenWords;
            });
          }
        },
      );
    }
  }

  void _handlePhraseSelected(Phrase phrase) {
    _sendMessage(
      text: '${phrase.en} / ${phrase.am}',
      sender: MessageSender.staff,
      type: MessageType.text,
      phraseId: phrase.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sign_language, size: 24),
            const SizedBox(width: 8),
            Text(AppConstants.appName, style: theme.textTheme.titleLarge),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book_outlined),
            tooltip: 'Phrase Library',
            onPressed: () async {
              final selected = await Navigator.of(context).pushNamed(
                AppConstants.routePhraseLibrary,
              );
              if (selected is Phrase && mounted) {
                _handlePhraseSelected(selected);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.rate_review_outlined),
            tooltip: 'Sign Feedback',
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeFeedback);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeSettings);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Message timeline
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return MessageBubble(
                  message: message,
                  onSpeak: () {
                    _ttsService.speak(message.text);
                  },
                );
              },
            ),
          ),

          // Suggestion chips row
          SuggestionChips(
            suggestions: _suggestedPhrases,
            onSelected: _handlePhraseSelected,
          ),

          // Composer input bar
          ComposerBar(
            controller: _composerController,
            isListening: _isListening,
            onSend: () => _sendMessage(text: _composerController.text),
            onSignInput: _openSignCamera,
            onMicToggle: _toggleMic,
          ),
        ],
      ),
    );
  }
}
