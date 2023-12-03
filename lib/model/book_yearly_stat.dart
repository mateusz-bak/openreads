import 'package:openreads/model/book.dart';

class BookYearlyStat {
  Book? book;
  int? year;
  String value;
  String? title;

  BookYearlyStat({
    this.book,
    this.year,
    this.title,
    required this.value,
  });
}
