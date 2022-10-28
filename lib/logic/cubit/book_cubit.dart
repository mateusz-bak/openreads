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
  final BehaviorSubject<Book> _bookFetcher = BehaviorSubject<Book>();

  Stream<List<Book>> get allBooks => _booksFetcher.stream;
  Stream<List<Book>> get finishedBooks => _finishedBooksFetcher.stream;
  Stream<List<Book>> get inProgressBooks => _inProgressBooksFetcher.stream;
  Stream<List<Book>> get toReadBooks => _toReadBooksFetcher.stream;
  Stream<Book> get book => _bookFetcher.stream;

  BookCubit() : super(null) {
    getFinishedBooks();
    getInProgressBooks();
    getToReadBooks();
  }

  getAllBooks() async {
    getFinishedBooks();
    getInProgressBooks();
    getToReadBooks();
  }

  getFinishedBooks() async {
    List<Book> books = await repository.getBooks(0);
    _finishedBooksFetcher.sink.add(books);
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
    getAllBooks();
  }

  updateBook(Book book) async {
    repository.updateBook(book);
    getBook(book.id!);
    getAllBooks();
  }

  deleteBook(int id) async {
    repository.deleteBook(id);
    getAllBooks();
  }

  getBook(int id) async {
    Book book = await repository.getBook(id);
    _bookFetcher.sink.add(book);
  }
}
