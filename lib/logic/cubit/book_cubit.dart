import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/resources/repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blurhash_dart/blurhash_dart.dart' as blurhash_dart;
import 'package:image/image.dart' as img;

import 'package:openreads/core/constants/enums/enums.dart';

class BookCubit extends Cubit {
  final Repository repository = Repository();

  final BehaviorSubject<List<Book>> _booksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<List<Book>> _finishedBooksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<List<Book>> _inProgressBooksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<List<Book>> _toReadBooksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<List<Book>> _deletedBooksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<List<Book>> _unfinishedBooksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<List<Book>> _searchBooksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<List<int>> _finishedYearsFetcher =
      BehaviorSubject<List<int>>();
  final BehaviorSubject<List<String>> _tagsFetcher =
      BehaviorSubject<List<String>>();
  final BehaviorSubject<List<String>> _authorsFetcher =
      BehaviorSubject<List<String>>();
  final BehaviorSubject<Book?> _bookFetcher = BehaviorSubject<Book?>();
  final BehaviorSubject<List<Book>?> _booksWithSameTagFetcher =
      BehaviorSubject<List<Book>?>();
  final BehaviorSubject<List<Book>?> _booksWithSameAuthorFetcher =
      BehaviorSubject<List<Book>?>();

  Stream<List<Book>> get allBooks => _booksFetcher.stream;
  Stream<List<Book>> get finishedBooks => _finishedBooksFetcher.stream;
  Stream<List<Book>> get inProgressBooks => _inProgressBooksFetcher.stream;
  Stream<List<Book>> get toReadBooks => _toReadBooksFetcher.stream;
  Stream<List<Book>> get deletedBooks => _deletedBooksFetcher.stream;
  Stream<List<Book>> get unfinishedBooks => _unfinishedBooksFetcher.stream;
  Stream<List<Book>> get searchBooks => _searchBooksFetcher.stream;
  Stream<List<int>> get finishedYears => _finishedYearsFetcher.stream;
  Stream<List<String>> get tags => _tagsFetcher.stream;
  Stream<List<String>> get authors => _authorsFetcher.stream;
  Stream<List<Book>?> get booksWithSameTag => _booksWithSameTagFetcher.stream;
  Stream<List<Book>?> get booksWithSameAuthor =>
      _booksWithSameAuthorFetcher.stream;

  Stream<Book?> get book => _bookFetcher.stream;

  BookCubit() : super(null) {
    _initLoad();
  }

  Future<void> _initLoad() async {
    if (!await _checkIfCoverMigrationDone()) {
      await _migrateCoversFromDatabaseToStorage();
    }

    getFinishedBooks();
    getInProgressBooks();
    getToReadBooks();
    getAllBooks();
  }

  getAllBooks({
    bool getTags = true,
    bool getAuthors = true,
  }) async {
    List<Book> books = await repository.getAllNotDeletedBooks();
    _booksFetcher.sink.add(books);

    if (getTags) {
      _tagsFetcher.sink.add(_getTags(books));
    }

    if (getAuthors) {
      _authorsFetcher.sink.add(_getAuthors(books));
    }
  }

  removeAllBooks() async {
    await repository.removeAllBooks();
  }

  getAllBooksByStatus() async {
    getFinishedBooks();
    getInProgressBooks();
    getToReadBooks();
    getUnfinishedBooks();
  }

  getFinishedBooks() async {
    List<Book> books = await repository.getBooks(0);

    _finishedBooksFetcher.sink.add(books);
    _finishedYearsFetcher.sink.add(_getFinishedYears(books));
  }

  getInProgressBooks() async {
    List<Book> books = await repository.getBooks(1);
    _inProgressBooksFetcher.sink.add(books);
  }

  getToReadBooks() async {
    List<Book> books = await repository.getBooks(2);
    _toReadBooksFetcher.sink.add(books);
  }

  getDeletedBooks() async {
    List<Book> books = await repository.getDeletedBooks();
    _deletedBooksFetcher.sink.add(books);
  }

  getUnfinishedBooks() async {
    List<Book> books = await repository.getBooks(3);
    _unfinishedBooksFetcher.sink.add(books);
  }

  getSearchBooks(String query) async {
    if (query.isEmpty) {
      _searchBooksFetcher.sink.add(List.empty());
    } else {
      List<Book> books = await repository.searchBooks(query);
      _searchBooksFetcher.sink.add(books);
    }
  }

  addBook(Book book, {bool refreshBooks = true, Uint8List? cover}) async {
    final bookID = await repository.insertBook(book);

    await _saveCoverToStorage(bookID, cover);

    if (refreshBooks) {
      getAllBooksByStatus();
      getAllBooks();
    }
  }

