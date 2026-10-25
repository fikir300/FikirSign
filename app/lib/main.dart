import 'package:flutter/material.dart';
import 'state.dart';
import 'widgets.dart';
import 'screens/auth.dart';
import 'screens/home.dart';
import 'screens/translate.dart';
import 'screens/more.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final s = AppState();
  await s.init();
  runApp(FikrApp(s));
}

class FikrApp extends StatelessWidget {
  final AppState s;
  const FikrApp(this.s, {super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Fikr Sign',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: kBrand, scaffoldBackgroundColor: Colors.white),
        builder: (context, child) => ColoredBox(
          color: const Color(0xFFE5E7EB),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: ClipRect(child: child!),
            ),
          ),
        ),
        home: Shell(s),
      );
}

class Shell extends StatelessWidget {
  final AppState s;
  const Shell(this.s, {super.key});
  static const tabs = [Screen.home, Screen.translate, Screen.phrases, Screen.profile];

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: s,
        builder: (_, __) {
          final body = switch (s.screen) {
            Screen.welcome => WelcomeScreen(s),
            Screen.login => LoginScreen(s),
            Screen.signup => SignUpScreen(s),
            Screen.home => HomeScreen(s),
            Screen.translate => TranslateScreen(s),
            Screen.phrases => const PhrasesScreen(),
            Screen.profile => ProfileScreen(s),
          };
          final active = s.screen;
          final idx = tabs.indexOf(active);
          return Scaffold(
            body: SafeArea(child: body),
            bottomNavigationBar: idx < 0
                ? null
                : NavigationBar(
                    selectedIndex: idx,
                    onDestinationSelected: (i) => s.go(tabs[i]),
                    destinations: const [
                      NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
                      NavigationDestination(icon: Icon(Icons.translate), label: 'Translate'),
                      NavigationDestination(icon: Icon(Icons.chat_bubble_outline), label: 'Phrases'),
                      NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
                    ],
                  ),
          );
        },
      );
}
