import 'package:flutter/widgets.dart';
import 'package:listbook/translation.dart';

class TranslationDelegate extends LocalizationsDelegate<Translations> {
  @override
  bool isSupported(Locale locale) => ['ko', 'en'].contains(locale.languageCode);

  @override
  Future<Translations> load(Locale locale) async {
    Translations localizations = Translations(locale);
    await localizations.load();

    print("Load ${locale.languageCode}");

    return localizations;
  }

  @override
  bool shouldReload(TranslationDelegate old) => false;
}
