// lib/screens/fikir_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../theme/app_theme.dart';
import '../services/sign_api_service.dart';

class ChatTranslation {
  final String sign;
  final String amharic;
  final double confidence;
  final DateTime timestamp;
  final bool isUserGesture;

  ChatTranslation({
    required this.sign,
    required this.amharic,
    required this.confidence,
    required this.timestamp,
    this.isUserGesture = true,
  });
}

class FikirChatScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const FikirChatScreen({super.key, required this.onToggleTheme, required this.isDarkMode});

  @override
  State<FikirChatScreen> createState() => _FikirChatScreenState();
}

class _FikirChatScreenState extends State<FikirChatScreen> {
  final List<ChatTranslation> _messages = [];
  final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();
  
  String _activeLiveSign = "Watching camera...";
  String _activeLiveAmharic = "ምልክት ይጠበቃል";
  bool _isCameraActive = true;
  String? _lastEmittedSign;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _addInitialGreeting();
  }

  void _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.85);
  }

  void _addInitialGreeting() {
    _messages.add(ChatTranslation(
      sign: "HELLO",
      amharic: "ሰላም! የኢትዮጵያ ምልክት ቋንቋ (EthSL) ተርጓሚ ዝግጁ ነው። ምልክትዎን ያሳዩ።",
      confidence: 1.0,
      timestamp: DateTime.now(),
      isUserGesture: false,
    ));
  }

  // Call this method whenever MediaPipe yields 30 frames
  void handleNewGesture(SignResult result) {
    setState(() {
      _activeLiveSign = result.sign;
      _activeLiveAmharic = result.amharic;
    });

    if (result.sign != "IDLE" && result.sign != _lastEmittedSign && result.confidence >= 0.65) {
      _lastEmittedSign = result.sign;
      final newMsg = ChatTranslation(
        sign: result.sign,
        amharic: result.amharic,
        confidence: result.confidence,
        timestamp: DateTime.now(),
        isUserGesture: true,
      );

      setState(() {
        _messages.add(newMsg);
      });

      // Voice output
      _tts.speak(result.sign);

      // Scroll smoothly to bottom
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDarkMode;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2024);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.olive.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.translate_rounded, color: AppTheme.olive, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fikir Signs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                Text("EthSL • Real-time AI Assistant", style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: textColor),
            onPressed: widget.onToggleTheme,
            tooltip: "Toggle Theme",
          ),
          IconButton(
            icon: Icon(_isCameraActive ? Icons.videocam_rounded : Icons.videocam_off_rounded,
                color: _isCameraActive ? AppTheme.olive : Colors.grey),
            onPressed: () => setState(() => _isCameraActive = !_isCameraActive),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: borderColor, height: 1),
        ),
      ),
      body: Column(
        children: [
          // Sleek Floating Live Detection Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: surfaceColor,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _activeLiveSign == "IDLE" ? Colors.grey : AppTheme.lightOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  "LIVE: ",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.4)),
                ),
                Text(
                  _activeLiveAmharic,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.olive),
                ),
                const Spacer(),
                Text(
                  _activeLiveSign,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.lightOrange),
                ),
              ],
            ),
          ),

          // Conversational AI Feed
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: msg.isUserGesture ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!msg.isUserGesture) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.olive,
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: msg.isUserGesture ? AppTheme.lightOrange.withOpacity(0.12) : cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: msg.isUserGesture ? AppTheme.lightOrange.withOpacity(0.3) : borderColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                msg.isUserGesture ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.amharic,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: msg.isUserGesture ? AppTheme.lightOrange : textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    msg.sign,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textColor.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.olive.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "${(msg.confidence * 100).toInt()}% match",
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.olive),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                                    color: AppTheme.olive,
                                    onPressed: () => _tts.speak(msg.sign),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}