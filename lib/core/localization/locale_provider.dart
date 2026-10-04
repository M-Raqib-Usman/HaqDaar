import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleNotifier extends Notifier<String> {
  @override
  String build() {
    return 'en';
  }

  void setLocale(String lang) {
    state = lang;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, String>(() => LocaleNotifier());
