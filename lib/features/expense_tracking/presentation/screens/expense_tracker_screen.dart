import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:haqdaar/core/localization/app_localizations.dart';
import 'package:haqdaar/core/localization/locale_provider.dart';
import 'package:haqdaar/features/case_tracking/presentation/screens/add_hearing_screen.dart';
import '../providers/expense_provider.dart';
import '../../domain/models/expense_model.dart';
import 'add_expense_screen.dart';

class ExpenseTrackerScreen extends ConsumerStatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  ConsumerState<ExpenseTrackerScreen> createState() =>
      _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends ConsumerState<ExpenseTrackerScreen>
    with SingleTickerProviderStateMixin {
  bool _speedDialOpen = false;
  late AnimationController _fabAnimController;
  late Animation<double> _fabRotateAnim;
  late Animation<double> _fabScaleAnim;

  @override
  void initState() {
    super.initState();
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _fabRotateAnim = Tween<double>(begin: 0, end: 0.375).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeOut),
    );
    _fabScaleAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fabAnimController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _fabAnimController.dispose();
    super.dispose();
  }

  void _toggleSpeedDial() {
    setState(() => _speedDialOpen = !_speedDialOpen);
    if (_speedDialOpen) {
      _fabAnimController.forward();
    } else {
      _fabAnimController.reverse();
    }
  }

  void _closeSpeedDial() {
    if (_speedDialOpen) {
      setState(() => _speedDialOpen = false);
      _fabAnimController.reverse();
    }
  }

  void _navigateToAddExpense() {
    _closeSpeedDial();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddExpenseScreen()),
    );
  }

  void _navigateToAddHearing() {
    _closeSpeedDial();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddHearingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    final expensesAsync = ref.watch(expensesStreamProvider);

    return GestureDetector(
      onTap: _closeSpeedDial,
      child: Scaffold(
        backgroundColor: const Color(0xFFF9FAFB),
        appBar: AppBar(
          title: Text(
            AppLocalizations.translate(lang, 'expense_tracker'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF135D38),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: expensesAsync.when(
          data: (expenses) {
            final totalAmount =
                expenses.fold(0.0, (sum, item) => sum + item.amount);
            return Column(
              children: [
                _buildSummaryCard(totalAmount, lang),
                if (expenses.isNotEmpty) _buildChartCard(expenses, lang),
                Expanded(
                  child: expenses.isEmpty
                      ? _buildEmptyState(lang)
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: expenses.length,
                          itemBuilder: (context, index) {
                            final expense = expenses[index];
                            return _buildExpenseTile(expense, lang);
                          },
                        ),
                ),
              ],
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF135D38)),
          ),
          error: (err, _) => Center(
            child: Text(
              '${AppLocalizations.translate(lang, 'error')}: $err',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ),
        // FAB is rendered as overlay — positioned above nav bar in the home scaffold
        floatingActionButton: _buildSpeedDial(lang),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
    );
  }

  Widget _buildSpeedDial(String lang) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Speed Dial Items
        ScaleTransition(
          scale: _fabScaleAnim,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildSpeedDialItem(
                label: AppLocalizations.translate(lang, 'add_hearing'),
                icon: Icons.event_available_rounded,
                color: const Color(0xFF1565C0),
                onTap: _navigateToAddHearing,
              ),
              const SizedBox(height: 12),
              _buildSpeedDialItem(
                label: AppLocalizations.translate(lang, 'add_expense'),
                icon: Icons.receipt_long_rounded,
                color: const Color(0xFF135D38),
                onTap: _navigateToAddExpense,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        // Main FAB
        FloatingActionButton(
          heroTag: 'expense_main_fab',
          onPressed: _toggleSpeedDial,
          backgroundColor: const Color(0xFF135D38),
          foregroundColor: Colors.white,
          elevation: 4,
          child: RotationTransition(
            turns: _fabRotateAnim,
            child: const Icon(Icons.add_rounded, size: 30),
          ),
        ),
        // Extra bottom padding so FAB clears the notch nav bar
        const SizedBox(height: 72),
      ],
    );
  }

  Widget _buildSpeedDialItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Mini FAB
        FloatingActionButton.small(
          heroTag: 'fab_$label',
          onPressed: onTap,
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          child: Icon(icon, size: 20),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF135D38).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 40,
              color: Color(0xFF135D38),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.translate(lang, 'no_expenses'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              AppLocalizations.translate(lang, 'no_expenses_sub'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryTranslation(String category, String lang) {
    switch (category) {
      case 'Lawyer Fee':
        return AppLocalizations.translate(lang, 'lawyer_fee');
      case 'Court Fee':
        return AppLocalizations.translate(lang, 'court_fee');
      case 'Travel':
        return AppLocalizations.translate(lang, 'travel');
      case 'Documentation':
        return AppLocalizations.translate(lang, 'documentation');
      default:
        return AppLocalizations.translate(lang, 'other');
    }
  }

  Widget _buildExpenseTile(ExpenseModel expense, String lang) {
    const categoryColors = {
      'Lawyer Fee': Color(0xFF135D38),
      'Court Fee': Color(0xFF1565C0),
      'Travel': Color(0xFFE65100),
      'Documentation': Color(0xFF6A1B9A),
      'Other': Color(0xFF546E7A),
    };
    const categoryIcons = {
      'Lawyer Fee': Icons.gavel_rounded,
      'Court Fee': Icons.account_balance_rounded,
      'Travel': Icons.directions_car_rounded,
      'Documentation': Icons.description_rounded,
      'Other': Icons.receipt_long_rounded,
    };

    final color = categoryColors[expense.category] ?? const Color(0xFF546E7A);
    final icon = categoryIcons[expense.category] ?? Icons.receipt_long_rounded;
    final catName = _getCategoryTranslation(expense.category, lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: const [
          BoxShadow(color: Color(0x0D000000), blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          '$catName • ${DateFormat('dd MMM yyyy').format(expense.date)}',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
        ),
        trailing: Text(
          'PKR ${NumberFormat('#,###').format(expense.amount)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Color(0xFFDC2626),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(double total, String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF135D38), Color(0xFF1A8050)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Color(0x40135D38), blurRadius: 12, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.translate(lang, 'total_spent'),
            style: const TextStyle(color: Colors.white70, fontSize: 14, letterSpacing: 0.3),
          ),
          const SizedBox(height: 10),
          Text(
            'PKR ${NumberFormat('#,###').format(total)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(List<ExpenseModel> expenses, String lang) {
    final Map<String, double> categoryTotals = {};
    for (var expense in expenses) {
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    const colors = [
      Color(0xFF135D38),
      Color(0xFF1565C0),
      Color(0xFFE65100),
      Color(0xFF6A1B9A),
      Color(0xFF546E7A),
    ];

    int colorIndex = 0;
    final List<PieChartSectionData> sections = [];
    final List<Widget> legendItems = [];

    categoryTotals.forEach((category, amount) {
      final color = colors[colorIndex % colors.length];
      final catName = _getCategoryTranslation(category, lang);
      sections.add(PieChartSectionData(
        color: color,
        value: amount,
        title: '',
        radius: 38,
      ));
      legendItems.add(Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
          ),
          const SizedBox(width: 5),
          Text(
            '$catName: PKR ${NumberFormat('#,###').format(amount)}',
            style: const TextStyle(fontSize: 11.5),
          ),
        ],
      ));
      colorIndex++;
    });

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              AppLocalizations.translate(lang, 'monthly_overview'),
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 130,
              child: PieChart(PieChartData(
                sections: sections,
                centerSpaceRadius: 36,
                sectionsSpace: 2,
              )),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              alignment: WrapAlignment.center,
              children: legendItems,
            ),
          ],
        ),
      ),
    );
  }
}
