import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/chat_screen.dart';
import 'features/feedback/feedback_screen.dart';
import 'features/onboarding/consent_screen.dart';
import 'features/phrase_library/phrase_library_screen.dart';
import 'features/settings/settings_screen.dart';

/// Root application widget configuring themes, localization, and top-level routes.
class FikirSignApp extends StatefulWidget {
  const FikirSignApp({super.key});

  @override
  State<FikirSignApp> createState() => _FikirSignAppState();
}

class _FikirSignAppState extends State<FikirSignApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleHighContrast(bool enabled) {
    setState(() {
      _themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.highContrastTheme,
      themeMode: _themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('am', 'ET'),
      ],
      initialRoute: AppConstants.routeConsent,
      routes: {
        AppConstants.routeConsent: (context) => const ConsentScreen(),
        AppConstants.routeChat: (context) => const ChatScreen(),
        AppConstants.routePhraseLibrary: (context) => const PhraseLibraryScreen(),
        AppConstants.routeFeedback: (context) => const FeedbackScreen(),
        AppConstants.routeSettings: (context) => SettingsScreen(
              isHighContrast: _themeMode == ThemeMode.dark,
              onHighContrastChanged: _toggleHighContrast,
            ),
      },
    );
  }
}
