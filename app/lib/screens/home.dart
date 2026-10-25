import 'package:flutter/material.dart';
import '../state.dart';
import '../widgets.dart';

class HomeScreen extends StatelessWidget {
  final AppState s;
  const HomeScreen(this.s, {super.key});

  void emergency(BuildContext context) {
    speak('Emergency. I need help now.');
    showDialog(
      context: context,
      builder: (_) => Dialog.fullscreen(
        backgroundColor: Colors.red.shade600,
        child: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.warning_amber_rounded, size: 72, color: Colors.white),
            const SizedBox(height: 24),
            const Text('EMERGENCY\nI NEED HELP NOW', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w800)),
            const SizedBox(height: 32),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.red.shade600),
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final first = s.user?['name']?.split(' ').first;
    Widget card(IconData i, String t, String sub, Screen to) => Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: Container(width: 52, height: 52, decoration: BoxDecoration(color: kTint, borderRadius: BorderRadius.circular(14)), child: Icon(i, color: kBrand)),
            title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(sub),
            trailing: const Icon(Icons.arrow_forward, color: kBrand, size: 18),
            onTap: () => s.go(to),
          ),
        );
    return screenList([
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Logo(),
        IconButton(onPressed: () => s.go(Screen.profile), icon: const Icon(Icons.person_outline)),
      ]),
      const SizedBox(height: 20),
      Text(first != null ? 'Hello, $first' : 'Welcome to Fikr Sign', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      const Text('Clear communication between deaf patients and hospital staff.', style: TextStyle(color: kMuted)),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: kTint, borderRadius: BorderRadius.circular(24)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Expanded(child: Text('Care Without\nBarriers', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800))),
            ClipRRect(borderRadius: BorderRadius.circular(16), child: Image.asset('assets/home-hero.png', width: 110, height: 110)),
          ]),
          const SizedBox(height: 12),
          const Text('Explain symptoms, ask questions and understand your treatment in Ethiopian Sign Language.', style: TextStyle(color: kMuted)),
          const SizedBox(height: 16),
          BigButton('Start Communicating', () => s.go(Screen.translate), icon: Icons.arrow_forward),
        ]),
      ),
      const SizedBox(height: 16),
      BigButton('Emergency: I need help', () => emergency(context), icon: Icons.warning_amber_rounded, color: Colors.red.shade600),
      const SizedBox(height: 16),
      card(Icons.camera_alt_outlined, 'Patient–Staff Translator', 'Sign to text and voice.', Screen.translate),
      card(Icons.chat_bubble_outline, 'Quick Phrases', 'Tap to say common hospital needs.', Screen.phrases),
    ]);
  }
}
