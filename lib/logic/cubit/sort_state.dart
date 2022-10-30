part of 'sort_cubit.dart';

class SortState {
  final SortType sortType;
  final bool isAsc;

  SortState({
    required this.sortType,
    required this.isAsc,
  });

  SortState copyWith({
    SortType? sortType,
    bool? isAsc,
  }) {
    return SortState(
      sortType: sortType ?? this.sortType,
      isAsc: isAsc ?? this.isAsc,
    );
  }
}
