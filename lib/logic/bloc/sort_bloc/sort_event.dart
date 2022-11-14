part of 'sort_bloc.dart';

abstract class SortEvent extends Equatable {
  const SortEvent();
}

class ChangeSortEvent extends SortEvent {
  const ChangeSortEvent({
    required this.sortType,
    required this.isAsc,
    required this.onlyFavourite,
  });

  final SortType sortType;
  final bool isAsc;
  final bool onlyFavourite;

  @override
  List<Object?> get props => [
        sortType,
        isAsc,
        onlyFavourite,
      ];
}
