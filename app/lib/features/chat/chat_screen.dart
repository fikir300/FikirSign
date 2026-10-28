// app/lib/features/chat/chat_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/api_client.dart';

class ChatItem {
  final String sign;
  final String amharic;
  final double confidence;
  final DateTime time;
  final bool isUser;

  ChatItem({
    required this.sign,
    required this.amharic,
    required this.confidence,
    required this.time,
    required this.isUser,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatItem> _messages = [];
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();

  bool _isDarkMode = true;
  String _liveSign = "Watching signs...";
  String _liveAmharic = "ምልክት ይጠበቃል";
  String? _lastEmittedSign;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _messages.add(ChatItem(
      sign: "SYSTEM",
      amharic: "ሰላም! የኢትዮጵያ ምልክት ቋንቋ (EthSL) የቀጥታ ተርጓሚ ዝግጁ ነው። ምልክትዎን በካሜራው ፊት ያሳዩ።",
      confidence: 1.0,
      time: DateTime.now(),
      isUser: false,
    ));
  }

  void _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.85);
  }

  // Call this method whenever 30 frames are ready
  void onFramesCaptured(List<List<double>> frames) async {
    final result = await ApiClient.sendFrames(frames);
    if (result == null) return;

    setState(() {
      _liveSign = result.sign;
      _liveAmharic = result.amharic;
    });

    if (result.sign != "IDLE" && result.sign != _lastEmittedSign && result.confidence >= 0.60) {
      _lastEmittedSign = result.sign;

      setState(() {
        _messages.add(ChatItem(
          sign: result.sign,
          amharic: result.amharic,
          confidence: result.confidence,
          time: DateTime.now(),
          isUser: true,
        ));
      });

      _tts.speak(result.sign);

      Future.delayed(const Duration(milliseconds: 150), () {
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
    final isDark = _isDarkMode;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2024);

    return Theme(
      data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppTheme.olive.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.olive, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Fikir Signs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                  Text("EthSL • Conversational AI", style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5))),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: textColor),
              onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
              tooltip: "Toggle Light/Dark Theme",
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
            // Minimalist Live Status Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: surfaceColor,
              child: Row(
                children: [
                  Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: _liveSign == "IDLE" ? Colors.grey : AppTheme.lightOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _liveAmharic,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.olive),
                  ),
                  const Spacer(),
                  Text(
                    _liveSign,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.lightOrange),
                  ),
                ],
              ),
            ),

            // Chat Feed (Claude / ChatGPT style)
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!msg.isUser) ...[
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: AppTheme.olive,
                            child: const Icon(Icons.translate_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: msg.isUser ? AppTheme.lightOrange.withOpacity(0.12) : cardColor,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: msg.isUser ? AppTheme.lightOrange.withOpacity(0.35) : borderColor,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.amharic,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: msg.isUser ? AppTheme.lightOrange : textColor,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      msg.sign,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: textColor.withOpacity(0.55),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.olive.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        "${(msg.confidence * 100).toInt()}% match",
                                        style: const TextStyle(
                                            fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.olive),
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
      ),
    );
  }
}