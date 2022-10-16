import 'package:openreads/database/database_controler.dart';
import 'package:openreads/model/book.dart';

class Repository {
  final DatabaseController dbController = DatabaseController();

  Future getAllBooks() => dbController.getAllBooks();

  Future insertBook(Book todo) => dbController.createBook(todo);

  Future updateBook(Book todo) => dbController.updateBook(todo);

  Future deleteBook(int index) => dbController.deleteBook(index);
}
