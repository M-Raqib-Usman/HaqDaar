import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';

class AuthorityItem {
  final String name;
  final String category;
  final String address;
  final String phone;
  final String timing;
  final String jurisdiction;

  const AuthorityItem({
    required this.name,
    required this.category,
    required this.address,
    required this.phone,
    required this.timing,
    required this.jurisdiction,
  });
}

class FindAuthorityScreen extends ConsumerStatefulWidget {
  const FindAuthorityScreen({super.key});

  @override
  ConsumerState<FindAuthorityScreen> createState() => _FindAuthorityScreenState();
}

class _FindAuthorityScreenState extends ConsumerState<FindAuthorityScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<AuthorityItem> _authorities = const [
    AuthorityItem(
      name: 'District & Sessions Court (ضلعی و سیشن عدالت)',
      category: 'Courts',
      address: 'Katchery Road, District Judicial Complex',
      phone: '051-9204561',
      timing: '8:30 AM - 3:30 PM (Mon-Sat)',
      jurisdiction: 'Civil, Criminal & Family Matters',
    ),
    AuthorityItem(
      name: 'High Court Legal Aid Cell (ہائی کورٹ مفت قانونی امداد سیل)',
      category: 'Legal Aid',
      address: 'Constitution Avenue, High Court Bar Building',
      phone: '051-9218844',
      timing: '9:00 AM - 4:00 PM (Mon-Fri)',
      jurisdiction: 'Pro-Bono Representation & Consultation',
    ),
    AuthorityItem(
      name: 'Federal Ombudsman Secretariat (وفاقی محتسب سیکرٹریٹ)',
      category: 'Ombudsman',
      address: 'Zero Point, Sector G-5/1',
      phone: '051-9217311',
      timing: '9:00 AM - 5:00 PM (Mon-Fri)',
      jurisdiction: 'Maladministration in Federal Government Agencies',
    ),
    AuthorityItem(
      name: 'Consumer Protection Court (صارف تحفظ عدالت)',
      category: 'Courts',
      address: 'Sector F-8 Markaz, Near Judicial Academy',
      phone: '051-9261290',
      timing: '9:00 AM - 3:00 PM (Mon-Sat)',
      jurisdiction: 'Consumer Rights, Defective Products & Services',
    ),
    AuthorityItem(
      name: 'National Commission for Human Rights (قومی کمیشن برائے انسانی حقوق)',
      category: 'Legal Aid',
      address: '5th Floor, Evacuee Trust Complex, F-5/1',
      phone: '051-9216699',
      timing: '9:00 AM - 5:00 PM (Mon-Fri)',
      jurisdiction: 'Human Rights Violations & Legal Inquiries',
    ),
    AuthorityItem(
      name: 'Central Police Station (تھانہ - تحفظ سیل)',
      category: 'Police',
      address: 'Police Lines, Sector H-11',
      phone: '15 / 051-9258371',
      timing: '24/7 Service',
      jurisdiction: 'Emergency Assistance, FIR Lodging & Protection',
    ),
  ];

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Courts':
        return Icons.account_balance_rounded;
      case 'Police':
        return Icons.local_police_rounded;
      case 'Legal Aid':
        return Icons.handshake_rounded;
      case 'Ombudsman':
        return Icons.shield_rounded;
      default:
        return Icons.apps_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Courts':
        return const Color(0xFF135D38);
      case 'Police':
        return const Color(0xFF1E40AF);
      case 'Legal Aid':
        return const Color(0xFF0D9488);
      case 'Ombudsman':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF4B5563);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final categories = ['All', 'Courts', 'Legal Aid', 'Ombudsman', 'Police'];

    final filteredList = _authorities.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesSearch =
          item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.address.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.jurisdiction.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(lang, 'authority_finder')),
        backgroundColor: const Color(0xFF135D38),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: const Color(0xFF135D38),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: AppLocalizations.translate(lang, 'search_authority_hint'),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Categories Horizontal List
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final catColor = _getCategoryColor(cat);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      avatar: Icon(
                        _getCategoryIcon(cat),
                        size: 16,
                        color: isSelected ? Colors.white : catColor,
                      ),
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: const Color(0xFF135D38),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFF374151),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      onSelected: (_) {
                        setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Authority List
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_rounded, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'No authorities found',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      final catColor = _getCategoryColor(item.category);
                      final catIcon = _getCategoryIcon(item.category);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: catColor.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(catIcon, color: catColor, size: 24),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF111827),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: catColor.withValues(alpha: 0.08),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            item.category,
                                            style: TextStyle(
                                              color: catColor,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.place_rounded, size: 16, color: Color(0xFF0D9488)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.address,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.schedule_rounded, size: 16, color: Color(0xFFD97706)),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.timing,
                                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.gavel_rounded, size: 16, color: Color(0xFF135D38)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item.jurisdiction,
                                      style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Dialing ${item.phone}...'),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                                    label: Text(item.phone),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF135D38),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
