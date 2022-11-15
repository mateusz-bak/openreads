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
  });

  final SortType sortType;
  final bool isAsc;
  final bool onlyFavourite;
  final String? years;
  final String? tags;
  final bool displayTags;

  @override
  List<Object?> get props => [
        sortType,
        isAsc,
        onlyFavourite,
        years,
        tags,
        displayTags,
      ];
}
