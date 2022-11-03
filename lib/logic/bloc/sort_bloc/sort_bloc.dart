import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';

part 'sort_state.dart';
part 'sort_event.dart';

class SortBloc extends HydratedBloc<SortEvent, SortState> {
  SortBloc() : super(TitleAscSortState()) {
    on<ChangeSortEvent>((event, emit) {
      switch (event.sortType) {
        case SortType.byTitle:
          event.isAsc ? emit(TitleAscSortState()) : emit(TitleDescSortState());
          break;
        case SortType.byAuthor:
          event.isAsc
              ? emit(AuthorAscSortState())
              : emit(AuthorDescSortState());
          break;
        case SortType.byRating:
          event.isAsc
              ? emit(RatingAscSortState())
              : emit(RatingDescSortState());
          break;
        case SortType.byPages:
          event.isAsc ? emit(PagesAscSortState()) : emit(PagesDescSortState());
          break;
        case SortType.byStartDate:
          event.isAsc
              ? emit(StartDateAscSortState())
              : emit(StartDateDescSortState());
          break;
        case SortType.byFinishDate:
          event.isAsc
              ? emit(FinishDateAscSortState())
              : emit(FinishDateDescSortState());
          break;
      }
    });
  }

  @override
  SortState? fromJson(Map<String, dynamic> json) {
    final sortType = json['SortType'] as int;
    final order = json['SortOrder'] as bool;

    switch (sortType) {
      case 1:
        return order ? AuthorAscSortState() : AuthorDescSortState();
      case 2:
        return order ? RatingAscSortState() : RatingDescSortState();
      case 3:
        return order ? PagesAscSortState() : PagesDescSortState();
      case 4:
        return order ? StartDateAscSortState() : StartDateDescSortState();
      case 5:
        return order ? FinishDateAscSortState() : FinishDateDescSortState();
      default:
        return order ? TitleAscSortState() : TitleDescSortState();
    }
  }

  @override
  Map<String, dynamic>? toJson(SortState state) {
    if (state is AuthorAscSortState) {
      return {
        'SortType': 1,
        'SortOrder': true,
      };
    } else if (state is AuthorDescSortState) {
      return {
        'SortType': 1,
        'SortOrder': false,
      };
    } else if (state is RatingAscSortState) {
      return {
        'SortType': 2,
        'SortOrder': true,
      };
    } else if (state is RatingDescSortState) {
      return {
        'SortType': 2,
        'SortOrder': false,
      };
    } else if (state is PagesAscSortState) {
      return {
        'SortType': 3,
        'SortOrder': true,
      };
    } else if (state is PagesDescSortState) {
      return {
        'SortType': 3,
        'SortOrder': false,
      };
    } else if (state is StartDateAscSortState) {
      return {
        'SortType': 4,
        'SortOrder': true,
      };
    } else if (state is StartDateDescSortState) {
      return {
        'SortType': 4,
        'SortOrder': false,
      };
    } else if (state is FinishDateAscSortState) {
      return {
        'SortType': 5,
        'SortOrder': true,
      };
    } else if (state is FinishDateDescSortState) {
      return {
        'SortType': 5,
        'SortOrder': false,
      };
    } else if (state is TitleDescSortState) {
      return {
        'SortType': 0,
        'SortOrder': false,
      };
    } else {
      return {
        'SortType': 0,
        'SortOrder': true,
      };
    }
  }
}
