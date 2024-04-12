import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/welcome_screen/widgets/widgets.dart';

class WelcomePageChoices extends StatelessWidget {
  const WelcomePageChoices({
    super.key,
    required this.restoreBackup,
    required this.importOpenreadsCsv,
    required this.importGoodreadsCsv,
    required this.importBookwyrmCsv,
    required this.skipImportingBooks,
  });

  final Function() restoreBackup;
  final Function() importOpenreadsCsv;
  final Function() importGoodreadsCsv;
  final Function() importBookwyrmCsv;
  final Function() skipImportingBooks;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        LocaleKeys.help_to_get_started.tr(),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        WelcomeChoiceButton(
                          description: LocaleKeys.restore_backup.tr(),
                          onPressed: restoreBackup,
                        ),
                        WelcomeChoiceButton(
                          description: LocaleKeys.import_csv.tr(),
                          onPressed: importOpenreadsCsv,
                        ),
                        WelcomeChoiceButton(
                          description: LocaleKeys.import_goodreads_csv.tr(),
                          onPressed: importGoodreadsCsv,
                        ),
                        WelcomeChoiceButton(
                          description: LocaleKeys.import_bookwyrm_csv.tr(),
                          onPressed: importBookwyrmCsv,
                        ),
                      ],
                    ),
                  ),
                ),
                WelcomeChoiceButton(
                  description: LocaleKeys.start_adding_books.tr(),
                  onPressed: skipImportingBooks,
                  isSkipImporting: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
