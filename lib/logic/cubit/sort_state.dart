part of 'sort_cubit.dart';

class SortState {
  final SortType sortType;
  final bool ascending;

  SortState({
    required this.sortType,
    required this.ascending,
  });

  SortState copyWith({
    SortType? sortType,
    bool? ascending,
  }) {
    return SortState(
      sortType: sortType ?? this.sortType,
      ascending: ascending ?? this.ascending,
    );
  }
}
