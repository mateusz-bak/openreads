import 'package:openreads/model/book.dart';
import 'package:openreads/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class BookBloc {
  final Repository repository = Repository();

  final PublishSubject<List<Book>> _booksFetcher = PublishSubject<List<Book>>();
  final PublishSubject<Book> _bookFetcher = PublishSubject<Book>();

  Stream<List<Book>> get allBooks => _booksFetcher.stream;
  Stream<Book> get book => _bookFetcher.stream;

  BookBloc() {
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

final bookBloc = BookBloc();
