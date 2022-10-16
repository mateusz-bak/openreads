import 'package:openreads/database/database.dart';
import 'package:openreads/model/book.dart';

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

  Future<int> updateBook(Book book) async {
    final db = await dbClient.db;

    return await db.update("booksTable", book.toJSON(),
        where: "id = ?", whereArgs: [book.id]);
  }

  Future<int> deleteBook(int id) async {
    final db = await dbClient.db;

    return await db.delete("booksTable", where: 'id = ?', whereArgs: [id]);
  }
}
