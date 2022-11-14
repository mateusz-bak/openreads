import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';

part 'sort_state.dart';
part 'sort_event.dart';

class SortBloc extends HydratedBloc<SortEvent, SortState> {
  SortBloc()
      : super(const SetSortState(
          sortType: SortType.byTitle,
          isAsc: true,
          onlyFavourite: false,
        )) {
    on<ChangeSortEvent>((event, emit) {
      emit(SetSortState(
        sortType: event.sortType,
        isAsc: event.isAsc,
        onlyFavourite: event.onlyFavourite,
      ));
    });
  }

  @override
  SortState? fromJson(Map<String, dynamic> json) {
    final sortTypeInt = json['sort_type'] as int;
    final isAsc = json['sort_order'] as bool;
    final onlyFavourite = json['only_favourite'] as bool;

    late SortType sortType;

    switch (sortTypeInt) {
      case 0:
        sortType = SortType.byTitle;
        break;
      case 1:
        sortType = SortType.byAuthor;
        break;
      case 2:
        sortType = SortType.byRating;
        break;
      case 3:
        sortType = SortType.byPages;
        break;
      case 4:
        sortType = SortType.byStartDate;
        break;
      case 5:
        sortType = SortType.byFinishDate;
        break;
      default:
        sortType = SortType.byTitle;
    }

    return SetSortState(
      sortType: sortType,
      isAsc: isAsc,
      onlyFavourite: onlyFavourite,
    );
  }

  @override
  Map<String, dynamic>? toJson(SortState state) {
    if (state is SetSortState) {
      late int sortTypeInt;
      switch (state.sortType) {
        case SortType.byTitle:
          sortTypeInt = 0;
          break;
        case SortType.byAuthor:
          sortTypeInt = 1;
          break;
        case SortType.byRating:
          sortTypeInt = 2;
          break;
        case SortType.byPages:
          sortTypeInt = 3;
          break;
        case SortType.byStartDate:
          sortTypeInt = 4;
          break;
        case SortType.byFinishDate:
          sortTypeInt = 5;
          break;
        default:
          sortTypeInt = 0;
      }

      return {
        'sort_type': sortTypeInt,
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
