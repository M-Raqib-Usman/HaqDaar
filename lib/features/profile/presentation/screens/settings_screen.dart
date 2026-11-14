import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haqdaar/core/localization/app_localizations.dart';
import 'package:haqdaar/core/localization/locale_provider.dart';
import 'package:haqdaar/features/auth/presentation/providers/auth_provider.dart';
import 'package:haqdaar/features/auth/presentation/screens/login_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _hearingReminders = true;
  bool _caseUpdates = true;
  bool _legalTips = false;
  bool _biometricLogin = false;

  void _showPasswordResetDialog(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password'),
        content: Text(
          'Send a password reset email to $email?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset link sent to your email!'),
                      backgroundColor: Colors.green,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceFirst('Exception: ', '')),
                      backgroundColor: Colors.red.shade700,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Send Link'),
          ),
        ],
      ),
    );
  }

  void _showLegalDisclaimerDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.gavel_rounded, color: Colors.green.shade800),
            const SizedBox(width: 8),
            const Text('Legal Disclaimer'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'HaqDaar is an AI-powered legal empowerment and workflow platform designed to provide legal information, document drafting assistance, and case tracking for citizens in Pakistan.\n\nThe AI advisor and generated documents are for informational and organizational assistance only and do not constitute formal legal representation. Users are encouraged to consult licensed advocates for court proceedings.',
            style: TextStyle(fontSize: 14, height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Understood'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Privacy & Security'),
        content: const SingleChildScrollView(
          child: Text(
            'At HaqDaar, your legal cases, financial records, and personal documents are encrypted and kept strictly confidential.\n\nWe do not share your private case filings or personally identifiable information with third-party advertisers.',
            style: TextStyle(fontSize: 14, height: 1.45),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final user = ref.watch(currentUserProvider);
    final userName = ref.watch(userNameProvider);
    final userEmail = user?.email ?? 'user@example.com';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(AppLocalizations.translate(lang, 'settings')),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // User Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.green.shade100,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        userEmail,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Account & Security
          _buildSectionHeader('Account & Security'),
          _buildSettingsTile(
            icon: Icons.lock_reset_rounded,
            title: 'Change Password',
            subtitle: 'Update your account credentials',
            onTap: () => _showPasswordResetDialog(userEmail),
          ),
          _buildSwitchTile(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric / PIN Lock',
            subtitle: 'Secure app access on startup',
            value: _biometricLogin,
            onChanged: (val) => setState(() => _biometricLogin = val),
          ),
          const SizedBox(height: 20),

          // Section 2: Preferences & Language
          _buildSectionHeader('Preferences'),
          _buildLanguageTile(lang),
          const SizedBox(height: 20),

          // Section 3: Notifications
          _buildSectionHeader('Notifications & Reminders'),
          _buildSwitchTile(
            icon: Icons.notifications_active_outlined,
            title: 'Hearing Date Alerts',
            subtitle: 'Get reminded 24h before court dates',
            value: _hearingReminders,
            onChanged: (val) => setState(() => _hearingReminders = val),
          ),
          _buildSwitchTile(
            icon: Icons.update_rounded,
            title: 'Case Progress Updates',
            subtitle: 'Notifications when case status changes',
            value: _caseUpdates,
            onChanged: (val) => setState(() => _caseUpdates = val),
          ),
          _buildSwitchTile(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Legal Tips & Updates',
            subtitle: 'New legal rights guides and policies',
            value: _legalTips,
            onChanged: (val) => setState(() => _legalTips = val),
          ),
          const SizedBox(height: 20),

          // Section 4: Legal & Policies
          _buildSectionHeader('Legal & Compliance'),
          _buildSettingsTile(
            icon: Icons.gavel_rounded,
            title: 'Legal Disclaimer',
            subtitle: 'Terms regarding legal information',
            onTap: _showLegalDisclaimerDialog,
          ),
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'How your case documents are secured',
            onTap: _showPrivacyPolicyDialog,
          ),
          const SizedBox(height: 20),

          // Section 5: About & Support
          _buildSectionHeader('Support'),
          _buildSettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help & FAQs',
            subtitle: 'Learn how to use HaqDaar features',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('For help, contact support@haqdaar.pk'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildSettingsTile(
            icon: Icons.info_outline_rounded,
            title: 'App Version',
            subtitle: 'HaqDaar v1.0.0 (Build 1)',
            onTap: null,
          ),
          const SizedBox(height: 24),

          // Sign Out Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout_rounded, color: Colors.red),
              title: const Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: Colors.red),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Sign Out'),
                    content: const Text('Are you sure you want to sign out of HaqDaar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Sign Out'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await ref.read(authRepositoryProvider).signOut();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                }
              },
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3ED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF145E39), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: onTap != null
            ? const Icon(Icons.chevron_right, color: Colors.grey)
            : null,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.green.shade800,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3ED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF145E39), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.5,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTile(String currentLang) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F3ED),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.language, color: Color(0xFF145E39), size: 20),
        ),
        title: const Text(
          'App Language / ایپ کی زبان',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: Color(0xFF111827),
          ),
        ),
        subtitle: Text(
          currentLang == 'en' ? 'English (انگریزی)' : 'اردو (Urdu)',
          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: TextButton(
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(40, 24),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () {
              final newLang = currentLang == 'en' ? 'ur' : 'en';
              ref.read(localeProvider.notifier).setLocale(newLang);
            },
            child: Text(
              currentLang == 'en' ? 'Switch to اردو' : 'Switch to EN',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Colors.green.shade900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
