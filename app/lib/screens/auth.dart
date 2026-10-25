import 'package:flutter/material.dart';
import '../state.dart';
import '../widgets.dart';

class WelcomeScreen extends StatelessWidget {
  final AppState s;
  const WelcomeScreen(this.s, {super.key});
  @override
  Widget build(BuildContext context) => screenList([
        const SizedBox(height: 24),
        const Center(child: Logo()),
        const SizedBox(height: 40),
        const Text('Welcome',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Clear communication in hospitals',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: kMuted)),
        const SizedBox(height: 16),
        Image.asset('assets/welcome.png', height: 140),
        const SizedBox(height: 12),
        const Text(
            'Helping deaf patients and hospital staff understand each other through Ethiopian Sign Language.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kMuted)),
        const SizedBox(height: 24),
        BigButton('Login', () => s.go(Screen.login)),
        const SizedBox(height: 12),
        BigButton('Create account', () => s.go(Screen.signup),
            outlined: true, color: kInk),
        TextButton(
            onPressed: () => s.go(Screen.translate),
            child: const Text('Continue as guest')),
      ]);
}

class LoginScreen extends StatefulWidget {
  final AppState s;
  const LoginScreen(this.s, {super.key});
  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = TextEditingController(), pw = TextEditingController();
  String err = '';

  // TODO(Person 2): Cognito sign-in. Password is not checked yet.
  void submit() {
    if (email.text.trim().isEmpty || pw.text.isEmpty)
      return setState(() => err = 'Enter your email and password.');
    final full = '${email.text.trim().split('@').first}@gmail.com';
    final saved = widget.s.user;
    widget.s.saveUser(saved != null && saved['email'] == full
        ? saved
        : {
            'name': email.text.trim(),
            'email': full,
            'age': '',
            'contact': '',
            'allergies': ''
          });
    widget.s.go(Screen.home);
  }

  @override
  Widget build(BuildContext context) => screenList([
        const SizedBox(height: 24),
        const Center(child: Logo()),
        const SizedBox(height: 40),
        const Text('Welcome Back',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        const Text('Log in to continue communicating with everyone.',
            textAlign: TextAlign.center, style: TextStyle(color: kMuted)),
        const SizedBox(height: 32),
        AppField('Email Address', 'Enter your email', Icons.mail_outline, email,
            suffix: '@gmail.com'),
        const SizedBox(height: 16),
        AppField('Password', 'Enter your password', Icons.lock_outline, pw,
            password: true),
        if (err.isNotEmpty)
          Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(err, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 24),
        BigButton('Login', submit),
        TextButton(
            onPressed: () => widget.s.go(Screen.signup),
            child: const Text("Don't have an account? Sign Up")),
      ]);
}

class SignUpScreen extends StatefulWidget {
  final AppState s;
  const SignUpScreen(this.s, {super.key});
  @override
  State<SignUpScreen> createState() => _SignUpState();
}

class _SignUpState extends State<SignUpScreen> {
  final name = TextEditingController(),
      age = TextEditingController(),
      email = TextEditingController();
  final pw = TextEditingController(), pw2 = TextEditingController();
  bool agree = false;
  List<String> errors = [];

  // TODO(Person 2): Cognito sign-up.
  void submit() {
    final a = int.tryParse(age.text.trim());
    final errs = <String>[
      if (name.text.trim().isEmpty) 'Enter your full name.',
      if (email.text.trim().isEmpty) 'Enter your email.',
      if (a == null || a < 0 || a > 120) 'Enter a valid age (0 to 120).',
      if (pw.text.length < 8) 'Password must be at least 8 characters.',
      if (pw.text != pw2.text) 'Passwords do not match.',
      if (!agree) 'Tick the box to agree to the Terms and Privacy Policy.',
    ];
    setState(() => errors = errs);
    if (errs.isNotEmpty) return;
    widget.s.saveUser({
      'name': name.text.trim(),
      'email': '${email.text.trim().split('@').first}@gmail.com',
      'age': '$a',
      'contact': '',
      'allergies': '',
    });
    widget.s.go(Screen.home);
  }

  @override
  Widget build(BuildContext context) => screenList([
        const Center(child: Logo()),
        const SizedBox(height: 24),
        const Text('Create Account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800)),
        const SizedBox(height: 24),
        AppField(
            'Full Name', 'Enter your full name', Icons.person_outline, name),
        const SizedBox(height: 14),
        AppField('Age', 'Enter your age', Icons.cake_outlined, age,
            keyboard: TextInputType.number),
        const SizedBox(height: 14),
        AppField('Email Address', 'Enter your email', Icons.mail_outline, email,
            suffix: '@gmail.com'),
        const SizedBox(height: 14),
        AppField('Password', 'Create a password (8+ characters)',
            Icons.lock_outline, pw,
            password: true),
        const SizedBox(height: 14),
        AppField('Confirm Password', 'Re-enter your password',
            Icons.lock_outline, pw2,
            password: true),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          value: agree,
          onChanged: (v) => setState(() => agree = v ?? false),
          title: const Text(
              'I agree to the Terms of Service and Privacy Policy.',
              style: TextStyle(color: kMuted, fontSize: 14)),
        ),
        if (errors.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              for (final e in errors)
                Text('• $e', style: TextStyle(color: Colors.red.shade700))
            ]),
          ),
        BigButton('Create Account', submit),
      ]);
}
