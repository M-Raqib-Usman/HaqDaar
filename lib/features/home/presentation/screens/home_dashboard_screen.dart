import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:haqdaar/features/ai/presentation/screens/ai_document_generator_screen.dart';
import 'package:haqdaar/features/ai/presentation/screens/ai_legal_advisor_screen.dart';
import 'package:haqdaar/features/auth/presentation/providers/auth_provider.dart';
import 'package:haqdaar/features/case_tracking/presentation/screens/add_hearing_screen.dart';
import 'package:haqdaar/features/case_tracking/presentation/screens/case_list_screen.dart';
import 'package:haqdaar/features/expense_tracking/presentation/screens/add_expense_screen.dart';
import 'package:haqdaar/features/expense_tracking/presentation/screens/expense_tracker_screen.dart';
import 'package:haqdaar/features/profile/presentation/screens/profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:haqdaar/core/localization/app_localizations.dart';
import 'package:haqdaar/core/localization/locale_provider.dart';
import 'package:haqdaar/shared_widgets/shared_widgets.dart';
import 'package:haqdaar/features/auth/presentation/screens/login_screen.dart';
import 'package:haqdaar/features/case_tracking/presentation/providers/case_provider.dart';
import 'package:haqdaar/features/expense_tracking/presentation/providers/expense_provider.dart';
import 'package:haqdaar/features/case_tracking/domain/models/hearing_model.dart';
import 'find_authority_screen.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen> {
  final _pageController = PageController(initialPage: 0);
  final _notchController = NotchBottomBarController(index: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
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
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final userName = ref.watch(userNameProvider);

    final List<Widget> pages = [
      _buildHomeContent(lang, userName),
      const Center(child: Text('Documents - Coming Soon')),
      const ExpenseTrackerScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      extendBody: true,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          if (_notchController.index != 0) {
            _notchController.index = 0;
            _pageController.jumpToPage(0);
          }
        },
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: pages,
        ),
      ),
      bottomNavigationBar: AnimatedNotchBottomBar(
        notchBottomBarController: _notchController,
        color: Colors.white,
        showLabel: true,
        textOverflow: TextOverflow.visible,
        maxLine: 1,
        shadowElevation: 6,
        kBottomRadius: 24.0,
        notchColor: const Color(0xFF135D38),
        removeMargins: false,
        bottomBarWidth: MediaQuery.of(context).size.width,
        showShadow: true,
        durationInMilliSeconds: 300,
        itemLabelStyle: const TextStyle(
          color: Color(0xFF135D38),
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        elevation: 3,
        kIconSize: 24.0,
        bottomBarItems: [
          BottomBarItem(
            inActiveItem: const Icon(
              Icons.home_outlined,
              color: Color(0xFF64748B),
              size: 24,
            ),
            activeItem: const Icon(
              Icons.home_rounded,
              color: Colors.white,
              size: 26,
            ),
            itemLabel: AppLocalizations.translate(lang, 'home'),
          ),
          BottomBarItem(
            inActiveItem: const Icon(
              Icons.description_outlined,
              color: Color(0xFF64748B),
              size: 24,
            ),
            activeItem: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 26,
            ),
            itemLabel: AppLocalizations.translate(lang, 'documents'),
          ),
          BottomBarItem(
            inActiveItem: const Icon(
              Icons.account_balance_wallet_outlined,
              color: Color(0xFF64748B),
              size: 24,
            ),
            activeItem: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 26,
            ),
            itemLabel: AppLocalizations.translate(lang, 'expenses'),
          ),
          BottomBarItem(
            inActiveItem: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFF64748B),
              size: 24,
            ),
            activeItem: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 26,
            ),
            itemLabel: AppLocalizations.translate(lang, 'profile'),
          ),
        ],
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
      ),
    );
  }

  Widget _buildHomeContent(String lang, String userName) {
    final topPadding = MediaQuery.of(context).padding.top;
    final casesAsync = ref.watch(casesStreamProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);
    final hearingsAsync = ref.watch(hearingsStreamProvider);

    final activeCasesCount = casesAsync.maybeWhen(
      data: (cases) => cases.where((c) {
        final st = c.status.toLowerCase();
        return st == 'active' || st == 'pending' || st == 'open';
      }).length,
      orElse: () => 0,
    );

    final totalExpenses = expensesAsync.maybeWhen(
      data: (expenses) => expenses.fold<double>(0.0, (sum, e) => sum + e.amount),
      orElse: () => 0.0,
    );

    final formattedExpense = totalExpenses > 0
        ? 'PKR ${NumberFormat('#,###').format(totalExpenses.round())}'
        : 'PKR 0';

    final upcomingHearings = <HearingModel>[];
    hearingsAsync.whenData((list) {
      upcomingHearings.addAll(list);
    });
    if (upcomingHearings.isEmpty) {
      casesAsync.whenData((cases) {
        for (var c in cases) {
          upcomingHearings.add(
            HearingModel(
              id: c.id,
              title: c.title,
              courtName: c.courtName,
              hearingDate: c.nextHearingDate,
              hearingTime: DateFormat('hh:mm a').format(c.nextHearingDate),
            ),
          );
        }
      });
    }
    upcomingHearings.sort((a, b) => a.hearingDate.compareTo(b.hearingDate));

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 90.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Curved Forest Green Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF135D38),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.translate(lang, 'welcome_back'),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                // Actions Row: Language Switcher + Logout
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            final newLang = lang == 'en' ? 'ur' : 'en';
                            ref.read(localeProvider.notifier).setLocale(newLang);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            child: Text(
                              lang == 'en' ? 'اردو' : 'EN',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () => _handleLogout(context),
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 14),

                // Metrics Row (Active Cases & Total Expenses)
                Row(
                  children: [
                    Expanded(
                      child: SummaryCard(
                        title: AppLocalizations.translate(lang, 'active_cases'),
                        value: activeCasesCount.toString(),
                        valueColor: const Color(0xFF0D5E36),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CaseListScreen()),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SummaryCard(
                        title: AppLocalizations.translate(lang, 'total_expenses'),
                        value: formattedExpense,
                        valueColor: const Color(0xFFBA8A2D),
                        onTap: () {
                          _pageController.jumpToPage(2);
                          _notchController.jumpTo(2);
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Quick Actions Header
                Text(
                  AppLocalizations.translate(lang, 'quick_actions'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 10),

                // 2x2 Quick Actions Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.25,
                  children: [
                    ActionCard(
                      icon: Icons.description_rounded,
                      iconColor: const Color(0xFF135D38),
                      iconBackgroundColor: const Color(0xFFE8F3ED),
                      label: AppLocalizations.translate(lang, 'generate_document'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AiDocumentGeneratorScreen()),
                        );
                      },
                    ),
                    ActionCard(
                      icon: Icons.auto_awesome_rounded,
                      iconColor: const Color(0xFFBA8A2D),
                      iconBackgroundColor: const Color(0xFFFEF7E6),
                      label: AppLocalizations.translate(lang, 'ask_ai'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AiLegalAdvisorScreen()),
                        );
                      },
                    ),
                    ActionCard(
                      icon: Icons.location_city_rounded,
                      iconColor: const Color(0xFF1565C0),
                      iconBackgroundColor: const Color(0xFFE3F2FD),
                      label: AppLocalizations.translate(lang, 'find_authority'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FindAuthorityScreen()),
                        );
                      },
                    ),
                    ActionCard(
                      icon: Icons.balance_rounded,
                      iconColor: const Color(0xFF6A1B9A),
                      iconBackgroundColor: const Color(0xFFF3E5F5),
                      label: AppLocalizations.translate(lang, 'track_case'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CaseListScreen()),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Upcoming Hearings Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppLocalizations.translate(lang, 'upcoming_hearings'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Add Expense shortcut
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Tooltip(
                            message: AppLocalizations.translate(lang, 'add_expense'),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: Color(0xFF135D38),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Add Hearing shortcut
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF135D38),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF135D38).withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Tooltip(
                            message: AppLocalizations.translate(lang, 'add_hearing'),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddHearingScreen()),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.calendar_month_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Upcoming Hearings Dynamic Content
                if (upcomingHearings.isNotEmpty)
                  ...upcomingHearings.take(3).map((item) {
                    final d = item.hearingDate;
                    final timeStr = item.hearingTime.isNotEmpty
                        ? item.hearingTime
                        : DateFormat('hh:mm a').format(d);
                    return HearingItemCard(
                      title: item.title,
                      court: item.courtName.isNotEmpty ? item.courtName : 'Civil Court',
                      date: DateFormat('MMM dd, yyyy').format(d),
                      time: timeStr,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CaseListScreen()),
                        );
                      },
                    );
                  })
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 32,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No Upcoming Hearings',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep track of your case dates and schedule hearings',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddHearingScreen()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Schedule Hearing'),
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF135D38),
                            backgroundColor: const Color(0xFF135D38).withValues(alpha: 0.08),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
