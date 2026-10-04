import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/ai/presentation/screens/ai_document_generator_screen.dart';
import '../../../../features/ai/presentation/screens/ai_document_explainer_screen.dart';
import '../../../../features/ai/presentation/screens/ai_legal_advisor_screen.dart';
import '../../../../features/case_tracking/presentation/screens/case_list_screen.dart';
import '../../../../features/expense_tracking/presentation/screens/expense_tracker_screen.dart';
import '../../../../features/profile/presentation/screens/profile_screen.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    final List<Widget> pages = [
      _buildHomeContent(lang),
      const Center(child: Text('Documents - Coming Soon')),
      const ExpenseTrackerScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      // We only show the custom AppBar on the Home tab. 
      // Expense and Profile screens have their own AppBars.
      appBar: _currentIndex == 0 ? AppBar(
        title: Text(AppLocalizations.translate(lang, 'app_title')),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextButton(
              onPressed: () {
                final newLang = lang == 'en' ? 'ur' : 'en';
                ref.read(localeProvider.notifier).setLocale(newLang);
              },
              child: Text(
                lang == 'en' ? 'اردو' : 'EN',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          )
        ],
      ) : null,
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.green.shade800,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: AppLocalizations.translate(lang, 'home')),
          BottomNavigationBarItem(icon: const Icon(Icons.folder), label: AppLocalizations.translate(lang, 'documents')),
          BottomNavigationBarItem(icon: const Icon(Icons.attach_money), label: AppLocalizations.translate(lang, 'expenses')),
          BottomNavigationBarItem(icon: const Icon(Icons.person), label: AppLocalizations.translate(lang, 'profile')),
        ],
      ),
    );
  }

  Widget _buildHomeContent(String lang) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.translate(lang, 'welcome_back'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: AppLocalizations.translate(lang, 'active_cases'),
                  value: '3',
                  color: Colors.green.shade100,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseListScreen()));
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  title: AppLocalizations.translate(lang, 'total_expenses'),
                  value: 'Rs245K',
                  color: Colors.orange.shade100,
                  onTap: () {
                    setState(() {
                      _currentIndex = 2; // Navigate to expenses tab
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.translate(lang, 'quick_actions'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(context, Icons.description, AppLocalizations.translate(lang, 'generate_document'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AiDocumentGeneratorScreen()));
              }),
              _buildActionCard(context, Icons.chat, AppLocalizations.translate(lang, 'ask_ai'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AiLegalAdvisorScreen()));
              }),
              _buildActionCard(context, Icons.document_scanner, AppLocalizations.translate(lang, 'explain_document'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AiDocumentExplainerScreen()));
              }),
              _buildActionCard(context, Icons.auto_graph, AppLocalizations.translate(lang, 'track_case'), () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseListScreen()));
              }),
            ],
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.translate(lang, 'upcoming_hearings'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _buildHearingItem('Civil Suit #4521', 'District Court', 'May 12, 2026', '10:00 AM'),
          _buildHearingItem('Property Dispute #8732', 'High Court', 'May 18, 2026', '2:30 PM'),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({required String title, required String value, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade800)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.green.shade800),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildHearingItem(String title, String court, String date, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(court),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(date, style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(time, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
