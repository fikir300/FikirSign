// app/lib/features/chat/chat_screen.dart
// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:async';
import 'dart:convert';
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/api_client.dart';

class ChatMessageItem {
  final String englishText;
  final String amharicText;
  final double confidence;
  final DateTime timestamp;
  final String sender; // 'Staff (Hearing)', 'Patient (Deaf)', or 'System'
  final String type;   // 'sign', 'voice', 'text', or 'system'

  ChatMessageItem({
    required this.englishText,
    required this.amharicText,
    required this.confidence,
    required this.timestamp,
    required this.sender,
    required this.type,
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

  // User Profile State
  bool _isDarkMode = true;
  String _userName = "Staff Member";
  String _userEmail = "staff@hospital.et";
  bool _isLoggedIn = false;

  // Status Bar
  String _statusSign = "Standby";
  String _statusAmharic = "ዝግጁ";
  bool _isListeningVoice = false;

  @override
  void initState() {
    super.initState();
    _initTTS();
    _addSystemGreeting();
  }

  void _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.85);
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      await _tts.speak(text);
    }
  }

  void _addSystemGreeting() {
    _messages.add(ChatMessageItem(
      englishText: "Communication Bridge Active. Staff can speak or type in English. Patients can sign using the camera.",
      amharicText: "የመገናኛ ድልድዩ ተጀምሯል። የህክምና ባለሙያው በድምጽ ወይም በጽሁፍ፣ ታካሚው በምልክት ቋንቋ ማሳየት ይችላሉ።",
      confidence: 1.0,
      timestamp: DateTime.now(),
      sender: "System",
      type: "system",
    ));
  }

  // ---------------------------------------------------------------------------
  // REAL VOICE INPUT (Web Speech API via Chrome)
  // ---------------------------------------------------------------------------
  void _startVoiceInput() {
    setState(() => _isListeningVoice = true);

    try {
      js.context.callMethod('startNativeVoiceDictation', [
        (spokenText) {
          if (mounted && spokenText != null && spokenText.toString().trim().isNotEmpty) {
            setState(() => _isListeningVoice = false);
            _submitStaffMessage(spokenText.toString().trim(), isVoice: true);
          }
        },
        (errorMsg) {
          if (mounted) {
            setState(() => _isListeningVoice = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Voice Error: $errorMsg")),
            );
          }
        }
      ]);
    } catch (e) {
      setState(() => _isListeningVoice = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Voice recognition is available on Google Chrome.")),
      );
    }
  }

  void _submitStaffMessage(String text, {bool isVoice = false}) {
    final clean = text.trim();
    if (clean.isEmpty) return;
    _textController.clear();

    setState(() {
      _messages.add(ChatMessageItem(
        englishText: clean,
        amharicText: "Staff Message (የባለሙያው መልእክት)",
        confidence: 1.0,
        timestamp: DateTime.now(),
        sender: "Staff (Hearing)",
        type: isVoice ? "voice" : "text",
      ));
    });
    _scrollToBottom();
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
  // PROCESS ETHSL SIGN FROM AWS
  // ---------------------------------------------------------------------------
  Future<void> _processSignFromAWS(List<List<double>> frames) async {
    setState(() {
      _statusSign = "Analyzing gesture on AWS...";
      _statusAmharic = "በመተንተን ላይ...";
    });

    final result = await ApiClient.sendFrames(frames);

    if (result != null) {
      final signName = result.sign;
      final amharicName = result.amharic.isNotEmpty ? result.amharic : "ምልክት";
      final conf = result.confidence;

      setState(() {
        _statusSign = signName;
        _statusAmharic = amharicName;

        _messages.add(ChatMessageItem(
          englishText: signName,
          amharicText: amharicName,
          confidence: conf,
          timestamp: DateTime.now(),
          sender: "Patient (Deaf)",
          type: "sign",
        ));

        _historyLog.insert(
          0,
          "$signName ($amharicName) — ${(conf * 100).toInt()}% [${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}]",
        );
      });

      if (signName != "IDLE") {
        _speak(signName);
      }
      _scrollToBottom();
    } else {
      setState(() {
        _statusSign = "Connection Error";
        _statusAmharic = "የግንኙነት ችግር";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not connect to backend. Please ensure 'node server.js' is running.")),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // CAMERA STUDIO MODAL
  // ---------------------------------------------------------------------------
  void _openCameraStudio() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _isDarkMode ? AppTheme.darkCard : AppTheme.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.privacy_tip_outlined, color: AppTheme.lightOrange),
            SizedBox(width: 10),
            Text("Camera Permission", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          "Fikir Signs accesses your webcam to track EthSL hand and body skeleton joints in real-time.\n\n"
          "• Only numerical coordinate points are transmitted to AWS.\n"
          "• No raw video is ever stored or saved.\n\n"
          "Do you consent to activate the camera for translation?",
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.olive,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _launchRealCameraCapture();
            },
            child: const Text("Allow & Start Camera", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _launchRealCameraCapture() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MediaPipeCameraSheet(
        isDarkMode: _isDarkMode,
        onCaptureFinished: (frames) {
          Navigator.pop(ctx);
          _processSignFromAWS(frames);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AUTH MODAL
  // ---------------------------------------------------------------------------
  void _openAuthModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _AuthModal(
        onSuccess: (name, email) {
          setState(() {
            _userName = name;
            _userEmail = email;
            _isLoggedIn = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Profile active: $_userName")),
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
      drawer: Drawer(
        backgroundColor: cardColor,
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: AppTheme.oliveDark),
              currentAccountPicture: CircleAvatar(
                backgroundColor: AppTheme.lightOrange,
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : "U",
                  style: const TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              accountName: Text(_userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              accountEmail: Text(_userEmail, style: const TextStyle(color: Colors.white70, fontSize: 12)),
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
                  ? Center(child: Text("No signs recorded yet.", style: TextStyle(color: textColor.withOpacity(0.4), fontSize: 13)))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _historyLog.length,
                      separatorBuilder: (_, __) => Divider(color: borderColor, height: 1),
                      itemBuilder: (ctx, i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(_historyLog[i], style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.85))),
                      ),
                    ),
            ),
            Divider(color: borderColor),
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                title: const Text("Sign Out", style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                onTap: () {
                  setState(() {
                    _userName = "Guest User";
                    _userEmail = "guest@fikirsigns.et";
                    _isLoggedIn = false;
                  });
                  Navigator.pop(context);
                },
              )
            else
              ListTile(
                leading: const Icon(Icons.login_rounded, color: AppTheme.lightOrange),
                title: Text("Sign In", style: TextStyle(color: textColor, fontSize: 14)),
                onTap: () {
                  Navigator.pop(context);
                  _openAuthModal();
                },
              ),
            const SizedBox(height: 12),
          ],
        ),
      ),

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
                Text("Fikir Signs", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                Text("EthSL • Real-Time AI Bridge", style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.5))),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, color: textColor),
            onPressed: () => setState(() => _isDarkMode = !_isDarkMode),
            tooltip: "Toggle Light / Dark Mode",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isLoggedIn ? AppTheme.olive : AppTheme.lightOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: Icon(_isLoggedIn ? Icons.check_circle_outline_rounded : Icons.login_rounded, size: 16),
              label: Text(_isLoggedIn ? _userName.split(" ")[0] : "Sign In", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              onPressed: _openAuthModal,
            ),
          ),
          const SizedBox(width: 6),
        ],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: borderColor, height: 1)),
      ),

      body: Column(
        children: [
          // Real-time Status Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: surfaceColor,
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: _statusSign == "Standby" || _statusSign.contains("Resting") ? Colors.grey : AppTheme.lightOrange,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Text("STATUS: ", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor.withOpacity(0.4))),
                Text(_statusSign, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.lightOrange)),
                const Spacer(),
                Text(_statusAmharic, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.olive)),
              ],
            ),
          ),

          // High-Visibility Chat Feed (LARGE CLINIC TEXT)
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isStaff = msg.sender.startsWith("Staff");

                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: isStaff ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isStaff) ...[
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: msg.sender == "System" ? AppTheme.olive : AppTheme.lightOrange,
                          child: Icon(
                            msg.sender == "System" ? Icons.auto_awesome : Icons.accessibility_new_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: isStaff ? AppTheme.lightOrange.withOpacity(0.12) : cardColor,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: isStaff ? AppTheme.lightOrange.withOpacity(0.4) : borderColor, width: 1.5),
                          ),
                          child: Column(
                            crossAxisAlignment: isStaff ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg.sender,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isStaff ? AppTheme.lightOrange : AppTheme.olive),
                              ),
                              const SizedBox(height: 6),

                              // LARGE HIGH-CONTRAST ENGLISH TEXT (26px)
                              Text(
                                msg.englishText,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  height: 1.25,
                                  color: isStaff ? AppTheme.lightOrange : textColor,
                                ),
                              ),

                              // LARGE HIGH-CONTRAST AMHARIC SUBTITLE (24px)
                              if (msg.amharicText.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  msg.amharicText,
                                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.25, color: AppTheme.olive),
                                ),
                              ],

                              const SizedBox(height: 8),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (msg.type == 'sign') ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: AppTheme.olive.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                                      child: Text(
                                        "${(msg.confidence * 100).toInt()}% Match",
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.olive),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    "${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}",
                                    style: TextStyle(fontSize: 11, color: textColor.withOpacity(0.4)),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                                    color: AppTheme.olive,
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

          // Multimodal Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: surfaceColor,
              border: Border(top: BorderSide(color: borderColor)),
            ),
            child: Row(
              children: [
                // 1. Camera Button (Deaf Patients)
                Container(
                  decoration: BoxDecoration(color: AppTheme.lightOrange.withOpacity(0.15), shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.videocam_rounded, color: AppTheme.lightOrange, size: 26),
                    tooltip: "Open Camera to Sign",
                    onPressed: _openCameraStudio,
                  ),
                ),
                const SizedBox(width: 10),

                // 2. Text Input
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
                      style: TextStyle(color: textColor, fontSize: 16),
                      decoration: InputDecoration(
                        hintText: "Staff: Type message for deaf patient...",
                        hintStyle: TextStyle(color: textColor.withOpacity(0.4), fontSize: 14),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (t) => _submitStaffMessage(t),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // 3. Real Microphone Button (Hearing Staff)
                Container(
                  decoration: BoxDecoration(
                    color: _isListeningVoice ? Colors.redAccent.withOpacity(0.2) : AppTheme.olive.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      _isListeningVoice ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: _isListeningVoice ? Colors.redAccent : AppTheme.olive,
                      size: 24,
                    ),
                    tooltip: "Speak into Microphone (English)",
                    onPressed: _startVoiceInput,
                  ),
                ),
                const SizedBox(width: 8),

                // 4. Send Button
                Container(
                  decoration: const BoxDecoration(color: AppTheme.lightOrange, shape: BoxShape.circle),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
                    onPressed: () => _submitStaffMessage(_textController.text),
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

// =============================================================================
// CAMERA STUDIO: Natural 3-Second Window with Real Landmarks
// =============================================================================
class _MediaPipeCameraSheet extends StatefulWidget {
  final bool isDarkMode;
  final Function(List<List<double>>) onCaptureFinished;

  const _MediaPipeCameraSheet({required this.isDarkMode, required this.onCaptureFinished});

  @override
  State<_MediaPipeCameraSheet> createState() => _MediaPipeCameraSheetState();
}

class _MediaPipeCameraSheetState extends State<_MediaPipeCameraSheet> {
  bool _isRecording = false;
  double _recordingProgress = 0.0;
  String _statusMessage = "Position yourself in front of camera";

  void _startCameraRecording() {
    setState(() {
      _isRecording = true;
      _recordingProgress = 0.0;
      _statusMessage = "Starting camera...";
    });

    try {
      // Calls window.startEthSLCameraSession defined in index.html!
      js.context.callMethod('startEthSLCameraSession', [
        'ethsl-camera-feed',
        (status, progress) {
          if (mounted) {
            setState(() {
              _statusMessage = status.toString();
              _recordingProgress = (progress as num).toDouble();
            });
          }
        },
        (framesJson) {
          final List<dynamic> raw = jsonDecode(framesJson);
          final List<List<double>> cleanFrames = raw
              .map((f) => (f as List).map((n) => (n as num).toDouble()).toList())
              .toList();

          if (mounted) {
            setState(() {
              _isRecording = false;
              _statusMessage = "Processing gesture on AWS...";
            });
          }
          widget.onCaptureFinished(cleanFrames);
        }
      ]);
    } catch (e) {
      debugPrint("Camera error: $e");
      setState(() {
        _isRecording = false;
        _statusMessage = "Camera access error. Please allow camera permissions.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = widget.isDarkMode ? AppTheme.darkCard : AppTheme.lightCard;
    final txtColor = widget.isDarkMode ? Colors.white : Colors.black87;

    return Container(
      height: 420,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.videocam_rounded, color: AppTheme.lightOrange),
                  const SizedBox(width: 8),
                  Text("Live EthSL Sign Capture", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: txtColor)),
                ],
              ),
              IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: widget.isDarkMode ? AppTheme.darkSurface : AppTheme.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.olive.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_isRecording ? Icons.radio_button_checked_rounded : Icons.accessibility_new_rounded,
                      size: 56, color: _isRecording ? Colors.redAccent : AppTheme.olive),
                  const SizedBox(height: 14),
                  Text(_statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _isRecording ? AppTheme.lightOrange : txtColor)),
                  const SizedBox(height: 16),
                  if (_isRecording) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _recordingProgress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withOpacity(0.2),
                        color: AppTheme.lightOrange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text("Perform complete sign now...", style: TextStyle(fontSize: 13, color: txtColor.withOpacity(0.5))),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isRecording ? Colors.grey : AppTheme.lightOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: Icon(_isRecording ? Icons.hourglass_top_rounded : Icons.fiber_manual_record_rounded, color: Colors.white),
              label: Text(_isRecording ? "Recording Gesture..." : "Start 3-Second Sign Recording",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              onPressed: _isRecording ? null : _startCameraRecording,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// AUTH MODAL: Spacious Form
// =============================================================================
class _AuthModal extends StatefulWidget {
  final Function(String name, String email) onSuccess;

  const _AuthModal({required this.onSuccess});

  @override
  State<_AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<_AuthModal> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _loginEmail = TextEditingController();
  final TextEditingController _loginPass = TextEditingController();
  final TextEditingController _signupName = TextEditingController();
  final TextEditingController _signupEmail = TextEditingController();
  final TextEditingController _signupPass = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _handleLogin() {
    final email = _loginEmail.text.trim();
    if (email.isNotEmpty) {
      final name = email.split("@")[0].replaceAll(".", " ");
      widget.onSuccess(name[0].toUpperCase() + name.substring(1), email);
      Navigator.pop(context);
    }
  }

  void _handleSignup() {
    final name = _signupName.text.trim();
    final email = _signupEmail.text.trim();
    if (name.isNotEmpty && email.isNotEmpty) {
      widget.onSuccess(name, email);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? AppTheme.darkCard : AppTheme.lightCard;
    final txtColor = isDark ? Colors.white : Colors.black87;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.4), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 18),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.lightOrange,
                unselectedLabelColor: txtColor.withOpacity(0.5),
                indicatorColor: AppTheme.lightOrange,
                tabs: const [Tab(text: "Sign In"), Tab(text: "Create Account")],
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 310,
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        TextField(
                          controller: _loginEmail,
                          style: TextStyle(color: txtColor),
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _loginPass,
                          obscureText: true,
                          style: TextStyle(color: txtColor),
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.lightOrange,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _handleLogin,
                            child: const Text("Sign In", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        TextField(
                          controller: _signupName,
                          style: TextStyle(color: txtColor),
                          decoration: InputDecoration(
                            labelText: "Full Name (e.g., Dr. Abebe)",
                            prefixIcon: const Icon(Icons.person_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _signupEmail,
                          style: TextStyle(color: txtColor),
                          decoration: InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _signupPass,
                          obscureText: true,
                          style: TextStyle(color: txtColor),
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.olive,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _handleSignup,
                            child: const Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}