import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  late final Future<Database> db = createDatabase();

  Future<Database> createDatabase() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();

    String path = join(
      docDirectory.path,
      "Books.db",
    );

    return await openDatabase(
      path,
      version: 3,
      onCreate: (Database db, int version) async {
        await db.execute("CREATE TABLE booksTable ("
            "id INTEGER PRIMARY KEY AUTOINCREMENT, "
            "title TEXT, "
            "subtitle TEXT, "
            "author TEXT, "
            "description TEXT, "
            "book_type TEXT, "
            "status INTEGER, "
            "rating INTEGER, "
            "favourite INTEGER, "
            "deleted INTEGER, "
            "start_date TEXT, "
            "finish_date TEXT, "
            "pages INTEGER, "
            "publication_year INTEGER, "
            "isbn TEXT, "
            "olid TEXT, "
            "tags TEXT, "
            "my_review TEXT, "
            "cover BLOB, "
            "blur_hash TEXT "
            ")");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (newVersion > oldVersion) {
          var batch = db.batch();

          switch (oldVersion) {
            case 1:
              _updateBookDatabaseV1toV3(batch);
              break;
            case 2:
              _updateBookDatabaseV2toV3(batch);
              break;
          }
        }
      },
    );
  }

  void _updateBookDatabaseV1toV3(Batch batch) {
    batch.execute("ALTER TABLE booksTable ADD description TEXT");
    batch.execute("ALTER TABLE booksTable ADD book_type TEXT DEFAULT paper");
  }

  void _updateBookDatabaseV2toV3(Batch batch) {
    batch.execute("ALTER TABLE booksTable ADD book_type TEXT");
  }
}
