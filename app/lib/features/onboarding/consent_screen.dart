import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

/// Onboarding consent screen detailing Ethiopian Sign Language camera assistance and medical guidelines.
class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreedToTerms = false;

  void _proceedToChat() {
    // TODO: Store consent acceptance timestamp in SharedPreferences
    Navigator.of(context).pushReplacementNamed(AppConstants.routeChat);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FikirSign'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings & Limitations',
            onPressed: () {
              Navigator.of(context).pushNamed(AppConstants.routeSettings);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.sign_language_rounded,
                  size: 48,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 20),

              // Title & Subtitle
              Text(
                'Welcome to FikirSign\nእንኳን ወደ ፍቅር ሳይን በደህና መጡ',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Empowering seamless communication between healthcare providers and deaf patients '
                'in Ethiopia using Ethiopian Sign Language (EthSL) and Amharic.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              const SizedBox(height: 24),

              // Key Points Card
              Expanded(
                child: Card(
                  elevation: 0,
                  color: theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _consentBullet(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera Sign Recognition',
                        body: 'Camera captures hand and facial gestures to recognize Ethiopian Sign Language phrases.',
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _consentBullet(
                        icon: Icons.record_voice_over_outlined,
                        title: 'Voice & Speech Audio',
                        body: 'Medical staff can speak English/Amharic, which synthesizes into text and audio for patients.',
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _consentBullet(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Patient Privacy',
                        body: 'No medical history or sensitive biometric video recordings are permanently stored without consent.',
                        theme: theme,
                      ),
                      const SizedBox(height: 16),
                      _consentBullet(
                        icon: Icons.warning_amber_rounded,
                        title: 'Clinical Disclaimer',
                        body: 'This tool is an assistive communication bridge, not a substitute for certified human interpreters.',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Checkbox
              CheckboxListTile(
                value: _agreedToTerms,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  'I understand the assistive nature and consent to camera & microphone usage for translation.',
                  style: theme.textTheme.bodyMedium,
                ),
                onChanged: (val) {
                  setState(() => _agreedToTerms = val ?? false);
                },
              ),
              const SizedBox(height: 12),

              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _agreedToTerms ? _proceedToChat : null,
                  child: const Text('Continue to Chat / ወደ ውይይት ይለፉ'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _consentBullet({
    required IconData icon,
    required String title,
    required String body,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                body,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
