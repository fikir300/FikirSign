import 'dart:convert';
import 'dart:math';
import 'package:web_socket_channel/web_socket_channel.dart';

// Contract shared with Person 1 and 2.
// Send:    {"action":"frames","frames":[[{x,y,z} x21]...],"hands":1}
// Receive: {"sign","confidence","sentence","audioUrl"}
// Run with the real API: flutter run --dart-define=WS_URL=wss://your-api...
const wsUrl = String.fromEnvironment('WS_URL');
const _mock = ['I', 'pain', 'need', 'doctor', 'water', 'medicine', 'help'];

class SignSocket {
  final void Function(Map<String, dynamic>) onMessage;
  WebSocketChannel? _ch;
  final _words = <String>[];

  SignSocket(this.onMessage) {
    if (wsUrl.isNotEmpty) {
      _ch = WebSocketChannel.connect(Uri.parse(wsUrl));
      _ch!.stream.listen((m) {
        try {
          onMessage(Map<String, dynamic>.from(jsonDecode(m as String)));
        } catch (_) {}
      });
    }
  }

  void send(Map<String, dynamic> payload) {
    if (_ch != null) {
      _ch!.sink.add(jsonEncode(payload));
      return;
    }
    // Mock: ignores the hands and returns a random word.
    final sign = _mock[Random().nextInt(_mock.length)];
    _words.add(sign);
    Future.delayed(const Duration(milliseconds: 300),
        () => onMessage({'sign': sign, 'confidence': 0.9, 'sentence': _words.join(' '), 'audioUrl': null}));
  }

  void close() => _ch?.sink.close();
}
