import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/case_provider.dart';
import 'case_details_screen.dart';

class CaseListScreen extends ConsumerWidget {
  const CaseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casesAsyncValue = ref.watch(casesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cases (Mera Muqadma)'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: casesAsyncValue.when(
        data: (cases) {
          if (cases.isEmpty) {
            return const Center(child: Text('No active cases found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: cases.length,
            itemBuilder: (context, index) {
              final caseItem = cases[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(caseItem.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text('Court: ${caseItem.courtName}'),
                      Text('Next Hearing: ${DateFormat('dd MMM yyyy').format(caseItem.nextHearingDate)}', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Chip(
                        label: Text(caseItem.status, style: const TextStyle(color: Colors.white)),
                        backgroundColor: caseItem.status == 'Active' ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
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
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: Implement Add Case dialog
        },
        label: const Text('Add Case'),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
    );
  }
}
