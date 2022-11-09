part of 'sort_bloc.dart';

abstract class SortState extends Equatable {
  const SortState();
}

class TitleSortState extends SortState {
  final bool isAsc;
  final bool onlyFavourite;

  const TitleSortState(this.isAsc, this.onlyFavourite);
  @override
  List<Object?> get props => [isAsc, onlyFavourite];
}

class AuthorSortState extends SortState {
  final bool isAsc;
  final bool onlyFavourite;

  const AuthorSortState(this.isAsc, this.onlyFavourite);
  @override
  List<Object?> get props => [isAsc, onlyFavourite];
}

class RatingSortState extends SortState {
  final bool isAsc;
  final bool onlyFavourite;

  const RatingSortState(this.isAsc, this.onlyFavourite);
  @override
  List<Object?> get props => [isAsc, onlyFavourite];
}

class PagesSortState extends SortState {
  final bool isAsc;
  final bool onlyFavourite;

  const PagesSortState(this.isAsc, this.onlyFavourite);
  @override
  List<Object?> get props => [isAsc, onlyFavourite];
}

class StartDateSortState extends SortState {
  final bool isAsc;
  final bool onlyFavourite;

  const StartDateSortState(this.isAsc, this.onlyFavourite);
  @override
  List<Object?> get props => [isAsc, onlyFavourite];
}

class FinishDateSortState extends SortState {
  final bool isAsc;
  final bool onlyFavourite;

  const FinishDateSortState(this.isAsc, this.onlyFavourite);
  @override
  List<Object?> get props => [isAsc, onlyFavourite];
}
