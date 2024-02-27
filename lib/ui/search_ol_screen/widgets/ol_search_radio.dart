import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class OLSearchRadio extends StatelessWidget {
  const OLSearchRadio({
    super.key,
    required this.searchType,
    required this.activeSearchType,
    required this.onChanged,
  });

  final OLSearchType searchType;
  final OLSearchType activeSearchType;
  final Function(OLSearchType?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<OLSearchType>(
          value: searchType,
          groupValue: activeSearchType,
          visualDensity: VisualDensity.compact,
          onChanged: onChanged,
        ),
        Text(
          searchType == OLSearchType.general
              ? LocaleKeys.general_search.tr()
              : searchType == OLSearchType.author
                  ? LocaleKeys.author.tr()
                  : searchType == OLSearchType.title
                      ? LocaleKeys.title.tr()
                      : searchType == OLSearchType.isbn
                          ? LocaleKeys.isbn.tr()
                          : '',
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
