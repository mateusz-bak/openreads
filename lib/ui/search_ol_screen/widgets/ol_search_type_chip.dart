import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class OLSearchTypeChip extends StatelessWidget {
  const OLSearchTypeChip({
    super.key,
    required this.searchType,
    required this.activeSearchType,
    required this.onSelected,
  });

  final OLSearchType searchType;
  final OLSearchType activeSearchType;
  final Function(OLSearchType) onSelected;

  String _getLabel() {
    switch (searchType) {
      case OLSearchType.general:
        return LocaleKeys.general_search.tr();
      case OLSearchType.author:
        return LocaleKeys.author.tr();
      case OLSearchType.title:
        return LocaleKeys.title.tr();
      case OLSearchType.isbn:
        return LocaleKeys.isbn.tr();
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSelected = searchType == activeSearchType;

    return FilterChip(
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      selected: isSelected,
      label: Text(
        _getLabel(),
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : null,
        ),
      ),
      showCheckmark: false,
      onSelected: (_) => onSelected(searchType),
    );
  }
}
