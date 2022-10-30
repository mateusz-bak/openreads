import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants.dart/enums.dart';

part 'sort_state.dart';

class SortCubit extends Cubit<SortState> {
  SortCubit() : super(SortState(sortType: SortType.byTitle, isAsc: true)) {
    updateSortMode(
      sortType: null,
    );
  }

  void updateSortMode({SortType? sortType}) {
    emit(state.copyWith(sortType: sortType));
  }

  void updateSortOrder(bool isAsc) {
    emit(state.copyWith(isAsc: isAsc));
  }
}
