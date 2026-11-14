import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haqdaar/core/localization/app_localizations.dart';
import 'package:haqdaar/core/localization/locale_provider.dart';
import '../../domain/models/case_model.dart';
import '../providers/case_provider.dart';
import 'case_details_screen.dart';

class CaseListScreen extends ConsumerWidget {
  const CaseListScreen({super.key});

  void _showAddCaseModal(BuildContext context, WidgetRef ref, String lang) {
    final titleController = TextEditingController();
    final courtController = TextEditingController();
    final lawyerController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String selectedStatus = 'Active';
    final formKey = GlobalKey<FormState>();
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Add New Case',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF111827),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => Navigator.pop(ctx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      TextFormField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Case Title *',
                          hintText: 'e.g. Property Dispute - Katchery',
                          prefixIcon: const Icon(Icons.title_rounded, color: Color(0xFF135D38)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter case title' : null,
                      ),
                      const SizedBox(height: 12),

                      // Court Name
                      TextFormField(
                        controller: courtController,
                        decoration: InputDecoration(
                          labelText: 'Court Name *',
                          hintText: 'e.g. Civil Court, Lahore',
                          prefixIcon: const Icon(Icons.account_balance_rounded, color: Color(0xFF135D38)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter court name' : null,
                      ),
                      const SizedBox(height: 12),

                      // Lawyer Name
                      TextFormField(
                        controller: lawyerController,
                        decoration: InputDecoration(
                          labelText: 'Lawyer Name',
                          hintText: 'e.g. Adv. Ahmed Khan',
                          prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFF135D38)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Next Hearing Date
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: ctx,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9FAFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade400),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month_rounded, color: Color(0xFF135D38)),
                              const SizedBox(width: 12),
                              Text(
                                'Next Hearing: ${DateFormat('dd MMM yyyy').format(selectedDate)}',
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                              const Spacer(),
                              const Icon(Icons.edit_calendar_rounded, size: 18, color: Color(0xFF135D38)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Description
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Case Description / Notes',
                          hintText: 'Brief summary of the case...',
                          prefixIcon: const Icon(Icons.notes_rounded, color: Color(0xFF135D38)),
                          filled: true,
                          fillColor: const Color(0xFFF9FAFB),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSaving
                              ? null
                              : () async {
                                  if (!formKey.currentState!.validate()) return;
                                  setModalState(() => isSaving = true);

                                  final user = FirebaseAuth.instance.currentUser;
                                  final uid = user?.uid ?? 'guest_user';

                                  final newCase = CaseModel(
                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                    title: titleController.text.trim(),
                                    courtName: courtController.text.trim(),
                                    lawyerName: lawyerController.text.trim().isNotEmpty
                                        ? lawyerController.text.trim()
                                        : 'Not Assigned',
                                    description: descController.text.trim(),
                                    status: selectedStatus,
                                    nextHearingDate: selectedDate,
                                  );

                                  await ref.read(caseRepositoryProvider).addCase(newCase, uid);

                                  if (ctx.mounted) {
                                    Navigator.pop(ctx);
                                  }

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Case added successfully!'),
                                        backgroundColor: Color(0xFF135D38),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF135D38),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Save Case',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);
    final casesAsyncValue = ref.watch(casesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.translate(lang, 'my_cases')),
        backgroundColor: const Color(0xFF135D38),
        foregroundColor: Colors.white,
      ),
      body: casesAsyncValue.when(
        data: (cases) {
          if (cases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F3ED),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_open_rounded,
                      size: 36,
                      color: Color(0xFF135D38),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.translate(lang, 'no_cases'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final caseItem = cases[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F3ED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.gavel_rounded,
                      color: Color(0xFF135D38),
                      size: 22,
                    ),
                  ),
                  title: Text(caseItem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text('Court: ${caseItem.courtName}', style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563))),
                      const SizedBox(height: 2),
                      Text(
                        'Next Hearing: ${DateFormat('dd MMM yyyy').format(caseItem.nextHearingDate)}',
                        style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Chip(
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        label: Text(
                          caseItem.status,
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        backgroundColor: caseItem.status == 'Active' ? const Color(0xFF135D38) : Colors.orange.shade800,
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF9CA3AF)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CaseDetailsScreen(caseModel: caseItem),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF135D38))),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddCaseModal(context, ref, lang),
        label: const Text('Add Case'),
        icon: const Icon(Icons.add_rounded),
        backgroundColor: const Color(0xFF135D38),
        foregroundColor: Colors.white,
      ),
    );
  }
}
