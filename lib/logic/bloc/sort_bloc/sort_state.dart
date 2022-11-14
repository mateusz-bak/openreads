part of 'sort_bloc.dart';

abstract class SortState extends Equatable {
  const SortState();
}

class SetSortState extends SortState {
  final SortType sortType;
  final bool isAsc;
  final bool onlyFavourite;

  const SetSortState({
    required this.sortType,
    required this.isAsc,
    required this.onlyFavourite,
  });

  @override
  List<Object?> get props => [
        isAsc,
        onlyFavourite,
        sortType,
      ];
}
