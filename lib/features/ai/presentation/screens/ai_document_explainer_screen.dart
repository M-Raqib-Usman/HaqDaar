import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_constants.dart';

class AiDocumentExplainerScreen extends StatefulWidget {
  const AiDocumentExplainerScreen({super.key});

  @override
  State<AiDocumentExplainerScreen> createState() => _AiDocumentExplainerScreenState();
}

class _AiDocumentExplainerScreenState extends State<AiDocumentExplainerScreen> {
  bool _hasDocument = false;
  bool _isAnalyzing = false;
  bool _showExplanation = false;
  String _aiExplanationText = '';

  Future<void> _uploadDocument() async {
    setState(() {
      _hasDocument = true;
      _isAnalyzing = true;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: ApiConstants.geminiApiKey,
      );

      final prompt = 'You are an expert Pakistani lawyer. Read this clause from a tenancy agreement: "Clause 4.2: The tenant shall be responsible for all repairs and maintenance costs exceeding PKR 5,000 per incident." Explain what it means simply in English and identify if this threshold is standard or unfair.';
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _showExplanation = true;
          _aiExplanationText = response.text ?? 'Could not generate explanation.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _showExplanation = true;
          _aiExplanationText = 'Error analyzing document: Ensure you have added a valid API Key in ApiConstants.geminiApiKey. Details: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Explainer'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade200,
              width: double.infinity,
              child: _hasDocument 
                ? _buildDocumentPreview() 
                : _buildUploadZone(),
            ),
          ),
          if (_isAnalyzing)
            const Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('AI is analyzing the document...'),
                  ],
                ),
              ),
            ),
          if (_showExplanation)
            Expanded(
              flex: 4,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -5))
                  ]
                ),
                child: _buildExplanationPanel(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadZone() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.document_scanner, size: 80, color: Colors.grey.shade400),
        const SizedBox(height: 16),
        const Text(
          'Upload or Scan a Legal Document',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.upload_file),
          label: const Text('Select Document'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade800,
            foregroundColor: Colors.white,
          ),
          onPressed: _uploadDocument,
        ),
      ],
    );
  }

  Widget _buildDocumentPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kiraaya_Nama_Draft.pdf', style: TextStyle(fontWeight: FontWeight.bold)),
            const Divider(),
            const Text('Bais tehreer anka (The reason for writing this document) is that...\n'),
            const Text('It is mutually agreed (baham karar paya hay) between the following parties:\n'),
            const Text('Fareeq Awal (First Party): Musama Ahmed Khan (Landlord)\n'),
            const Text('Fareeq Dom (Second Party): Musamat Sarah Ali (Tenant)\n'),
            if (_showExplanation)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange.shade100,
                child: const Text('Clause 4.2: The tenant (Fareeq Dom) shall be responsible for all repairs and maintenance costs exceeding PKR 5,000 per incident.'),
              ),
            if (!_showExplanation)
              const Text('Clause 4.2: The tenant (Fareeq Dom) shall be responsible for all repairs and maintenance costs exceeding PKR 5,000 per incident.'),
            const Text('\nThe monthly rent shall be PKR 45,000...'),
          ],
        ),
      ),
    );
  }

  Widget _buildExplanationPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.green.shade800),
              const SizedBox(width: 8),
              const Text(
                'AI Explanation',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('What this highlighted clause means (اس کا مطلب):', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_aiExplanationText),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              border: Border.all(color: Colors.orange.shade200),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800),
                    const SizedBox(width: 8),
                    Text('Important Note (اہم نوٹ)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange.shade900)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('This threshold is higher than typical Pakistani rental agreements (Kiraaya Nama). Consider negotiating this amount down to PKR 2,000-3,000 to protect yourself before notarizing it at the local Katchery (Court).'),
              ],
            ),
          )
        ],
      ),
    );
  }
}
