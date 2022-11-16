import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

final bookCubit = BookCubit();

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
  final BehaviorSubject<List<int>> _finishedYearsFetcher =
      BehaviorSubject<List<int>>();
  final BehaviorSubject<List<String>> _tagsFetcher =
      BehaviorSubject<List<String>>();
  final BehaviorSubject<Book> _bookFetcher = BehaviorSubject<Book>();

  Stream<List<Book>> get allBooks => _booksFetcher.stream;
  Stream<List<Book>> get finishedBooks => _finishedBooksFetcher.stream;
  Stream<List<Book>> get inProgressBooks => _inProgressBooksFetcher.stream;
  Stream<List<Book>> get toReadBooks => _toReadBooksFetcher.stream;
  Stream<List<int>> get finishedYears => _finishedYearsFetcher.stream;
  Stream<List<String>> get tags => _tagsFetcher.stream;

  Stream<Book> get book => _bookFetcher.stream;

  BookCubit() : super(null) {
    getFinishedBooks();
    getInProgressBooks();
    getToReadBooks();
    getAllBooks();
  }

  getAllBooks() async {
    List<Book> books = await repository.getAllBooks();
    _booksFetcher.sink.add(books);
  }

  getAllBooksByStatus() async {
    getFinishedBooks();
    getInProgressBooks();
    getToReadBooks();
  }

  getFinishedBooks() async {
    List<Book> books = await repository.getBooks(0);

    _finishedBooksFetcher.sink.add(books);
    _finishedYearsFetcher.sink.add(_getFinishedYears(books));
    _tagsFetcher.sink.add(_getTags(books));
  }

  getInProgressBooks() async {
    List<Book> books = await repository.getBooks(1);
    _inProgressBooksFetcher.sink.add(books);
  }

  getToReadBooks() async {
    List<Book> books = await repository.getBooks(2);
    _toReadBooksFetcher.sink.add(books);
  }

  addBook(Book book) async {
    await repository.insertBook(book);
    getAllBooksByStatus();
    getAllBooks();
  }

  updateBook(Book book) async {
    repository.updateBook(book);
    getBook(book.id!);
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
        years.add(DateTime.parse(book.finishDate!).year);
      }
    }

    years.sort((a, b) => b.compareTo(a));

    return years;
  }

  List<String> _getTags(List<Book> books) {
    final tags = List<String>.empty(growable: true);

    for (var book in books) {
      if (book.tags != null) {
        for (var tag in book.tags!.split('|')) {
          if (!tags.contains(tag)) {
            tags.add(tag);
          }
        }
      }
    }

    tags.sort((a, b) => a.compareTo(b));

    return tags;
  }
}
