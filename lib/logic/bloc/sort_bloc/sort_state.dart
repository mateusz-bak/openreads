import 'package:equatable/equatable.dart';
import 'package:openreads/core/constants/enums/book_format.dart';
import 'package:openreads/core/constants/enums/sort_type.dart';

class SortState extends Equatable {
  const SortState({
    required this.sortType,
    required this.isAsc,
    required this.onlyFavourite,
    this.years,
    this.tags,
    required this.displayTags,
    required this.filterTagsAsAnd,
    this.bookType,
    this.filterOutTags = false,
  });

  final SortType sortType;
  final bool isAsc;
  final bool onlyFavourite;
  final String? years;
  final String? tags;
  final bool displayTags;
  final bool filterTagsAsAnd;
  final BookFormat? bookType;
  final bool filterOutTags;

  SortState copyWith({
    SortType? sortType,
    bool? isAsc,
    bool? onlyFavourite,
    String? years,
    String? tags,
    bool? displayTags,
    bool? filterTagsAsAnd,
    BookFormat? bookType,
    bool? filterOutTags,
  }) {
    return SortState(
      sortType: sortType ?? this.sortType,
      isAsc: isAsc ?? this.isAsc,
      onlyFavourite: onlyFavourite ?? this.onlyFavourite,
      years: years ?? this.years,
      tags: tags ?? this.tags,
      displayTags: displayTags ?? this.displayTags,
      filterTagsAsAnd: filterTagsAsAnd ?? this.filterTagsAsAnd,
      bookType: bookType ?? this.bookType,
      filterOutTags: filterOutTags ?? this.filterOutTags,
    );
  }

  factory SortState.fromJson(Map<String, dynamic> json) {
    final sortTypeInt = json['sort_type'] as int;
    final isAsc = json['sort_order'] as bool;
    final onlyFavourite = json['only_favourite'] as bool;
    final years = json['years'] as String?;
    final tags = json['tags'] as String?;
    final displayTags = json['display_tags'] as bool;
    final filterTagsAsAnd = json['filter_tags_as_and'] as bool;
    final filterOutTags = json['filter_out_tags'] as bool;
    final bookType = json['filter_book_type'] as String?;

    final sortType = sortTypeInt < SortType.values.length
        ? SortType.values[sortTypeInt]
        : SortType.byDateModified;

    return SortState(
      sortType: sortType,
      isAsc: isAsc,
      onlyFavourite: onlyFavourite,
      years: years,
      tags: tags,
      displayTags: displayTags,
      filterTagsAsAnd: filterTagsAsAnd,
      bookType: bookType == null ? null : BookFormat.values.byName(bookType),
      filterOutTags: filterOutTags,
    );
  }

  Map<String, dynamic>? toJson() {
    return {
      'sort_type': sortType.index,
      'sort_order': isAsc,
      'only_favourite': onlyFavourite,
      'years': years,
      'tags': tags,
      'display_tags': displayTags,
      'filter_tags_as_and': filterTagsAsAnd,
      'filter_book_type': bookType?.name,
      'filter_out_tags': filterOutTags,
    };
  }

  @override
  List<Object?> get props => [
        sortType,
        isAsc,
        onlyFavourite,
        years,
        tags,
        displayTags,
        filterTagsAsAnd,
        bookType,
        filterOutTags,
      ];
}
