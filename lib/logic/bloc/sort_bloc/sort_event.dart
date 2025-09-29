import 'package:equatable/equatable.dart';
import 'package:openreads/core/constants/enums/book_format.dart';
import 'package:openreads/core/constants/enums/sort_type.dart';

abstract class SortEvent extends Equatable {
  const SortEvent();
}

class ChangeSortTypeEvent extends SortEvent {
  final SortType sortType;

  const ChangeSortTypeEvent(this.sortType);

  @override
  List<Object?> get props => [sortType];
}

class ToggleOrderEvent extends SortEvent {
  const ToggleOrderEvent();

  @override
  List<Object?> get props => [];
}

class ChangeOnlyFavouriteEvent extends SortEvent {
  final bool onlyFavourite;

  const ChangeOnlyFavouriteEvent(this.onlyFavourite);

  @override
  List<Object?> get props => [];
}

class ChangeBookTypeEvent extends SortEvent {
  final BookFormat? bookType;

  const ChangeBookTypeEvent(this.bookType);

  @override
  List<Object?> get props => [bookType];
}

class ChangeYearsEvent extends SortEvent {
  final String? years;

  const ChangeYearsEvent(this.years);

  @override
  List<Object?> get props => [years];
}

class ChangeTagsEvent extends SortEvent {
  final String? tags;

  const ChangeTagsEvent(this.tags);

  @override
  List<Object?> get props => [tags];
}

class ChangeFilterTagsAsAnd extends SortEvent {
  final bool filterTagsAsAnd;

  const ChangeFilterTagsAsAnd(this.filterTagsAsAnd);

  @override
  List<Object?> get props => [filterTagsAsAnd];
}

class ChangeFilterOutTags extends SortEvent {
  final bool filterOutTags;

  const ChangeFilterOutTags(this.filterOutTags);

  @override
  List<Object?> get props => [filterOutTags];
}

class ChangeDisplayTagsEvent extends SortEvent {
  final bool displayTags;

  const ChangeDisplayTagsEvent(this.displayTags);

  @override
  List<Object?> get props => [displayTags];
}
