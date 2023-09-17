import 'package:openreads/database/database_controler.dart';
import 'package:openreads/model/book.dart';

import '../core/constants.dart/enums.dart';

class Repository {
  final DatabaseController dbController = DatabaseController();

  Future getAllNotDeletedBooks() => dbController.getAllNotDeletedBooks();

  Future getAllBooks() => dbController.getAllBooks();

  Future<List<Book>> getBooks(int status) => dbController.getBooks(
        status: status,
      );

  Future<List<Book>> searchBooks(String query) => dbController.searchBooks(
        query: query,
      );

  Future<int> countBooks(int status) => dbController.countBooks(status: status);

  Future<int> insertBook(Book book) => dbController.createBook(book);

  Future updateBook(Book book) => dbController.updateBook(book);

  Future updateBookType(Set<int> ids, BookType bookType) =>
      dbController.updateBookType(ids, bookType);

  Future deleteBook(int index) => dbController.deleteBook(index);

  Future getBook(int index) => dbController.getBook(index);

  Future<List<Book>> getDeletedBooks() => dbController.getDeletedBooks();

  Future<int> removeAllBooks() => dbController.removeAllBooks();
}
