import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haqdaar/core/localization/app_localizations.dart';
import 'package:haqdaar/core/localization/locale_provider.dart';
import 'package:haqdaar/features/case_tracking/data/repositories/hearing_repository.dart';
import 'package:haqdaar/features/case_tracking/domain/models/hearing_model.dart';

class AddHearingScreen extends ConsumerStatefulWidget {
  const AddHearingScreen({super.key});

  @override
  ConsumerState<AddHearingScreen> createState() => _AddHearingScreenState();
}

class _AddHearingScreenState extends ConsumerState<AddHearingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _courtController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  String _selectedCourtType = 'District Court';
  bool _isLoading = false;

  static const List<String> _courtTypes = [
    'District Court',
    'High Court',
    'Supreme Court',
    'Civil Court',
    'Sessions Court',
    'Family Court',
    'Labour Court',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _courtController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF135D38),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF135D38),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final userId = user?.uid ?? 'guest_user';

    setState(() => _isLoading = true);

    try {
      final timeStr = _selectedTime.format(context);
      final courtName = _selectedCourtType == 'Other'
          ? _courtController.text.trim()
          : _selectedCourtType;

      final hearing = HearingModel(
        id: '',
        title: _titleController.text.trim(),
        courtName: courtName,
        hearingDate: _selectedDate,
        hearingTime: timeStr,
        notes: _notesController.text.trim(),
      );

      await HearingRepository().addHearing(hearing, userId);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hearing added successfully!'),
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

  String _getCourtTypeTranslation(String court, String lang) {
    switch (court) {
      case 'District Court':
        return AppLocalizations.translate(lang, 'district_court');
      case 'High Court':
        return AppLocalizations.translate(lang, 'high_court');
      case 'Supreme Court':
        return AppLocalizations.translate(lang, 'supreme_court');
      case 'Civil Court':
        return AppLocalizations.translate(lang, 'civil_court');
      case 'Sessions Court':
        return AppLocalizations.translate(lang, 'sessions_court');
      case 'Family Court':
        return AppLocalizations.translate(lang, 'family_court');
      case 'Labour Court':
        return AppLocalizations.translate(lang, 'labour_court');
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
          AppLocalizations.translate(lang, 'add_hearing'),
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
              // Info Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F3ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF135D38).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF135D38), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        AppLocalizations.translate(lang, 'hearing_reminder'),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green.shade900,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Case / Matter Title
              _buildLabel('${AppLocalizations.translate(lang, 'hearing_title')} *'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? AppLocalizations.translate(lang, 'enter_hearing_title') : null,
                decoration: _inputDecoration(
                  hint: AppLocalizations.translate(lang, 'hearing_title_hint'),
                  icon: Icons.gavel_rounded,
                ),
              ),
              const SizedBox(height: 20),

              // Court Type Selector
              _buildLabel('${AppLocalizations.translate(lang, 'select_court')} *'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _courtTypes.map((ct) {
                  final isSelected = _selectedCourtType == ct;
                  final ctLabel = _getCourtTypeTranslation(ct, lang);
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCourtType = ct),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF135D38) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF135D38) : const Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [const BoxShadow(color: Color(0x40135D38), blurRadius: 6, offset: Offset(0, 2))]
                            : [],
                      ),
                      child: Text(
                        ctLabel,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : const Color(0xFF374151),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Show custom court input if 'Other' is selected
              if (_selectedCourtType == 'Other') ...[
                const SizedBox(height: 16),
                _buildLabel('${AppLocalizations.translate(lang, 'court_name')} *'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _courtController,
                  validator: (v) => _selectedCourtType == 'Other' && (v == null || v.trim().isEmpty)
                      ? AppLocalizations.translate(lang, 'enter_court_name')
                      : null,
                  decoration: _inputDecoration(
                    hint: AppLocalizations.translate(lang, 'court_name_hint'),
                    icon: Icons.account_balance_rounded,
                  ),
                ),
              ],
              const SizedBox(height: 20),

              // Date & Time Row
              _buildLabel('${AppLocalizations.translate(lang, 'hearing_date')} & ${AppLocalizations.translate(lang, 'time')} *'),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month_rounded,
                                color: Color(0xFF135D38), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                color: Color(0xFF135D38), size: 18),
                            const SizedBox(width: 8),
                            Text(
                              _selectedTime.format(context),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Notes
              _buildLabel('${AppLocalizations.translate(lang, 'notes')} (${AppLocalizations.translate(lang, 'optional')})'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: _inputDecoration(
                  hint: '...',
                  icon: Icons.notes_rounded,
                ),
              ),
              const SizedBox(height: 32),

              // Submit
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
                            const Icon(Icons.event_available_rounded),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.translate(lang, 'save_hearing'),
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

  InputDecoration _inputDecoration({required String hint, required IconData icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF135D38), size: 20),
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
    );
  }
}
