import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';

part 'sort_state.dart';

class SortCubit extends Cubit<SortState> {
  SortCubit() : super(SortState(sortType: SortType.byTitle, ascending: true)) {
    updateSortMode(
      sortTypeString: null,
      ascending: true,
    );
  }

  void updateSortMode({String? sortTypeString, bool? ascending}) {
    switch (sortTypeString) {
      case 'Author':
        emit(state.copyWith(sortType: SortType.byAuthor));
        break;
      case 'Rating':
        emit(state.copyWith(sortType: SortType.byRating));
        break;
      case 'Pages':
        emit(state.copyWith(sortType: SortType.byPages));
        break;
      default:
        emit(state.copyWith(sortType: SortType.byTitle));
        break;
    }
  }

  void updateSortOrder(bool ascending) {
    emit(state.copyWith(ascending: ascending));
  }
}
