import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';

part 'sort_state.dart';
part 'sort_event.dart';

class SortBloc extends HydratedBloc<SortEvent, SortState> {
  SortBloc() : super(const TitleSortState(true, false)) {
    on<ChangeSortEvent>((event, emit) {
      switch (event.sortType) {
        case SortType.byTitle:
          emit(TitleSortState(event.isAsc, event.onlyFavourite));
          break;

        case SortType.byAuthor:
          emit(AuthorSortState(event.isAsc, event.onlyFavourite));
          break;

        case SortType.byRating:
          emit(RatingSortState(event.isAsc, event.onlyFavourite));
          break;

        case SortType.byPages:
          emit(PagesSortState(event.isAsc, event.onlyFavourite));
          break;

        case SortType.byStartDate:
          emit(StartDateSortState(event.isAsc, event.onlyFavourite));
          break;

        case SortType.byFinishDate:
          emit(FinishDateSortState(event.isAsc, event.onlyFavourite));
          break;
      }
    });
  }

  @override
  SortState? fromJson(Map<String, dynamic> json) {
    final sortType = json['sort_type'] as int;
    final order = json['sort_order'] as bool;
    final favourite = json['only_favourite'] as bool;

    switch (sortType) {
      case 0:
        return TitleSortState(order, favourite);
      case 1:
        return AuthorSortState(order, favourite);
      case 2:
        return RatingSortState(order, favourite);
      case 3:
        return PagesSortState(order, favourite);
      case 4:
        return StartDateSortState(order, favourite);
      case 5:
        return FinishDateSortState(order, favourite);
      default:
        return TitleSortState(order, favourite);
    }
  }

  @override
  Map<String, dynamic>? toJson(SortState state) {
    if (state is TitleSortState) {
      return {
        'sort_type': 0,
        'sort_order': state.isAsc,
        'only_favourite': state.onlyFavourite,
      };
    } else if (state is AuthorSortState) {
      return {
        'sort_type': 1,
        'sort_order': state.isAsc,
        'only_favourite': state.onlyFavourite,
      };
    } else if (state is RatingSortState) {
      return {
        'sort_type': 2,
        'sort_order': state.isAsc,
        'only_favourite': state.onlyFavourite,
      };
    } else if (state is PagesSortState) {
      return {
        'sort_type': 3,
        'sort_order': state.isAsc,
        'only_favourite': state.onlyFavourite,
      };
    } else if (state is StartDateSortState) {
      return {
        'sort_type': 4,
        'sort_order': state.isAsc,
        'only_favourite': state.onlyFavourite,
      };
    } else if (state is FinishDateSortState) {
      return {
        'sort_type': 5,
        'sort_order': state.isAsc,
        'only_favourite': state.onlyFavourite,
      };
    } else {
      return {
        'sort_type': 0,
        'sort_order': true,
        'only_favourite': false,
      };
    }
  }
}
