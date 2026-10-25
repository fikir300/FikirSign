import 'package:flutter/material.dart';
import '../../core/config/env.dart';

/// Screen managing accessibility options, theme mode, and presenting medical limitations.
class SettingsScreen extends StatefulWidget {
  final bool isHighContrast;
  final ValueChanged<bool>? onHighContrastChanged;

  const SettingsScreen({
    super.key,
    this.isHighContrast = false,
    this.onHighContrastChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _highContrast;

  @override
  void initState() {
    super.initState();
    _highContrast = widget.isHighContrast;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Accessibility Section
          Text('Accessibility & Display', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('High-Contrast Theme'),
                  subtitle: const Text('Black background with yellow/cyan highlights'),
                  value: _highContrast,
                  onChanged: (val) {
                    setState(() => _highContrast = val);
                    widget.onHighContrastChanged?.call(val);
                    // TODO: Persist accessibility settings in SharedPreferences
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.format_size),
                  title: const Text('Text Size'),
                  subtitle: const Text('Default enlarged typography is enabled'),
                  trailing: const Chip(label: Text('Large')),
                  onTap: () {
                    // TODO: Allow customizing font scale multiplier
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Connectivity & Backend
          Text('Backend & API Status', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_outlined),
                  title: const Text('API Base URL'),
                  subtitle: Text(Env.apiBaseUrl),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.developer_mode),
                  title: const Text('Mock Mode'),
                  subtitle: Text(Env.useMockApi ? 'Active (USE_MOCK_API=true)' : 'Live Backend Mode'),
                  trailing: Chip(
                    backgroundColor: Env.useMockApi ? Colors.amber.shade100 : Colors.green.shade100,
                    label: Text(Env.useMockApi ? 'Mock' : 'Live'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About & Limitations
          Text('About & Clinical Limitations', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.health_and_safety, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text('FikirSign v1.0.0', style: theme.textTheme.titleMedium),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'FikirSign is an assistive chat app designed to support communication '
                    'between hospital staff and deaf Ethiopians using Ethiopian Sign Language (EthSL) '
                    'and Amharic.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer.withAlpha(80),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: theme.colorScheme.error.withAlpha(80)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
                            const SizedBox(width: 8),
                            Text(
                              'Medical Disclaimer',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'This app is an assistive bridge and NOT a substitute for certified medical interpreters '
                          'or clinical decision making. For invasive procedures, informed surgery consent, '
                          'or critical diagnoses, a certified human interpreter must be involved.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
