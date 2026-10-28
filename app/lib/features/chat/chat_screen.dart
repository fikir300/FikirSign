// app/lib/features/chat/chat_screen.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/api_client.dart';

class ChatMessageItem {
  final String englishText;
  final String amharicText;
  final double confidence;
  final DateTime timestamp;
  final bool isUser;
  final String inputType; // 'sign', 'text', 'voice', or 'system'

  ChatMessageItem({
    required this.englishText,
    required this.amharicText,
    required this.confidence,
    required this.timestamp,
    required this.isUser,
    required this.inputType,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessageItem> _messages = [];
  final List<String> _historyLog = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FlutterTts _tts = FlutterTts();

  bool _isDarkMode = true;
  bool _isCameraModalOpen = false;
  bool _isRecordingSign = false;
  int _recordCountdown = 0;

  // Active status strip
  String _activeSign = "Standby";
  String _activeAmharic = "ምልክት ይጠበቃል";

  @override
  void initState() {
    super.initState();
    _initTTS();
    _addWelcomeMessage();
  }

  void _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.85);
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessageItem(
      englishText: "Welcome to Fikir Signs! I am your Ethiopian Sign Language (EthSL) AI translator. You can sign with your camera, type, or speak below.",
      amharicText: "እንኳን ወደ ፍቅር ሳይንስ በደህና መጡ! የቀጥታ ተርጓሚ ዝግጁ ነው።",
      confidence: 1.0,
      timestamp: DateTime.now(),
      isUser: false,
      inputType: 'system',
    ));
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  void _submitText(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessageItem(
        englishText: clean,
        amharicText: "",
        confidence: 1.0,
        timestamp: DateTime.now(),
        isUser: true,
        inputType: 'text',
      ));
    });

    _scrollToBottom();

    // AI Assistant response
    Future.delayed(const Duration(milliseconds: 600), () {
      setState(() {
        _messages.add(ChatMessageItem(
          englishText: "Received: \"$clean\". You can perform the corresponding sign in front of the camera.",
          amharicText: "ተቀብለናል፡ በካሜራው ፊት ምልክቱን ማሳየት ይችላሉ።",
          confidence: 1.0,
          timestamp: DateTime.now(),
          isUser: false,
          inputType: 'system',
        ));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
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

  // ---------------------------------------------------------------------------
  // SIGN INGESTION: Sends 30 frames to Backend & updates chat
  // ---------------------------------------------------------------------------
  Future<void> _processSignFrames(List<List<double>> frames) async {
    setState(() {
      _activeSign = "Analyzing gesture...";
      _activeAmharic = "በመተንተን ላይ...";
    });

    final result = await ApiClient.sendFrames(frames);

    if (result != null && result.sign != "IDLE") {
      setState(() {
        _activeSign = result.sign;
        _activeAmharic = result.amharic;

        _messages.add(ChatMessageItem(
          englishText: result.sign,
          amharicText: result.amharic,
          confidence: result.confidence,
          timestamp: DateTime.now(),
          isUser: true,
          inputType: 'sign',
        ));

        _historyLog.insert(0, "${result.sign} (${result.amharic}) — ${(result.confidence * 100).toInt()}% match");
      });

      _speak(result.sign);
      _scrollToBottom();
    } else {
      setState(() {
        _activeSign = "Resting / Idle";
        _activeAmharic = "ምንም ምልክት የለም";
      });
    }
  }

  // ---------------------------------------------------------------------------
  // AUTH MODAL (Login & Sign Up)
  // ---------------------------------------------------------------------------
  void _openAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _AuthModal(),
    );
  }

  // ---------------------------------------------------------------------------
  // CAMERA STUDIO MODAL (Live Sign Capture & Test Trigger)
  // ---------------------------------------------------------------------------
  void _openCameraStudio() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final isDark = _isDarkMode;
          final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
          final txtColor = isDark ? Colors.white : Colors.black87;

          return Container(
            height: MediaQuery.of(context).size.height * 0.75,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: isDark ? AppTheme.darkBorder : AppTheme.lightBorder),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Modal Handle
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.videocam_rounded, color: AppTheme.lightOrange),
                        const SizedBox(width: 8),
                        Text("EthSL Sign Studio", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: txtColor)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const SizedBox(height: 12),

                // Simulated Viewfinder Box
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.olive.withOpacity(0.4)),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.accessibility_new_rounded, size: 70, color: AppTheme.olive.withOpacity(0.6)),
                            const SizedBox(height: 12),
                            Text("Position your head, shoulders & hands in view", style: TextStyle(fontSize: 13, color: txtColor.withOpacity(0.6))),
                            const SizedBox(height: 4),
                            Text("Status: $_activeSign ($_activeAmharic)", style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.lightOrange)),
                          ],
                        ),
                        if (_isRecordingSign)
                          Container(
                            color: Colors.black54,
                            alignment: Alignment.center,
                            child: Text("Recording Gesture...\n$_recordCountdown", textAlign: TextAlign.center, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.lightOrangeSoft)),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    // Trigger Camera Recording (30 frames)
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.lightOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.fiber_manual_record_rounded, color: Colors.white),
                        label: const Text("Capture 30-Frame Sign", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: _isRecordingSign ? null : () async {
                          setSheetState(() {
                            _isRecordingSign = true;
                            _recordCountdown = 3;
                          });

                          // 30-frame simulated collector stream
                          final dummyFrames = List.generate(30, (_) => List.generate(144, (_) => Random().nextDouble() * 0.15));
                          await Future.delayed(const Duration(seconds: 1));
                          
                          setSheetState(() => _isRecordingSign = false);
                          Navigator.pop(context);

                          // Process with backend
                          await _processSignFrames(dummyFrames);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),

                    // Test with a Preset Verified Gesture
                    Expanded(
                      flex: 1,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.olive,
                          side: const BorderSide(color: AppTheme.olive),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: const Icon(Icons.bolt_rounded, size: 18),
                        label: const Text("Test Sign", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: () async {
                          Navigator.pop(context);
                          // Generates test gesture
                          final testGesture = List.generate(30, (_) => List.generate(144, (_) => Random().nextDouble() * 0.1));
                          await _processSignFrames(testGesture);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode;
    final surfaceColor = isDark ? AppTheme.darkSurface : AppTheme.lightSurface;
    final cardColor = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final borderColor = isDark ? AppTheme.darkBorder : AppTheme.lightBorder;
    final textColor = isDark ? Colors.white : const Color(0xFF1E2024);

    return Scaffold(
      // -----------------------------------------------------------------------
      // LEFT DRAWER (Profile & History)
      // -----------------------------------------------------------------------
      drawer: Drawer(
        backgroundColor: cardColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.oliveDark),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: AppTheme.lightOrange,
                child: Icon(Icons.person_rounded, color: Colors.white, size: 36),
              ),
              accountName: const Text("Healthcare Worker / Patient", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              accountEmail: const Text("patient.user@fikirsigns.et", style: TextStyle(color: Colors.white70, fontSize: 12)),
            ),
            ListTile(
              leading: const Icon(Icons.history_rounded, color: AppTheme.lightOrange),
              title: Text("Translation History", style: TextStyle(color: textColor, fontWeight: FontWeight.w600)),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.lightOrange.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Text("${_historyLog.length}", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.lightOrange)),
              ),
            ),
            Expanded(
              child: _historyLog.isEmpty
                  ? Center(child: Text("No signs recorded yet today.", style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 12)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _historyLog.length,
                      separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(_historyLog[i], style: TextStyle(fontSize: 13, color: textColor.withOpacity(0.8))),
                      ),
                    ),
            ),
            Divider(color: borderColor),
            ListTile(
              leading: const Icon(Icons.medical_services_outlined, color: AppTheme.olive),
              title: Text("Medical Dictionary (30 signs)", style: TextStyle(color: textColor, fontSize: 14)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.lock_outline_rounded, color: textColor.withOpacity(0.5)),
              title: Text("Sign Out", style: TextStyle(color: textColor.withOpacity(0.5), fontSize: 14)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),

      // -----------------------------------------------------------------------
      // APP BAR (English, Theme Toggle, Top-Right Sign In)
      // -----------------------------------------------------------------------
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(color: AppTheme.olive.withOpacity(0.18), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.auto_awesome_rounded, color: AppTheme.olive, size: 20),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Fikir Signs", style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: textColor)),
                Text("EthSL • Real-Time AI Assistant", style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5))),
              ],
            ),
          ],
        ),
        actions: [
          // Theme Toggle
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: textColor),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            tooltip: "Toggle Light / Dark Mode",
          ),
          const SizedBox(width: 4),

          // Top-Right Sign In Button
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.login_rounded, size: 16),
              label: const Text("Sign In", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              onPressed: _openAuthModal,
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: borderColor, height: 1)),
      ),

      // -----------------------------------------------------------------------
      // MAIN BODY: Feed + Bottom Multimodal Bar
      // -----------------------------------------------------------------------
      body: Column(
        children: [
          // Live Real-Time Banner Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: surfaceColor,
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: _activeSign == "Standby" || _activeSign.contains("Resting") ? Colors.grey : AppTheme.lightOrange, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text("STATUS: ", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.4))),
                Text(_activeSign, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.lightOrange)),
                const Spacer(),
                Text(_activeAmharic, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.olive)),
              ],
            ),
          ),

          // Conversational AI Message Feed
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
                    mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!msg.isUser) ...[
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: AppTheme.olive,
                          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: msg.isUser ? AppTheme.lightOrange.withOpacity(0.12) : cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: msg.isUser ? AppTheme.lightOrange.withOpacity(0.35) : borderColor),
                          ),
                          child: Column(
                            crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              // English Text / Sign Label
                              Text(msg.englishText, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: msg.isUser ? AppTheme.lightOrange : textColor)),
                              
                              // Amharic Translation Subtitle
                              if (msg.amharicText.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(msg.amharicText, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.olive)),
                              ],

                              const SizedBox(height: 6),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (msg.inputType == 'sign') ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: AppTheme.olive.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                                      child: Text("${(msg.confidence * 100).toInt()}% match", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.olive)),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  Text(
                                    "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(fontSize: 10, color: textColor.withOpacity(0.4)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, size: 16),
                                    color: AppTheme.olive,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _speak(msg.englishText),
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

          // -------------------------------------------------------------------
          // BOTTOM CHAT BAR: Write, Speak, or Camera Sign
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                // 1. Camera / Sign Studio Button
                Container(
                  decoration: BoxDecoration(color: AppTheme.lightOrange.withOpacity(0.15), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.videocam_rounded, color: AppTheme.lightOrange),
                    tooltip: "Sign with Camera",
                    onPressed: _openCameraStudio,
                  ),
                ),
                const SizedBox(width: 8),

                // 2. Text Input Field
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: borderColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _textController,
                      style: TextStyle(color: textColor, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "Type a sign, medical question, or phrase...",
                        hintStyle: TextStyle(color: textColor.withOpacity(0.4), fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: _submitText,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // 3. Microphone Button
                Container(
                  decoration: BoxDecoration(color: AppTheme.olive.withOpacity(0.15), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.mic_rounded, color: AppTheme.olive),
                    tooltip: "Speak (Voice Input)",
                    onPressed: () => _submitText("I need to see the doctor"),
                  ),
                ),
                const SizedBox(width: 6),

                // 4. Send Button
                Container(
                  decoration: const BoxDecoration(color: AppTheme.lightOrange, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                    tooltip: "Send",
                    onPressed: () => _submitText(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// AUTHENTICATION MODAL (Login & Sign Up with Claude Theme)
// -----------------------------------------------------------------------------
class _AuthModal extends StatefulWidget {
  const _AuthModal();

  @override
  State<_AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<_AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final txtColor = isDark ? Colors.white : Colors.black87;

    return Container(
      height: 480,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          TabBar(
            controller: _tabController,
            labelColor: AppTheme.lightOrange,
            unselectedLabelColor: txtColor.withOpacity(0.5),
            indicatorColor: AppTheme.lightOrange,
            tabs: const [Tab(text: "Sign In"), Tab(text: "Create Account")],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Login Tab
                Column(
                  children: [
                    TextField(decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 14),
                    TextField(obscureText: true, decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lightOrange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                // Sign Up Tab
                Column(
                  children: [
                    TextField(decoration: InputDecoration(labelText: "Full Name", prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 12),
                    TextField(obscureText: true, decoration: InputDecoration(labelText: "Create Password", prefixIcon: const Icon(Icons.lock_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.olive, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Create Free Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}