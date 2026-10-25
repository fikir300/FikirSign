import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

const kBrand = Color(0xFF2563EB);
const kInk = Color(0xFF111827);
const kMuted = Color(0xFF64748B);
const kTint = Color(0xFFEFF6FF);
const kLine = Color(0xFFCBD5E1);

final _tts = FlutterTts();
Future<void> speak(String text) async {
  if (text.trim().isEmpty) return;
  await _tts.stop();
  await _tts.speak(text);
}

class Logo extends StatelessWidget {
  const Logo({super.key});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset('assets/logo.png', width: 44, height: 44)),
        const SizedBox(width: 12),
        const Text.rich(TextSpan(
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800, color: kInk),
            children: [
              TextSpan(text: 'Fikir '),
              TextSpan(text: 'Sign', style: TextStyle(color: kBrand)),
            ])),
      ]);
}

class BigButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool outlined;
  final Color color;
  const BigButton(this.label, this.onPressed,
      {super.key, this.icon, this.outlined = false, this.color = kBrand});
  @override
  Widget build(BuildContext context) {
    final child = Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
      Text(label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    ]);
    final shape =
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16));
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                  foregroundColor: color,
                  side: const BorderSide(color: kLine),
                  shape: shape),
              child: child)
          : FilledButton(
              onPressed: onPressed,
              style:
                  FilledButton.styleFrom(backgroundColor: color, shape: shape),
              child: child),
    );
  }
}

class AppField extends StatefulWidget {
  final String label, hint;
  final IconData icon;
  final TextEditingController controller;
  final bool password;
  final String? suffix;
  final TextInputType? keyboard;
  const AppField(this.label, this.hint, this.icon, this.controller,
      {super.key, this.password = false, this.suffix, this.keyboard});
  @override
  State<AppField> createState() => _AppFieldState();
}

class _AppFieldState extends State<AppField> {
  bool _hide = true;
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          obscureText: widget.password && _hide,
          keyboardType: widget.suffix != null
              ? TextInputType.emailAddress
              : widget.keyboard,
          autocorrect: false,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: Icon(widget.icon, color: kMuted),
            suffixText: widget.suffix,
            suffixStyle: const TextStyle(color: kInk, fontSize: 16),
            suffixIcon: widget.password
                ? IconButton(
                    icon: Icon(_hide
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () => setState(() => _hide = !_hide))
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kLine)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: kLine)),
          ),
        ),
      ]);
}

/// Top bar for sub-screens: back arrow + logo.
class TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const TopBar(this.onBack, {super.key});
  @override
  Widget build(BuildContext context) =>
      Stack(alignment: Alignment.center, children: [
        Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                onPressed: onBack, icon: const Icon(Icons.arrow_back))),
        const Logo(),
      ]);
}

Widget screenList(List<Widget> children) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 24, 24, 24), children: children);
