import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Translations {
  Translations(this.locale);

  final Locale locale;

  static Translations? of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations);
  }

  late Map<String, String> _sentences;

  String getLocale() {
    return locale.languageCode;
  }

  Future<bool> load() async {
    String data = await rootBundle.loadString('assets/trans/${locale.languageCode}.json'); // 경로 유의
    // String data = await rootBundle.loadString('assets/trans/en.json'); // 경로 유의
    Map<String, dynamic> result = json.decode(data);

    _sentences = <String, String>{};
    result.forEach((String key, dynamic value) {
      _sentences[key] = value.toString();
    });

    return true;
  }

  String? trans(String key) {
    return _sentences[key];
  }
}
