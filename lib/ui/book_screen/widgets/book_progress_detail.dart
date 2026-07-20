import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class BookProgressDetail extends StatelessWidget {
  const BookProgressDetail({
    super.key,
    required this.currentPage,
    required this.pages,
    required this.onTap,
  });

  final int? currentPage;
  final int? pages;
  final VoidCallback onTap;

  // Without a total page count there is nothing to be a fraction of, so the
  // bar and the percentage are both skipped.
  bool get _hasTotal => pages != null && pages! > 0;

  double? get _fraction {
    if (!_hasTotal || currentPage == null) return null;

    return (currentPage! / pages!).clamp(0.0, 1.0);
  }

  String _buildText() {
    if (currentPage == null) return LocaleKeys.not_started.tr();

    if (!_hasTotal) return '$currentPage';

    final percent = (_fraction! * 100).round();
    return '$currentPage / $pages  ·  $percent%';
  }

  @override
  Widget build(BuildContext context) {
    final fraction = _fraction;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 0, 25, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.progress_uppercase.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _buildText(),
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            if (fraction != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 8,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
