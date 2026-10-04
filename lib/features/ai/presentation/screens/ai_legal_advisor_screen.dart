import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_constants.dart';

class AiLegalAdvisorScreen extends StatefulWidget {
  const AiLegalAdvisorScreen({super.key});

  @override
  State<AiLegalAdvisorScreen> createState() => _AiLegalAdvisorScreenState();
}

class _AiLegalAdvisorScreenState extends State<AiLegalAdvisorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final List<Map<String, String>> _messages = [
    {'role': 'ai', 'content': 'Hello, I am your HaqDaar Legal Advisor. Please describe your legal problem and I will explain your rights, potential sanctions, and necessary evidence according to Pakistani law.'}
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

      final prompt = 'You are HaqDaar, an expert in Pakistani law. Answer the user\'s legal query in simple language, referencing local Pakistani court terminology where appropriate (like Katchery, Session Court, Kiraaya Nama, etc).\n\nUser Query: $text';
      
      final response = await model.generateContent([Content.text(prompt)]);
      
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add({'role': 'ai', 'content': response.text ?? 'I could not generate an answer.'});
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add({'role': 'ai', 'content': 'Error: Ensure you have added a valid API Key in ApiConstants.geminiApiKey. Details: $e'});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Legal Advisor'),
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
                        hintText: 'Describe your legal issue...',
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
}
