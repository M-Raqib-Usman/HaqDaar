import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haqdaar/core/localization/app_localizations.dart';
import 'package:haqdaar/core/localization/locale_provider.dart';
import '../providers/expense_provider.dart';
import '../../domain/models/expense_model.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCategory = 'Lawyer Fee';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  static const List<String> _categories = [
    'Lawyer Fee',
    'Court Fee',
    'Travel',
    'Documentation',
    'Other',
  ];

  static const Map<String, IconData> _categoryIcons = {
    'Lawyer Fee': Icons.gavel_rounded,
    'Court Fee': Icons.account_balance_rounded,
    'Travel': Icons.directions_car_rounded,
    'Documentation': Icons.description_rounded,
    'Other': Icons.receipt_long_rounded,
  };

  static const Map<String, Color> _categoryColors = {
    'Lawyer Fee': Color(0xFF135D38),
    'Court Fee': Color(0xFF1565C0),
    'Travel': Color(0xFFE65100),
    'Documentation': Color(0xFF6A1B9A),
    'Other': Color(0xFF546E7A),
  };

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF135D38),
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest_user';

    setState(() => _isLoading = true);

    try {
      final expense = ExpenseModel(
        id: '',
        caseId: '',
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text.trim()),
        date: _selectedDate,
        category: _selectedCategory,
      );

      await ref.read(expenseRepositoryProvider).addExpense(expense, userId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: Color(0xFF135D38),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF135D38),
        foregroundColor: Colors.white,
        title: Text(
          AppLocalizations.translate(lang, 'add_expense'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              _buildLabel(AppLocalizations.translate(lang, 'title')),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _titleController,
                hint: AppLocalizations.translate(lang, 'expense_title_hint'),
                icon: Icons.title_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? AppLocalizations.translate(lang, 'enter_expense_title') : null,
              ),
              const SizedBox(height: 20),

              // Amount Field
              _buildLabel(AppLocalizations.translate(lang, 'amount')),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _amountController,
                hint: '0.00',
                prefixText: 'PKR ',
                icon: Icons.payments_rounded,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return AppLocalizations.translate(lang, 'enter_amount');
                  final val = double.tryParse(v.trim());
                  if (val == null || val <= 0) return AppLocalizations.translate(lang, 'enter_valid_amount');
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Selector
              _buildLabel(AppLocalizations.translate(lang, 'category')),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  final color = _categoryColors[cat]!;
                  final catLabel = _getCategoryTranslation(cat, lang);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? color : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                            : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcons[cat],
                            size: 16,
                            color: isSelected ? Colors.white : color,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            catLabel,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : const Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Date Picker
              _buildLabel(AppLocalizations.translate(lang, 'date')),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF135D38), size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.edit_calendar_rounded, color: Colors.grey.shade400, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Notes Field (optional)
              _buildLabel('${AppLocalizations.translate(lang, 'notes')} (${AppLocalizations.translate(lang, 'optional')})'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _notesController,
                hint: '...',
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF135D38),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_circle_outline_rounded),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.translate(lang, 'save_expense'),
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? prefixText,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF135D38), size: 20),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          color: Color(0xFF135D38),
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF135D38), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
