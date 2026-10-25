import 'package:flutter/material.dart';
import '../state.dart';
import '../widgets.dart';

const phrases = [
  'I am in pain', 'I need a doctor', 'I need a nurse', 'I need water', 'I need medicine', 'I feel dizzy',
  'I have a fever', 'Where is the bathroom?', 'Please call my family', 'I do not understand', 'Please repeat slowly', 'Thank you',
];

class PhrasesScreen extends StatefulWidget {
  const PhrasesScreen({super.key});
  @override
  State<PhrasesScreen> createState() => _PhrasesState();
}

class _PhrasesState extends State<PhrasesScreen> {
  String shown = '';
  @override
  Widget build(BuildContext context) => screenList([
        const Text('Quick Phrases', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Tap a phrase to show it in large text and speak it to hospital staff.', style: TextStyle(color: kMuted)),
        if (shown.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: kTint, borderRadius: BorderRadius.circular(24)),
            child: Text(shown, textAlign: TextAlign.center, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: kBrand)),
          ),
        const SizedBox(height: 16),
        for (final p in phrases)
          Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: const BorderSide(color: Color(0xFFE2E8F0))),
            child: ListTile(
              title: Text(p, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.volume_up_outlined, color: kBrand),
              onTap: () {
                setState(() => shown = p);
                speak(p);
              },
            ),
          ),
      ]);
}

class ProfileScreen extends StatefulWidget {
  final AppState s;
  const ProfileScreen(this.s, {super.key});
  @override
  State<ProfileScreen> createState() => _ProfileState();
}

class _ProfileState extends State<ProfileScreen> {
  bool editing = false;
  String err = '';
  final name = TextEditingController(), age = TextEditingController(), contact = TextEditingController(), allergies = TextEditingController();

  void startEdit(Map<String, String> u) {
    name.text = u['name'] ?? '';
    age.text = u['age'] ?? '';
    contact.text = u['contact'] ?? '';
    allergies.text = u['allergies'] ?? '';
    setState(() {
      err = '';
      editing = true;
    });
  }

  void save(Map<String, String> u) {
    final a = age.text.trim().isEmpty ? null : int.tryParse(age.text.trim());
    if (name.text.trim().isEmpty) return setState(() => err = 'Name cannot be empty.');
    if (age.text.trim().isNotEmpty && (a == null || a < 0 || a > 120)) return setState(() => err = 'Enter a valid age (0 to 120).');
    widget.s.saveUser({...u, 'name': name.text.trim(), 'age': a?.toString() ?? '', 'contact': contact.text.trim(), 'allergies': allergies.text.trim()});
    setState(() => editing = false);
  }

  Widget row(IconData i, String label, String? v) => ListTile(
        leading: Icon(i, color: kBrand),
        title: Text(label, style: const TextStyle(fontSize: 13, color: kMuted)),
        subtitle: Text((v == null || v.isEmpty) ? 'Not added' : v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: (v == null || v.isEmpty) ? kMuted : kInk)),
      );

  @override
  Widget build(BuildContext context) {
    final u = widget.s.user;
    if (u == null) {
      return screenList([
        const SizedBox(height: 40),
        const Center(child: CircleAvatar(radius: 48, backgroundColor: kTint, child: Icon(Icons.person, size: 48, color: kBrand))),
        const SizedBox(height: 24),
        const Text('Create your profile', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        const Text('You are using Fikr Sign as a guest. Add your name and age so hospital staff can help you faster.', textAlign: TextAlign.center, style: TextStyle(color: kMuted)),
        const SizedBox(height: 28),
        BigButton('Create account', () => widget.s.go(Screen.signup), icon: Icons.person_add_alt),
        const SizedBox(height: 12),
        BigButton('Login', () => widget.s.go(Screen.login), outlined: true, color: kInk),
      ]);
    }
    final initials = (u['name'] ?? '').split(' ').where((w) => w.isNotEmpty).take(2).map((w) => w[0].toUpperCase()).join();
    return screenList([
      Center(child: CircleAvatar(radius: 48, backgroundColor: kBrand, child: Text(initials, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white)))),
      const SizedBox(height: 12),
      Text(u['name'] ?? '', textAlign: TextAlign.center, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
      Text(u['email'] ?? '', textAlign: TextAlign.center, style: const TextStyle(color: kMuted)),
      const SizedBox(height: 20),
      if (!editing) ...[
        row(Icons.cake_outlined, 'Age', (u['age'] ?? '').isEmpty ? null : '${u['age']} years'),
        row(Icons.phone_outlined, 'Emergency contact', u['contact']),
        row(Icons.favorite_border, 'Allergies or medical notes', u['allergies']),
        const SizedBox(height: 16),
        BigButton('Edit profile', () => startEdit(u), icon: Icons.edit_outlined),
        const SizedBox(height: 12),
        BigButton('Log out', () async {
          await widget.s.saveUser(null);
          widget.s.go(Screen.welcome);
        }, outlined: true, color: Colors.red),
      ] else ...[
        AppField('Full Name', 'Your full name', Icons.person_outline, name),
        const SizedBox(height: 14),
        AppField('Age', 'Your age', Icons.cake_outlined, age, keyboard: TextInputType.number),
        const SizedBox(height: 14),
        AppField('Emergency contact (phone)', 'Someone we can call', Icons.phone_outlined, contact, keyboard: TextInputType.phone),
        const SizedBox(height: 14),
        AppField('Allergies or medical notes', 'For example: penicillin allergy', Icons.favorite_border, allergies),
        if (err.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 8), child: Text(err, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 16),
        BigButton('Save changes', () => save(u)),
        const SizedBox(height: 12),
        BigButton('Cancel', () => setState(() => editing = false), outlined: true, color: kInk),
      ],
    ]);
  }
}
