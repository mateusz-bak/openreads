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
      version: 4,
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
            "has_cover INTEGER, "
            "cover BLOB, "
            "blur_hash TEXT "
            ")");
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        if (newVersion > oldVersion) {
          var batch = db.batch();

          switch (oldVersion) {
            case 1:
              _updateBookDatabaseV1toV4(batch);
              break;
            case 2:
              _updateBookDatabaseV2toV4(batch);
              break;
            case 3:
              _updateBookDatabaseV3toV4(batch);
              break;
          }

          await batch.commit();
        }
      },
    );
  }

  void _updateBookDatabaseV1toV4(Batch batch) {
    batch.execute("ALTER TABLE booksTable ADD description TEXT");
    batch.execute("ALTER TABLE booksTable ADD book_type TEXT DEFAULT paper");
    batch.execute("ALTER TABLE booksTable ADD has_cover INTEGER DEFAULT 0");
  }

  void _updateBookDatabaseV2toV4(Batch batch) {
    batch.execute("ALTER TABLE booksTable ADD book_type TEXT");
    batch.execute("ALTER TABLE booksTable ADD has_cover INTEGER DEFAULT 0");
  }

  void _updateBookDatabaseV3toV4(Batch batch) {
    batch.execute("ALTER TABLE booksTable ADD has_cover INTEGER DEFAULT 0");
  }
}
