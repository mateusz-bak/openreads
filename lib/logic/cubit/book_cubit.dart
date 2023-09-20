import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/resources/repository.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/enums.dart';

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
  final BehaviorSubject<Book?> _bookFetcher = BehaviorSubject<Book?>();

  Stream<List<Book>> get allBooks => _booksFetcher.stream;
  Stream<List<Book>> get finishedBooks => _finishedBooksFetcher.stream;
  Stream<List<Book>> get inProgressBooks => _inProgressBooksFetcher.stream;
  Stream<List<Book>> get toReadBooks => _toReadBooksFetcher.stream;
  Stream<List<Book>> get deletedBooks => _deletedBooksFetcher.stream;
  Stream<List<Book>> get unfinishedBooks => _unfinishedBooksFetcher.stream;
  Stream<List<Book>> get searchBooks => _searchBooksFetcher.stream;
  Stream<List<int>> get finishedYears => _finishedYearsFetcher.stream;
  Stream<List<String>> get tags => _tagsFetcher.stream;

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

  getAllBooks({bool tags = false}) async {
    List<Book> books = await repository.getAllNotDeletedBooks();
    _booksFetcher.sink.add(books);
    if (tags) return;
    _tagsFetcher.sink.add(_getTags(books));
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

  addBook(Book book, {bool refreshBooks = true, File? coverFile}) async {
    final bookID = await repository.insertBook(book);

    await _saveCoverToStorage(bookID, coverFile);

    if (refreshBooks) {
      getAllBooksByStatus();
      getAllBooks();
    }
  }

  Future _saveCoverToStorage(int? bookID, File? coverFile) async {
    if (bookID == null || coverFile == null) return;

    final file = File('${appDocumentsDirectory.path}/$bookID.jpg');
    await file.writeAsBytes(coverFile.readAsBytesSync());
  }

  updateBook(Book book, {File? coverFile, BuildContext? context}) async {
    repository.updateBook(book);
    await _saveCoverToStorage(book.id!, coverFile);

    if (context != null) {
      // This looks bad but we need to wait for cover to be saved to storage
      // before updating current book
      context.read<CurrentBookCubit>().setBook(book.copyWith());
    }

    getBook(book.id!);
    getAllBooksByStatus();
    getAllBooks();
  }

  updateBookType(Set<int> ids, BookType bookType) async {
    repository.updateBookType(ids, bookType);
    getAllBooksByStatus();
    getAllBooks();
  }

  deleteBook(int id) async {
    repository.deleteBook(id);
    getAllBooksByStatus();
    getAllBooks();
  }

  getBook(int id) async {
    Book book = await repository.getBook(id);
    _bookFetcher.sink.add(book);
  }

  List<int> _getFinishedYears(List<Book> books) {
    final years = List<int>.empty(growable: true);

    for (var book in books) {
      if (book.finishDate != null) {
        years.add(book.finishDate!.year);
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

  Future<bool> _checkIfCoverMigrationDone() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool? check = prefs.getBool('is_cover_migration_done');

    return check == true ? true : false;
  }

  Future<void> _migrateCoversFromDatabaseToStorage() async {
    List<Book> allBooks = await repository.getAllBooks();

    for (var book in allBooks) {
      if (book.cover != null) {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/${book.id}.jpg');

        await file.writeAsBytes(book.cover!);
        await repository.updateBook(book.copyWithNullCover());
      }
    }

    await _saveCoverMigrationStatus();
  }

  Future<void> _saveCoverMigrationStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('is_cover_migration_done', true);
  }
}
