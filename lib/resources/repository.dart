import 'package:openreads/database/database_controler.dart';
import 'package:openreads/model/book.dart';

class Repository {
  final DatabaseController dbController = DatabaseController();

  Future getAllNotDeletedBooks() => dbController.getAllNotDeletedBooks();

  Future<List<Book>> getBooks(int status) => dbController.getBooks(
        status: status,
      );

  Future<List<Book>> searchBooks(String query) => dbController.searchBooks(
        query: query,
      );

  Future<int> countBooks(int status) => dbController.countBooks(status: status);

  Future insertBook(Book book) => dbController.createBook(book);

  Future updateBook(Book book) => dbController.updateBook(book);

  Future deleteBook(int index) => dbController.deleteBook(index);

  Future getBook(int index) => dbController.getBook(index);

  Future<List<Book>> getDeletedBooks() => dbController.getDeletedBooks();

  Future<int> removeAllBooks() => dbController.removeAllBooks();
}
