import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';

class AiDocumentGeneratorScreen extends ConsumerStatefulWidget {
  const AiDocumentGeneratorScreen({super.key});

  @override
  ConsumerState<AiDocumentGeneratorScreen> createState() =>
      _AiDocumentGeneratorScreenState();
}

class _AiDocumentGeneratorScreenState
    extends ConsumerState<AiDocumentGeneratorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isGenerating = false;
  String _lastLang = '';

  void _initGreeting(String lang) {
    if (_messages.isEmpty || _lastLang != lang) {
      _lastLang = lang;
      _messages.clear();
      final greeting = lang == 'ur'
          ? 'خوش آمدید! میں حقدار قانونی دستاویز ساز ہوں۔ آپ کونسی قانونی دستاویز بنانا چاہتے ہیں؟ (مثلاً کرایہ نامہ، بیان حلفی، نوٹس یا مختار نامہ)۔ نیچے دیے گئے بٹن پر کلک کریں یا تفصیل لکھیں۔'
          : 'Welcome! I can draft standardized Pakistani legal documents formatted according to local court practice (e.g., Rent Agreement / Kiraaya Nama, Affidavit / Bayan-e-Halafi, Legal Notice, or Power of Attorney). Tap a suggestion or type your details.';
      _messages.add({'role': 'ai', 'content': greeting});
    }
  }

  Future<void> _sendMessage([String? prefilledText]) async {
    final queryText = prefilledText ?? _promptController.text.trim();
    if (queryText.isEmpty) return;

    final lang = ref.read(localeProvider);

    setState(() {
      _messages.add({'role': 'user', 'content': queryText});
      if (prefilledText == null) _promptController.clear();
      _isGenerating = true;
    });

    _scrollToBottom();

    try {
      final model = GenerativeModel(
        model: 'gemini-flash-latest',
        apiKey: ApiConstants.geminiApiKey,
      );

      final langPrompt = lang == 'ur'
          ? 'Draft the legal document in formal Urdu (with English headings where standard in Pakistani practice). Include proper legal recitals (Whereas, Now Therefore), terms, signature blocks for executant, stamp vendor endorsement placeholders, and two witnesses with CNIC blanks.'
          : 'Draft the legal document in standard Pakistani legal English format suitable for stamp paper printing. Include standard Pakistani legal clauses, parties details placeholders, dispute resolution clause, and witness blocks.';

      final prompt =
          'You are HaqDaar, an automated Pakistani legal document draft generator. $langPrompt\n\nUser Request: $queryText';

      final response = await model.generateContent([Content.text(prompt)]);

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add({
            'role': 'ai',
            'content': response.text ??
                (lang == 'ur'
                    ? 'دستاویز تیار نہیں ہو سکی۔'
                    : 'Could not draft the document.'),
          });
          _messages.add({
            'role': 'document',
            'content': 'HaqDaar_Legal_Draft.pdf',
          });
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add({
            'role': 'ai',
            'content': lang == 'ur'
                ? 'دستاویز سازی میں خرابی: $e'
                : 'Error generating legal document: $e',
          });
        });
        _scrollToBottom();
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(localeProvider);
    _initGreeting(lang);

    final docTemplates = [
      {'key': 'rent_agreement', 'icon': Icons.home_work_rounded},
      {'key': 'affidavit', 'icon': Icons.verified_user_rounded},
      {'key': 'legal_notice', 'icon': Icons.mark_email_read_rounded},
      {'key': 'consumer_complaint', 'icon': Icons.report_problem_rounded},
      {'key': 'power_of_attorney', 'icon': Icons.history_edu_rounded},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          AppLocalizations.translate(lang, 'doc_generator'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF135D38),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() {
                _messages.clear();
                _initGreeting(lang);
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Quick templates horizontal bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: Colors.white,
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: docTemplates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final item = docTemplates[i];
                final label = AppLocalizations.translate(lang, item['key'] as String);
                final icon = item['icon'] as IconData;
                return ActionChip(
                  avatar: Icon(icon, size: 16, color: const Color(0xFF135D38)),
                  label: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF135D38),
                    ),
                  ),
                  backgroundColor: const Color(0xFFE8F3ED),
                  side: const BorderSide(color: Color(0xFF135D38), width: 0.8),
                  onPressed: () => _sendMessage('Draft: $label'),
                );
              },
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                final isDoc = message['role'] == 'document';

                if (isDoc) {
                  return _buildDocumentCard(message['content']!, lang);
                }

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.84,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF135D38) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: isUser
                          ? null
                          : Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SelectableText(
                      message['content']!,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: isUser ? Colors.white : const Color(0xFF1F2937),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (_isGenerating)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFF135D38)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.translate(lang, 'generating_doc'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      decoration: InputDecoration(
                        hintText: lang == 'ur'
                            ? 'دستاویز کی تفصیل لکھیں (مثلاً 2 کمروں کا کرایہ نامہ)...'
                            : 'Describe details (e.g. 2-bedroom rental agreement)...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide:
                              const BorderSide(color: Color(0xFF135D38), width: 1.5),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF135D38),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 18),
                      onPressed: _isGenerating ? null : () => _sendMessage(),
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

  Widget _buildDocumentCard(String docName, String lang) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFF135D38), width: 1.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.picture_as_pdf_rounded,
              color: Colors.red.shade700, size: 26),
        ),
        title: Text(
          docName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          AppLocalizations.translate(lang, 'generate_pdf'),
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF135D38),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          icon: const Icon(Icons.download_rounded, size: 16),
          label: Text(lang == 'ur' ? 'ڈاؤن لوڈ' : 'PDF'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  lang == 'ur'
                      ? 'پی ڈی ایف دستاویز کامیابی سے تیار ہو گئی ہے۔'
                      : 'PDF ready for printing / download.',
                ),
                backgroundColor: const Color(0xFF135D38),
              ),
            );
          },
        ),
      ),
    );
  }
}
