import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/database/database_provider.dart';
import 'package:openreads/model/book.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseController {
  final dbClient = DatabaseProvider.dbProvider;

  Future<int> createBook(Book book) async {
    final db = await dbClient.db;

    return db.insert("booksTable", book.toJSON());
  }

  Future<List<Book>> getAllNotDeletedBooks({List<String>? columns}) async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      columns: columns,
      where: 'deleted = 0',
    );

    return result.isNotEmpty
        ? result.map((item) => Book.fromJSON(item)).toList()
        : [];
  }

  Future<List<Book>> getAllBooks({List<String>? columns}) async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      columns: columns,
    );

    return result.isNotEmpty
        ? result.map((item) => Book.fromJSON(item)).toList()
        : [];
  }

  Future<List<Book>> getBooks({
    List<String>? columns,
    required int status,
  }) async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      columns: columns,
      where: 'status = ? AND deleted = 0',
      whereArgs: [status],
    );

    return result.isNotEmpty
        ? result.map((item) => Book.fromJSON(item)).toList()
        : [];
  }

  Future<List<Book>> searchBooks({
    List<String>? columns,
    required String query,
  }) async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      columns: columns,
      where:
          "(title LIKE ? OR subtitle LIKE ? OR author LIKE ?) AND deleted LIKE ?",
      whereArgs: [
        '%$query%',
        '%$query%',
        '%$query%',
        '0',
      ],
    );

    return result.isNotEmpty
        ? result.map((item) => Book.fromJSON(item)).toList()
        : [];
  }

  Future<int> countBooks({
    List<String>? columns,
    required int status,
  }) async {
    final db = await dbClient.db;

    final count = Sqflite.firstIntValue(await db.rawQuery(
      'SELECT COUNT(*) FROM booksTable WHERE status = $status AND deleted = 0',
    ));

    return count ?? 0;
  }

  Future<int> updateBook(Book book) async {
    final db = await dbClient.db;

    return await db.update("booksTable", book.toJSON(),
        where: "id = ?", whereArgs: [book.id]);
  }

  Future<int> deleteBook(int id) async {
    final db = await dbClient.db;

    return await db.delete("booksTable", where: 'id = ?', whereArgs: [id]);
  }

  Future<Book?> getBook(int id) async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    return result.isNotEmpty
        ? result.map((item) => Book.fromJSON(item)).toList()[0]
        : null;
  }

  Future<List<Book>> getDeletedBooks() async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      where: 'deleted = 1',
    );

    return result.isNotEmpty
        ? result.map((item) => Book.fromJSON(item)).toList()
        : [];
  }

  Future<int> removeAllBooks() async {
    final db = await dbClient.db;
    return await db.delete("booksTable");
  }

  Future<List<Object?>> bulkUpdateBookFormat(
    Set<int> ids,
    BookFormat bookFormat,
  ) async {
    final db = await dbClient.db;
    var batch = db.batch();

    String bookFormatString = bookFormat == BookFormat.audiobook
        ? 'audiobook'
        : bookFormat == BookFormat.ebook
            ? 'ebook'
            : bookFormat == BookFormat.paperback
                ? 'paperback'
                : bookFormat == BookFormat.hardcover
                    ? 'hardcover'
                    : 'paperback';

    for (int id in ids) {
      batch.update("booksTable", {"book_type": bookFormatString},
          where: "id = ?", whereArgs: [id]);
    }
    return await batch.commit();
  }

  Future<List<Object?>> bulkUpdateBookAuthor(
    Set<int> ids,
    String author,
  ) async {
    final db = await dbClient.db;
    var batch = db.batch();

    for (int id in ids) {
      batch.update("booksTable", {"author": author},
          where: "id = ?", whereArgs: [id]);
    }
    return await batch.commit();
  }

  Future<List<Book>> getBooksWithSameTag(String tag) async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      where: 'tags IS NOT NULL AND deleted = 0',
      orderBy: 'publication_year ASC',
    );

    final booksWithTag = List<Book>.empty(growable: true);

    if (result.isNotEmpty) {
      final books = result.map((item) => Book.fromJSON(item)).toList();
      for (final book in books) {
        if (book.tags != null && book.tags!.isNotEmpty) {
          for (final bookTag in book.tags!.split('|||||')) {
            if (bookTag == tag) {
              booksWithTag.add(book);
            }
          }
        }
      }
    }

    return booksWithTag;
  }

  Future<List<Book>> getBooksWithSameAuthor(String author) async {
    final db = await dbClient.db;

    var result = await db.query(
      "booksTable",
      where: 'author = ? AND deleted = 0',
      whereArgs: [author],
      orderBy: 'publication_year ASC',
    );

    return result.isNotEmpty
        ? result.map((item) => Book.fromJSON(item)).toList()
        : [];
  }
}
