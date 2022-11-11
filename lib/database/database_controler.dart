import 'package:openreads/database/database_provider.dart';
import 'package:openreads/model/book.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseController {
  final dbClient = DatabaseProvider.dbProvider;

  Future<int> createBook(Book book) async {
    final db = await dbClient.db;

    return db.insert("booksTable", book.toJSON());
  }

  Future<List<Book>> getAllBooks({List<String>? columns}) async {
    final db = await dbClient.db;

    var result = await db.query("booksTable", columns: columns);

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
      where: 'status = ?',
      whereArgs: [status],
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
      'SELECT COUNT(*) FROM booksTable WHERE status = $status',
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
}
