part of 'sort_bloc.dart';

abstract class SortEvent extends Equatable {
  const SortEvent();
}

class ChangeSortEvent extends SortEvent {
  const ChangeSortEvent({
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

  final SortType sortType;
  final bool isAsc;
  final bool onlyFavourite;
  final String? years;
  final String? tags;
  final bool displayTags;
  final bool filterTagsAsAnd;
  final BookFormat? bookType;
  final bool filterOutTags;

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
