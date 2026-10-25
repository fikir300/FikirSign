import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../services/hands.dart';
import '../services/socket.dart';
import '../state.dart';
import '../widgets.dart';

class TranslateScreen extends StatefulWidget {
  final AppState s;
  const TranslateScreen(this.s, {super.key});
  @override
  State<TranslateScreen> createState() => _TranslateState();
}

class _TranslateState extends State<TranslateScreen> {
  CameraController? _cam;
  SignSocket? _sock;
  Timer? _poll;
  final _hands = HandTracker();
  final _buf = <List<Map<String, double>>>[];
  HandState _hs = const HandState();
  DateTime _startedAt = DateTime.now();
  bool _slow = false;
  final _text = TextEditingController();
  bool _running = false, _consented = false, _saved = false;
  String _mode = 'both', _error = '';

  @override
  void dispose() {
    _stop(update: false);
    _text.dispose();
    super.dispose();
  }

  Future<void> _toggle() async {
    if (_running) return _stop();
    if (!_consented) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Camera use'),
          content: const Text('Fikr Sign uses your camera to detect hand positions. Only hand landmarks are sent to be translated. Video stays on your device.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Not now')),
            FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Allow')),
          ],
        ),
      );
      if (ok != true) return;
      _consented = true;
    }
    try {
      final cams = await availableCameras();
      final front = cams.firstWhere((c) => c.lensDirection == CameraLensDirection.front, orElse: () => cams.first);
      final c = CameraController(front, ResolutionPreset.medium, enableAudio: false);
      await c.initialize();
      _sock = SignSocket((m) {
        if (!mounted) return;
        // Only react to a real, confident sign. Ignore empty, "unknown" or low-confidence answers.
        final sign = (m['sign'] ?? '') as String;
        final conf = (m['confidence'] as num?)?.toDouble() ?? 0;
        if (sign.isEmpty || sign == 'unknown' || conf < 0.7) return;
        final sentence = (m['sentence'] ?? '') as String;
        setState(() => _text.text = sentence);
        if (_mode != 'text') speak(sentence);
      });
      _poll = Timer.periodic(const Duration(milliseconds: 33), (_) => _onTick());
      setState(() {
        _cam = c;
        _running = true;
        _error = '';
        _slow = false;
        _startedAt = DateTime.now();
      });
      try {
        _hands.start();
      } catch (_) {
        if (mounted) setState(() => _error = 'Hand detection could not start. Check that web/index.html contains the hands.js line, then restart the app.');
      }
    } catch (e) {
      setState(() => _error = 'Could not start the camera. Allow camera permission and try again.');
    }
  }

  // Runs ~30 times a second. Frames are only collected and sent while a hand is visible.
  void _onTick() {
    final h = _hands.read();
    if (h.visible && h.frame.isNotEmpty) {
      final pts = (jsonDecode(h.frame) as List)
          .map((p) => {'x': (p[0] as num).toDouble(), 'y': (p[1] as num).toDouble(), 'z': (p[2] as num).toDouble()})
          .toList();
      _buf.add(pts);
      if (_buf.length >= 30) {
        _sock?.send({'action': 'frames', 'frames': List.of(_buf), 'hands': h.hands});
        _buf.clear();
      }
    } else {
      _buf.clear(); // hands left the picture: drop the partial sign
    }
    final slow = !h.ready && DateTime.now().difference(_startedAt).inSeconds > 15;
    if (h.visible != _hs.visible || h.ready != _hs.ready || h.fingers != _hs.fingers || slow != _slow) {
      setState(() {
        _hs = h;
        _slow = slow;
      });
    }
  }

  void _stop({bool update = true}) {
    _poll?.cancel();
    _hands.stop();
    _buf.clear();
    _hs = const HandState();
    _sock?.close();
    _cam?.dispose();
    _cam = null;
    _sock = null;
    if (update && mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _cam != null && _cam!.value.isInitialized
        ? CameraPreview(_cam!)
        : const Center(child: Icon(Icons.videocam_off_outlined, size: 48, color: kMuted));
    return screenList([
      TopBar(() => widget.s.go(Screen.home)),
      const SizedBox(height: 8),
      const Text('Patient–Staff Translator', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 16),
      const Text('Translate Ethiopian Sign Language', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15)),
      const SizedBox(height: 8),
      const Text('Sign to your camera so doctors and nurses can read and hear your message.', style: TextStyle(color: kMuted)),
      const SizedBox(height: 16),
      ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 300,
          color: const Color(0xFFE2E8F0),
          child: Stack(fit: StackFit.expand, children: [
            FittedBox(fit: BoxFit.cover, clipBehavior: Clip.hardEdge, child: SizedBox(width: 300, height: 400, child: preview)),
            Positioned(left: 12, top: 12, child: _chip('Camera Preview')),
            if (_running) Positioned(right: 12, top: 12, child: _chip('● LIVE', color: kBrand)),
            if (_running && _error.isEmpty && (!_hands.supported || !_hs.ready || !_hs.visible))
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: kInk.withOpacity(0.85), borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    !_hands.supported
                        ? 'Hand detection is not available on this device yet.'
                        : !_hs.ready
                            ? (_slow ? 'Hand detection did not load. Check your internet connection.' : 'Loading hand detection…')
                            : 'No hands detected. Raise your hands into view.',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            if (_running && _hs.visible)
              Positioned(left: 12, bottom: 12, child: _chip('✋ Hand detected · ${_hs.fingers} finger${_hs.fingers == 1 ? '' : 's'}', color: Colors.green.shade700)),
            if (_error.isNotEmpty)
              Positioned(left: 12, right: 12, bottom: 12, child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)), child: Text(_error, style: const TextStyle(color: Colors.white)))),
          ]),
        ),
      ),
      const SizedBox(height: 16),
      BigButton(_running ? 'Stop Translating' : 'Start Translating', _toggle, icon: Icons.camera_alt_outlined),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Translated Text', style: TextStyle(fontWeight: FontWeight.w700)),
          TextField(
            controller: _text,
            maxLines: 3,
            style: const TextStyle(fontSize: 20),
            decoration: const InputDecoration(hintText: 'Your translated message will appear here', border: InputBorder.none),
          ),
          SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'text', label: Text('Text')), ButtonSegment(value: 'voice', label: Text('Voice')), ButtonSegment(value: 'both', label: Text('Both'))],
            selected: {_mode},
            onSelectionChanged: (v) => setState(() => _mode = v.first),
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: FilledButton(onPressed: () => speak(_text.text), child: const Text('Speak'))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton(onPressed: () => setState(() => _text.clear()), child: const Text('Clear'))),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton(
                onPressed: _text.text.isEmpty ? null : () => setState(() => _saved = true), // TODO: save history (local/DynamoDB)
                child: Text(_saved ? 'Saved' : 'Save'),
              ),
            ),
          ]),
        ]),
      ),
      const SizedBox(height: 12),
      const Text('Translations may contain errors. For urgent or medical decisions, confirm with a certified interpreter or staff member.',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: kMuted)),
    ]);
  }

  Widget _chip(String t, {Color color = kInk}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      );
}
