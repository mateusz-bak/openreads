import 'package:flutter_bloc/flutter_bloc.dart';

class BooksTabIndexCubit extends Cubit<int> {
  BooksTabIndexCubit() : super(0);

  void setTabIndex(int index) => emit(index);
}
