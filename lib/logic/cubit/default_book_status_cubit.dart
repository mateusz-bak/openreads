import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';

class DefaultBooksFormatCubit extends HydratedCubit<BookFormat> {
  DefaultBooksFormatCubit() : super(BookFormat.paperback);

  setBookFormat(BookFormat bookFormat) => emit(bookFormat);

  @override
  BookFormat? fromJson(Map<String, dynamic> json) {
    return parseBookFormat(json['default_books_format']);
  }

  @override
  Map<String, dynamic>? toJson(BookFormat state) {
    return {
      'default_books_format': state.value,
    };
  }
}
