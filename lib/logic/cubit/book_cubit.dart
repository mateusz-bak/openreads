import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class BookCubit extends Cubit {
  final Repository repository = Repository();

  final BehaviorSubject<List<Book>> _booksFetcher =
      BehaviorSubject<List<Book>>();
  final BehaviorSubject<Book> _bookFetcher = BehaviorSubject<Book>();

  Stream<List<Book>> get allBooks => _booksFetcher.stream;
  Stream<Book> get book => _bookFetcher.stream;

  BookCubit() : super(null) {
    getAllBooks();
  }

  getAllBooks() async {
    List<Book> book = await repository.getAllBooks();
    _booksFetcher.sink.add(book);
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

final bookCubit = BookCubit();