  Future<List<int>> importAdditionalBooks(List<Book> books) async {
    final importedBookIDs = List<int>.empty(growable: true);

    for (var book in books) {
      final id = await repository.insertBook(book);
      importedBookIDs.add(id);
    }

    getAllBooksByStatus();
    getAllBooks();

    return importedBookIDs;
  }

  Future _saveCoverToStorage(int? bookID, Uint8List? cover) async {
    if (bookID == null || cover == null) return;

    final file = File('${appDocumentsDirectory.path}/$bookID.jpg');
    await file.writeAsBytes(cover);
  }

  updateBook(Book book, {Uint8List? cover, BuildContext? context}) async {
    repository.updateBook(book);
    await _saveCoverToStorage(book.id!, cover);

    if (context != null) {
      // This looks bad but we need to wait for cover to be saved to storage
      // before updating current book
      context.read<CurrentBookCubit>().setBook(book.copyWith());
    }

    getBook(book.id!);
    getAllBooksByStatus();
    getAllBooks();
  }

  bulkUpdateBookFormat(Set<int> ids, BookFormat bookFormat) async {
    repository.bulkUpdateBookFormat(ids, bookFormat);
    getAllBooksByStatus();
    getAllBooks();
  }

  bulkUpdateBookAuthor(Set<int> ids, String author) async {
    repository.bulkUpdateBookAuthor(ids, author);
    getAllBooksByStatus();
    getAllBooks();
  }

  deleteBook(int id) async {
    repository.deleteBook(id);
    getAllBooksByStatus();
    getAllBooks();
  }

  Future<Book?> getBook(int id) async {
    Book? book = await repository.getBook(id);
    _bookFetcher.sink.add(book);

    return book;
  }

  List<int> _getFinishedYears(List<Book> books) {
    final years = List<int>.empty(growable: true);

    for (var book in books) {
      for (var date in book.readings) {
        if (date.finishDate != null) {
          if (!years.contains(date.finishDate!.year)) {
            //TODO check if years should be duplicated or not
            years.add(date.finishDate!.year);
          }
        }
      }
    }

    years.sort((a, b) => b.compareTo(a));

    return years;
  }

  List<String> _getTags(List<Book> books) {
    final tags = List<String>.empty(growable: true);

    for (var book in books) {
      if (book.tags != null) {
        for (var tag in book.tags!.split('|||||')) {
          if (!tags.contains(tag)) {
            tags.add(tag);
          }
        }
      }
    }

    tags.sort((a, b) => a.compareTo(b));

    return tags;
  }

  List<String> _getAuthors(List<Book> books) {
    final authors = List<String>.empty(growable: true);

    for (var book in books) {
      if (!authors.contains(book.author)) {
        authors.add(book.author);
      }
    }

    authors.sort((a, b) => a.compareTo(b));

    return authors;
  }

  Future<bool> _checkIfCoverMigrationDone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? check = prefs.getBool(SharedPreferencesKeys.coverMigrationDone);

    return check == true ? true : false;
  }

  Future<void> _migrateCoversFromDatabaseToStorage() async {
    List<Book> allBooks = await repository.getAllBooks();

    for (var book in allBooks) {
      if (book.cover != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${book.id}.jpg');

        await file.writeAsBytes(book.cover!);

        Book updatedBook = book.copyWithNullCover();
        updatedBook = book.copyWith(hasCover: true);

        await repository.updateBook(updatedBook);
      }
    }

    await _saveCoverMigrationStatus();
  }

  Future<void> _saveCoverMigrationStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SharedPreferencesKeys.coverMigrationDone, true);
  }

  getBooksWithSameTag(String tag) async {
    _booksWithSameTagFetcher.sink.add(null);

    List<Book> books = await repository.getBooksWithSameTag(tag);

    _booksWithSameTagFetcher.sink.add(books);
  }

  getBooksWithSameAuthor(String author) async {
    _booksWithSameAuthorFetcher.sink.add(null);

    List<Book> books = await repository.getBooksWithSameAuthor(author);

    _booksWithSameAuthorFetcher.sink.add(books);
  }

  Future<bool> downloadCoverByISBN(Book book) async {
    if (book.isbn == null) return false;
    if (book.isbn!.isEmpty) return false;

    final cover = await OpenLibraryService().getCover(book.isbn!);
    if (cover == null) return false;

    final file = File('${appDocumentsDirectory.path}/${book.id}.jpg');
    await file.writeAsBytes(cover);

    final blurHash = _generateBlurHash(cover);

    await bookCubit.updateBook(book.copyWith(
      hasCover: true,
      blurHash: blurHash,
    ));

    return true;
  }

  static String? _generateBlurHash(Uint8List? cover) {
    if (cover == null) return null;

    return blurhash_dart.BlurHash.encode(
      img.decodeImage(cover)!,
      numCompX: Constants.blurHashX,
      numCompY: Constants.blurHashY,
    ).hash;
  }
}
