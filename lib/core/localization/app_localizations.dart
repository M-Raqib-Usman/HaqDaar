class AppLocalizations {
  static const Map<String, Map<String, String>> _translations = {
    'en': {
      'app_title': 'HaqDaar Dashboard',
      'welcome_back': 'Welcome back,\nAhmed Khan',
      'active_cases': 'Active Cases',
      'total_expenses': 'Total Expenses',
      'quick_actions': 'Quick Actions',
      'generate_document': 'Generate Document',
      'ask_ai': 'Ask AI',
      'explain_document': 'Explain Document',
      'track_case': 'Track Case',
      'upcoming_hearings': 'Upcoming Hearings',
      'home': 'Home',
      'documents': 'Documents',
      'expenses': 'Expenses',
      'profile': 'Profile',
      'settings': 'Settings',
      'language': 'Language',
      'logout': 'Logout',
      'generated_docs': 'Generated Docs',
    },
    'ur': {
      'app_title': 'حقدار ڈیش بورڈ',
      'welcome_back': 'خوش آمدید،\nاحمد خان',
      'active_cases': 'فعال مقدمات',
      'total_expenses': 'کل اخراجات',
      'quick_actions': 'فوری اقدامات',
      'generate_document': 'دستاویز بنائیں',
      'ask_ai': 'اے آئی سے پوچھیں',
      'explain_document': 'دستاویز سمجھیں',
      'track_case': 'مقدمہ ٹریک کریں',
      'upcoming_hearings': 'آئندہ سماعتیں',
      'home': 'ہوم',
      'documents': 'دستاویزات',
      'expenses': 'اخراجات',
      'profile': 'پروفائل',
      'settings': 'ترتیبات',
      'language': 'زبان',
      'logout': 'لاگ آؤٹ',
      'generated_docs': 'بنائی گئی دستاویزات',
    },
  };

  static String translate(String languageCode, String key) {
    return _translations[languageCode]?[key] ?? _translations['en']?[key] ?? key;
  }
}
