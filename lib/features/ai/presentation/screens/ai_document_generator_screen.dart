import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_constants.dart';

class AiDocumentGeneratorScreen extends StatefulWidget {
  const AiDocumentGeneratorScreen({super.key});

  @override
  State<AiDocumentGeneratorScreen> createState() => _AiDocumentGeneratorScreenState();
}

class _AiDocumentGeneratorScreenState extends State<AiDocumentGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'I can help you generate legal documents formatted for Pakistani courts. What do you need? (e.g. Kiraaya Nama / Rent Agreement, Bayan-e-Halfi / Affidavit, Mukhtar Nama / Power of Attorney).'}
  ];
  bool _isGenerating = false;

  Future<void> _sendMessage() async {
    if (_promptController.text.trim().isEmpty) return;
    
    final text = _promptController.text;
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _promptController.clear();
      _isGenerating = true;
    });

    try {
      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: ApiConstants.geminiApiKey,
      );

      final prompt = 'You are HaqDaar, an AI that generates Pakistani legal documents based on user requests. Generate a draft of the document requested by the user. Do not explain, just generate the text of the document.\n\nUser Request: $text';
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add({'role': 'ai', 'content': 'I have prepared a comprehensive document based on your request:\n\n${response.text}'});
          _messages.add({'role': 'document', 'content': 'Generated_Document.pdf'});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add({'role': 'ai', 'content': 'Error generating document: Ensure you have added a valid API Key in ApiConstants.geminiApiKey. Details: $e'});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Document Generator'),
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                final isDoc = message['role'] == 'document';

                if (isDoc) {
                  return _buildDocumentCard(message['content']!);
                }

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.green.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(message['content']!, style: const TextStyle(fontSize: 16)),
                  ),
                );
              },
            ),
          ),
          if (_isGenerating) const Padding(
            padding: EdgeInsets.all(8.0),
            child: CircularProgressIndicator(),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: 'Ask for a legal document...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.green.shade800,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDocumentCard(String docName) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.green.shade300, width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade400, size: 40),
        title: Text(docName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text('245 KB'),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () {
            // TODO: Implement PDF download
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Downloading PDF...')));
          },
        ),
      ),
    );
  }
}
