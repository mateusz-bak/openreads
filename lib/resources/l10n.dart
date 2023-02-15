import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations get l10n => _l10n!;
AppLocalizations? _l10n;

class AppTranslations {
  static init(BuildContext context) {
    _l10n = AppLocalizations.of(context);
  }
}
