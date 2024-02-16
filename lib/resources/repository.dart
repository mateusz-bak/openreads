import 'package:openreads/database/database_controler.dart';
import 'package:openreads/model/book.dart';

import 'package:openreads/core/constants/enums/enums.dart';

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

  Future bulkUpdateBookFormat(Set<int> ids, BookFormat bookFormat) =>
      dbController.bulkUpdateBookFormat(ids, bookFormat);

  Future bulkUpdateBookAuthor(Set<int> ids, String author) =>
      dbController.bulkUpdateBookAuthor(ids, author);

  Future deleteBook(int index) => dbController.deleteBook(index);

  Future<Book?> getBook(int index) => dbController.getBook(index);

  Future<List<Book>> getDeletedBooks() => dbController.getDeletedBooks();

  Future<int> removeAllBooks() => dbController.removeAllBooks();

  Future<List<Book>> getBooksWithSameTag(String tag) =>
      dbController.getBooksWithSameTag(tag);

  Future<List<Book>> getBooksWithSameAuthor(String author) =>
      dbController.getBooksWithSameAuthor(author);
}
