part of 'sort_bloc.dart';

abstract class SortState extends Equatable {
  const SortState();
}

class SetSortState extends SortState {
  final SortType sortType;
  final bool isAsc;
  final bool onlyFavourite;
  final String? years; // Not a list because of equality issues

  const SetSortState({
    required this.sortType,
    required this.isAsc,
    required this.onlyFavourite,
    required this.years,
  });

  @override
  List<Object?> get props => [
        isAsc,
        onlyFavourite,
        sortType,
        years,
      ];
}
