import 'package:openreads/model/book.dart';
import 'package:openreads/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class BookBloc {
  final Repository repository = Repository();

  final PublishSubject<List<Book>> _bookFetcher = PublishSubject<List<Book>>();

  Stream<List<Book>> get allBooks => _bookFetcher.stream;

  BookBloc() {
    getAllBooks();
  }

  getAllBooks() async {
    List<Book> book = await repository.getAllBooks();
    _bookFetcher.sink.add(book);
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
}

final bookBloc = BookBloc();
