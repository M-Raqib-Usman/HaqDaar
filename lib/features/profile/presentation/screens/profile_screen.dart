import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(lang, 'profile')),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Profile Picture & Info
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green.shade100,
                    child: Icon(Icons.person, size: 50, color: Colors.green.shade800),
                  ),
                  const SizedBox(height: 16),
                  const Text('Ahmed Khan', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  const Text('ahmed.khan@example.com', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn(AppLocalizations.translate(lang, 'active_cases'), '3'),
                _buildStatColumn(AppLocalizations.translate(lang, 'generated_docs'), '12'),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(),
            
            // Settings Section
            ListTile(
              leading: Icon(Icons.language, color: Colors.green.shade800),
              title: Text(AppLocalizations.translate(lang, 'language')),
              trailing: TextButton(
                onPressed: () {
                  final newLang = lang == 'en' ? 'ur' : 'en';
                  ref.read(localeProvider.notifier).setLocale(newLang);
                },
                child: Text(
                  lang == 'en' ? 'اردو' : 'EN',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.settings, color: Colors.green.shade800),
              title: Text(AppLocalizations.translate(lang, 'settings')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(AppLocalizations.translate(lang, 'logout'), style: const TextStyle(color: Colors.red)),
              onTap: () {
                // TODO: Implement Firebase Auth Logout
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
