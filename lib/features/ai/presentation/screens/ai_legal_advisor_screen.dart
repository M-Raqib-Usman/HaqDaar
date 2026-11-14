import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';

class AiLegalAdvisorScreen extends ConsumerStatefulWidget {
  const AiLegalAdvisorScreen({super.key});

  @override
  ConsumerState<AiLegalAdvisorScreen> createState() =>
      _AiLegalAdvisorScreenState();
}

class _AiLegalAdvisorScreenState extends ConsumerState<AiLegalAdvisorScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isGenerating = false;
  String _lastLang = '';

  @override
  void initState() {
    super.initState();
  }

  void _initGreeting(String lang) {
    if (_messages.isEmpty || _lastLang != lang) {
      _lastLang = lang;
      _messages.clear();
      final greeting = lang == 'ur'
          ? 'السلام علیکم! میں حقدار اے آئی قانونی مشیر ہوں۔ آپ پاکستانی قانون سے متعلق اپنا سوال بیان کریں (مثلاً کرایہ داری، خاندانی تنازعات، ضمانت، ایف آئی آر یا چیک باؤنس) اور میں قانونی دفعات اور حقوق کی وضاحت کروں گا۔'
          : 'Hello! I am your HaqDaar Legal Advisor. Please describe your legal question regarding Pakistani civil, criminal, or family law, and I will explain your rights, relevant legal sections, and next steps.';
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

      final langInstruction = lang == 'ur'
          ? 'Respond completely in clear, professional, accessible Urdu (اردو), using proper Pakistani legal terms (جیسے کہ کچہری، سیشن کورٹ، ضمانت، کرایہ نامہ، ایف آئی آر وغیرہ).'
          : 'Respond in clear, accessible English, referencing relevant Pakistani statutes (PPC, CrPC, CPC, Family Courts Act) and court procedures.';

      final prompt =
          'You are HaqDaar, an expert legal advisor specialized in Pakistani Law. $langInstruction\nProvide an empathetic, structured answer with (1) Plain-language explanation, (2) Relevant Pakistani Laws/Sections, (3) Practical Next Steps, and (4) Necessary Evidence or Documents.\n\nUser Query: $queryText';

      final response = await model.generateContent([Content.text(prompt)]);

      if (mounted) {
        setState(() {
          _isGenerating = false;
          _messages.add({
            'role': 'ai',
            'content': response.text ??
                (lang == 'ur'
                    ? 'معذرت، جواب تیار نہیں ہو سکا۔ دوبارہ کوشش کریں۔'
                    : 'I could not generate a response. Please try again.'),
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
                ? 'خرابی: براہ کرم انٹرنیٹ کنکشن چیک کریں۔ تفصیلات: $e'
                : 'Error connecting to legal engine: $e',
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

    final suggestions = [
      AppLocalizations.translate(lang, 'suggestion_1'),
      AppLocalizations.translate(lang, 'suggestion_2'),
      AppLocalizations.translate(lang, 'suggestion_3'),
      AppLocalizations.translate(lang, 'suggestion_4'),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Text(
          AppLocalizations.translate(lang, 'ai_legal_advisor'),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF135D38),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: AppLocalizations.translate(lang, 'clear_chat'),
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
          // Disclaimer alert header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: const Color(0xFFFEF3C7),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.translate(lang, 'disclaimer'),
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF92400E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';

                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.82,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? const Color(0xFF135D38) : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUser ? Icons.person_rounded : Icons.balance_rounded,
                              size: 14,
                              color: isUser ? Colors.white70 : const Color(0xFF135D38),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isUser
                                   ? (lang == 'ur' ? 'آپ' : 'You')
                                  : 'HaqDaar AI',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isUser ? Colors.white70 : const Color(0xFF135D38),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SelectableText(
                          message['content']!,
                          style: TextStyle(
                            fontSize: 14.5,
                            height: 1.45,
                            color: isUser ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Suggestion query chips when few messages
          if (_messages.length <= 2 && !_isGenerating)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: suggestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  return ActionChip(
                    avatar: const Icon(Icons.help_outline_rounded,
                        size: 14, color: Color(0xFF135D38)),
                    label: Text(
                      suggestions[i],
                      style: const TextStyle(fontSize: 12, color: Color(0xFF135D38)),
                    ),
                    backgroundColor: const Color(0xFFE8F3ED),
                    side: const BorderSide(color: Color(0xFF135D38), width: 0.8),
                    onPressed: () => _sendMessage(suggestions[i]),
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
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF135D38)),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    AppLocalizations.translate(lang, 'thinking'),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

          // Input field row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
                        hintText: AppLocalizations.translate(lang, 'type_legal_question'),
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
                          borderSide: const BorderSide(color: Color(0xFF135D38), width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF135D38),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: _isGenerating ? null : () => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
