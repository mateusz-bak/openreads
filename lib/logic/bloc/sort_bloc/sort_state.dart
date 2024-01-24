part of 'sort_bloc.dart';

abstract class SortState extends Equatable {
  const SortState();
}

class SetSortState extends SortState {
  final SortType sortType;
  final bool isAsc;
  final bool onlyFavourite;
  final String? years;
  final String? tags;
  final bool displayTags;
  final bool filterTagsAsAnd;
  final BookFormat? bookType;
  final bool filterOutTags;

  const SetSortState({
    required this.sortType,
    required this.isAsc,
    required this.onlyFavourite,
    required this.years,
    required this.tags,
    required this.displayTags,
    required this.filterTagsAsAnd,
    required this.bookType,
    this.filterOutTags = false,
  });

  @override
  List<Object?> get props => [
        isAsc,
        onlyFavourite,
        sortType,
        years,
        tags,
        displayTags,
        filterTagsAsAnd,
        bookType,
        filterOutTags,
      ];
}
