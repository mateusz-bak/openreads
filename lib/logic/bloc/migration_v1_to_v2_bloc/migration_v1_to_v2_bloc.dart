import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_from_backup_v3.dart';
import 'package:openreads/model/year_from_backup_v3.dart';
import 'package:openreads/model/yearly_challenge.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash_dart/blurhash_dart.dart' as blurhash_dart;

part 'migration_v1_to_v2_event.dart';
part 'migration_v1_to_v2_state.dart';

class MigrationV1ToV2Bloc
    extends Bloc<MigrationV1ToV2Event, MigrationV1ToV2State> {
  MigrationV1ToV2Bloc() : super(MigrationNotStarted()) {
    on<StartMigration>((event, emit) async {
      emit(MigrationTriggered());

      final v1BooksDbPath = await _checkIfV1DatabaseExists('BooksDB.db');
      final v1YearsDbPath = await _checkIfV1DatabaseExists('YearDB.db');

      if (!event.retrigger && await _checkIfNewDBIsPresent()) {
        emit(MigrationSkipped());
        return;
      }

      if (v1BooksDbPath == null) {
        if (event.retrigger) {
          // ignore: use_build_context_synchronously
          _showSnackbar(event.context, 'Migration error 1');
        }

        emit(MigrationSkipped());
        return;
      }

      emit(const MigrationOnging());

      await _migrateBooksFromV1ToV2(v1BooksDbPath);

      if (v1YearsDbPath != null) {
        // ignore: use_build_context_synchronously
        await _migrateYearsFromV1ToV2(event.context, v1YearsDbPath);
      } else {
        if (event.retrigger) {
          // ignore: use_build_context_synchronously
          _showSnackbar(event.context, 'Migration error 3');
        }
      }

      emit(MigrationSucceded());

      await Future.delayed(const Duration(seconds: 5));
    });
  }

  _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
        ),
      ),
    );
  }

  Future<bool> _checkIfNewDBIsPresent() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();
    final filePathToBeChecked = path.join(docDirectory.path, 'Books.db');
    final files = await docDirectory.list().toList();

    for (var file in files) {
      if (file.path == filePathToBeChecked) {
        return true;
      }
    }

    return false;
  }

  Future<String?> _checkIfV1DatabaseExists(String dbName) async {
    Directory docDirectory = await getApplicationDocumentsDirectory();
    String dbDirectoryPath = path.join(docDirectory.parent.path, 'databases');

    Directory dbDirectory = Directory(dbDirectoryPath);
    if (!dbDirectory.existsSync()) return null;

    final files = await dbDirectory.list().toList();

    final filePathToBeChecked = path.join(dbDirectory.path, dbName);

    for (var file in files) {
      if (file.path == filePathToBeChecked) {
        return file.path;
      }
    }

    return null;
  }

  Future<void> _migrateBooksFromV1ToV2(String dbPath) async {
    final booksDB = await openDatabase(dbPath);
    final result = await booksDB.query("Book");

    final List<BookFromBackupV3> books = result.isNotEmpty
        ? result.map((item) => BookFromBackupV3.fromJson(item)).toList()
        : [];

    final totalBooksToMigrate = books.length;
    var booksMigrated = 0;

    // ignore: invalid_use_of_visible_for_testing_member
    emit(MigrationOnging(total: totalBooksToMigrate, done: booksMigrated));

    for (var book in books) {
      await _addBookFromBackupV3(
        book,
        totalBooksToMigrate,
        booksMigrated,
      );
      booksMigrated += 1;

      // ignore: invalid_use_of_visible_for_testing_member
      emit(MigrationOnging(total: totalBooksToMigrate, done: booksMigrated));
    }

    bookCubit.getAllBooksByStatus();
    bookCubit.getAllBooks();
  }

  Future<void> _addBookFromBackupV3(
    BookFromBackupV3 book,
    int total,
    int done,
  ) async {
    final blurHash = await compute(_generateBlurHash, book.bookCoverImg);
    final newBook = Book.fromBookFromBackupV3(book, blurHash);

    bookCubit.addBook(newBook, refreshBooks: false);
  }

  static String? _generateBlurHash(Uint8List? cover) {
    if (cover == null) return null;

    return blurhash_dart.BlurHash.encode(
      img.decodeImage(cover)!,
      numCompX: Constants.blurHashX,
      numCompY: Constants.blurHashY,
    ).hash;
  }

  Future<void> _migrateYearsFromV1ToV2(
    BuildContext context,
    String dbPath,
  ) async {
    final booksDB = await openDatabase(dbPath);
    final result = await booksDB.query("Year");

    final List<YearFromBackupV3>? years = result.isNotEmpty
        ? result.map((item) => YearFromBackupV3.fromJson(item)).toList()
        : null;

    String newChallenges = '';

    if (years == null) return;

    for (var year in years) {
      if (newChallenges.isEmpty) {
        if (year.year != null) {
          final newJson = json
              .encode(YearlyChallenge(
                year: int.parse(year.year!),
                books: year.yearChallengeBooks,
                pages: year.yearChallengePages,
              ).toJSON())
              .toString();

          newChallenges = [
            newJson,
          ].join('|||||');
        }
      } else {
        final splittedNewChallenges = newChallenges.split('|||||');

        final newJson = json
            .encode(YearlyChallenge(
              year: int.parse(year.year!),
              books: year.yearChallengeBooks,
              pages: year.yearChallengePages,
            ).toJSON())
            .toString();

        splittedNewChallenges.add(newJson);

        newChallenges = splittedNewChallenges.join('|||||');
      }
    }

    // ignore: use_build_context_synchronously
    BlocProvider.of<ChallengeBloc>(context).add(
      RestoreChallengesEvent(
        challenges: newChallenges,
      ),
    );
  }
}
