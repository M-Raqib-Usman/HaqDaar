import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haqdaar/core/localization/locale_provider.dart';
import 'package:haqdaar/features/home/presentation/screens/home_dashboard_screen.dart';

class LanguageSetupScreen extends ConsumerStatefulWidget {
  const LanguageSetupScreen({super.key});

  @override
  ConsumerState<LanguageSetupScreen> createState() => _LanguageSetupScreenState();
}

class _LanguageSetupScreenState extends ConsumerState<LanguageSetupScreen> {
  String _selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.language, size: 64, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Choose Your Language\nاپنی زبان کا انتخاب کریں',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 0,
                color: _selectedLanguage == 'en' ? Colors.green.shade50 : Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedLanguage == 'en' ? Colors.green.shade800 : Colors.grey.shade300,
                    width: _selectedLanguage == 'en' ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: _selectedLanguage == 'en' ? Colors.green.shade800 : Colors.grey.shade400,
                  ),
                  title: const Text('English', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('Continue in English'),
                  onTap: () => setState(() => _selectedLanguage = 'en'),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 0,
                color: _selectedLanguage == 'ur' ? Colors.green.shade50 : Colors.grey.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedLanguage == 'ur' ? Colors.green.shade800 : Colors.grey.shade300,
                    width: _selectedLanguage == 'ur' ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.check_circle,
                    color: _selectedLanguage == 'ur' ? Colors.green.shade800 : Colors.grey.shade400,
                  ),
                  title: const Text('اردو (Urdu)', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('اردو میں جاری رکھیں'),
                  onTap: () => setState(() => _selectedLanguage = 'ur'),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade800,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ref.read(localeProvider.notifier).setLocale(_selectedLanguage);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
                    (route) => false,
                  );
                },
                child: const Text(
                  'Continue / آگے بڑھیں',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
