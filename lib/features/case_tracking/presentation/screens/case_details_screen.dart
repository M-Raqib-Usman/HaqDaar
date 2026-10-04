import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/case_model.dart';

class CaseDetailsScreen extends StatelessWidget {
  final CaseModel caseModel;

  const CaseDetailsScreen({super.key, required this.caseModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caseModel.title),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            const Text('Case Timeline (Tareekh-e-Samaat)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildTimelineItem('Next Hearing', DateFormat('dd MMM yyyy').format(caseModel.nextHearingDate), true),
            _buildTimelineItem('Previous Hearing', '12 Jan 2026', false),
            _buildTimelineItem('Case Filed', '01 Jan 2026', false),
            const SizedBox(height: 24),
            const Text('Evidence & Documents (Sabooth)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildDocumentItem('FIR Copy', Icons.picture_as_pdf),
            _buildDocumentItem('Land Registry', Icons.description),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Status: ${caseModel.status}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Divider(),
            const SizedBox(height: 8),
            Text('Court: ${caseModel.courtName}'),
            const SizedBox(height: 8),
            Text('Lawyer (Vakeel): ${caseModel.lawyerName}'),
            const SizedBox(height: 8),
            Text('Description: ${caseModel.description}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String title, String date, bool isNext) {
    return ListTile(
      leading: Icon(Icons.circle, color: isNext ? Colors.red : Colors.grey, size: 16),
      title: Text(title, style: TextStyle(fontWeight: isNext ? FontWeight.bold : FontWeight.normal)),
      trailing: Text(date, style: TextStyle(color: isNext ? Colors.red.shade700 : Colors.black54, fontWeight: isNext ? FontWeight.bold : FontWeight.normal)),
    );
  }

  Widget _buildDocumentItem(String name, IconData icon) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(name),
        trailing: const Icon(Icons.download),
        onTap: () {},
      ),
    );
  }
}
