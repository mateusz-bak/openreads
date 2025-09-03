import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedBooksCubit extends Cubit<List<int>> {
  SelectedBooksCubit() : super([]);

  void onBookPressed(int bookId) {
    final currentList = List<int>.from(state);

    if (currentList.contains(bookId)) {
      deselectBook(bookId, currentList);
    } else {
      selectBook(bookId, currentList);
    }
  }

  void selectBook(int bookId, List<int> currentList) {
    currentList.add(bookId);
    emit(currentList);
  }

  void deselectBook(int bookId, List<int> currentList) {
    currentList.remove(bookId);
    emit(currentList);
  }

  void resetSelection() {
    emit([]);
  }
}
