import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants/enums/sort_type.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_event.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_state.dart';

class SortUnfinishedBooksBloc extends HydratedBloc<SortEvent, SortState> {
  SortUnfinishedBooksBloc()
      : super(
          const SortState(
            sortType: SortType.byDateModified,
            isAsc: false,
            onlyFavourite: false,
            years: null,
            tags: null,
            displayTags: false,
            filterTagsAsAnd: false,
            bookType: null,
          ),
        ) {
    on<ChangeSortTypeEvent>(
      (event, emit) => emit(state.copyWith(sortType: event.sortType)),
    );

    on<ToggleOrderEvent>(
      (event, emit) => emit(state.copyWith(isAsc: !state.isAsc)),
    );

    on<ChangeOnlyFavouriteEvent>(
      (event, emit) => emit(state.copyWith(onlyFavourite: event.onlyFavourite)),
    );

    on<ChangeBookTypeEvent>(
        (event, emit) => emit(state.copyWith(bookType: event.bookType)));

    on<ChangeYearsEvent>(
      (event, emit) => emit(state.copyWith(years: event.years)),
    );

    on<ChangeTagsEvent>(
      (event, emit) => emit(state.copyWith(tags: event.tags)),
    );

    on<ChangeFilterTagsAsAnd>(
      (event, emit) => emit(
        state.copyWith(
          filterTagsAsAnd: event.filterTagsAsAnd,
          filterOutTags: false,
        ),
      ),
    );

    on<ChangeFilterOutTags>(
      (event, emit) => emit(
        state.copyWith(
          filterOutTags: event.filterOutTags,
          filterTagsAsAnd: false,
        ),
      ),
    );

    on<ChangeDisplayTagsEvent>(
      (event, emit) => emit(state.copyWith(displayTags: event.displayTags)),
    );
  }

  @override
  SortState? fromJson(Map<String, dynamic> json) => SortState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(SortState state) => state.toJson();
}
