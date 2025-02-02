import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

class NynorskMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const NynorskMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale == const Locale('nn');
  }

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    assert(locale == const Locale('nn'));

    return SynchronousFuture<MaterialLocalizations>(
      await GlobalMaterialLocalizations.delegate.load(
        const Locale('no', 'NO'),
      ),
    );
  }

  @override
  bool shouldReload(NynorskMaterialLocalizationsDelegate old) => false;
}

class NynorskCupertinoLocalizationsDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  const NynorskCupertinoLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return locale == const Locale('nn');
  }

  @override
  Future<CupertinoLocalizations> load(Locale locale) async {
    assert(locale == const Locale('nn'));

    return SynchronousFuture<CupertinoLocalizations>(
      await GlobalCupertinoLocalizations.delegate.load(
        const Locale('no', 'NO'),
      ),
    );
  }

  @override
  bool shouldReload(NynorskCupertinoLocalizationsDelegate old) => false;
}
