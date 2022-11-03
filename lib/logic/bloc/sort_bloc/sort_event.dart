part of 'sort_bloc.dart';

abstract class SortEvent extends Equatable {
  const SortEvent();
}

class ChangeSortEvent extends SortEvent {
  const ChangeSortEvent(this.sortType, this.isAsc);

  final SortType sortType;
  final bool isAsc;

  @override
  List<Object?> get props => [sortType, isAsc];
}
