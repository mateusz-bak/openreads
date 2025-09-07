import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';

class BookListsOrderCubit extends HydratedCubit<List<BookStatus>> {
  BookListsOrderCubit()
      : super([
          BookStatus.read,
          BookStatus.inProgress,
          BookStatus.forLater,
          BookStatus.unfinished,
        ]);

  updateOrder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final item = state.removeAt(oldIndex);
    state.insert(newIndex, item);

    emit(List<BookStatus>.from(state));
  }

  @override
  List<BookStatus> fromJson(Map<String, dynamic> json) {
    final List<dynamic> list = json['book_lists_order'];

    return list.map((e) => BookStatus.values.byName(e)).toList();
  }

  @override
  Map<String, dynamic>? toJson(List<BookStatus> state) {
    return {
      'book_lists_order': state.map((e) => e.name).toList(),
    };
  }
}
