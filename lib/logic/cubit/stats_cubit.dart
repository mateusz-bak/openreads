import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_stat.dart';
import 'package:openreads/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class StatsCubit extends Cubit {
  final Repository repository = Repository();

  final BehaviorSubject<List<int>> _finishedBooksByMonthFetcher =
      BehaviorSubject<List<int>>();
  final BehaviorSubject<List<int>> _finishedPagesByMonthFetcher =
      BehaviorSubject<List<int>>();
  final BehaviorSubject<int> _numberOfFinishedBooksFetcher =
      BehaviorSubject<int>();
  final BehaviorSubject<int> _numberOfFinishedPagesFetcher =
      BehaviorSubject<int>();
  final BehaviorSubject<double> _avgRatingFetcher = BehaviorSubject<double>();
  final BehaviorSubject<double> _avgPagesFetcher = BehaviorSubject<double>();
  final BehaviorSubject<BookStat?> _longestFetcher =
      BehaviorSubject<BookStat?>();
  final BehaviorSubject<BookStat?> _shortestFetcher =
      BehaviorSubject<BookStat?>();
  final BehaviorSubject<BookStat?> _fastestFetcher =
      BehaviorSubject<BookStat?>();
  final BehaviorSubject<BookStat?> _slowestFetcher =
      BehaviorSubject<BookStat?>();
  final BehaviorSubject<double?> _avgReadingTimeFetcher =
      BehaviorSubject<double?>();

  Stream<List<int>> get finishedBooksByMonth =>
      _finishedBooksByMonthFetcher.stream;
  Stream<List<int>> get finishedPagesByMonth =>
      _finishedPagesByMonthFetcher.stream;
  Stream<int> get numberOfFinishedBooks => _numberOfFinishedBooksFetcher.stream;
  Stream<int> get numberOfFinishedPages => _numberOfFinishedPagesFetcher.stream;
  Stream<double> get avgRating => _avgRatingFetcher.stream;
  Stream<double> get avgPages => _avgPagesFetcher.stream;
  Stream<BookStat?> get longest => _longestFetcher.stream;
  Stream<BookStat?> get shortest => _shortestFetcher.stream;
  Stream<BookStat?> get fastest => _fastestFetcher.stream;
  Stream<BookStat?> get slowest => _slowestFetcher.stream;
  Stream<double?> get avgReadingTime => _avgReadingTimeFetcher.stream;

  StatsCubit() : super(null) {
    getFinishedBooksByMonth();
    getFinishedPagesByMonth();
    getNumberOfFinishedBooks();
    getNumberOfFinishedPages();
    getAverageRating();
    getAveragePages();
    getAverageReadingTime();
    getLongestBook();
    getShortestBook();
    getFastestReadBook();
    getSlowestReadBook();
  }

  getFinishedBooksByMonth() async {
    List<Book> books = await repository.getBooks(0);

    List<int> finishedBooksByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (book.finishDate != null) {
        final finishMonth = DateTime.parse(book.finishDate!).month;

        finishedBooksByMonth[finishMonth - 1] += 1;
      }
    }

    _finishedBooksByMonthFetcher.sink.add(finishedBooksByMonth);
  }

  getFinishedPagesByMonth() async {
    List<Book> books = await repository.getBooks(0);

    List<int> finishedPagesByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (book.finishDate != null && book.pages != null) {
        final finishMonth = DateTime.parse(book.finishDate!).month;

        finishedPagesByMonth[finishMonth - 1] += book.pages!;
      }
    }

    _finishedPagesByMonthFetcher.sink.add(finishedPagesByMonth);
  }

  getNumberOfFinishedBooks() async {
    List<Book> books = await repository.getBooks(0);
    _numberOfFinishedBooksFetcher.sink.add(books.length);
  }

  getNumberOfFinishedPages() async {
    List<Book> books = await repository.getBooks(0);

    int finishedPages = 0;

    for (Book book in books) {
      if (book.pages != null) {
        finishedPages += book.pages!;
      }
    }

    _numberOfFinishedPagesFetcher.sink.add(finishedPages);
  }

  getAverageRating() async {
    List<Book> books = await repository.getBooks(0);

    double sumRating = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.rating != null) {
        sumRating += book.rating! / 10;
        countedBooks += 1;
      }
    }

    if (books.isEmpty) {
      _avgRatingFetcher.sink.add(0);
    } else {
      _avgRatingFetcher.sink.add(sumRating / countedBooks);
    }
  }

  getAveragePages() async {
    List<Book> books = await repository.getBooks(0);

    int finishedPages = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.pages != null) {
        finishedPages += book.pages!;
        countedBooks += 1;
      }
    }

    if (books.isEmpty) {
      _avgPagesFetcher.sink.add(0);
    } else {
      _avgPagesFetcher.sink.add(finishedPages / countedBooks);
    }
  }

  getLongestBook() async {
    List<Book> books = await repository.getBooks(0);

    int longestBookPages = 0;
    String? longestBook;

    for (Book book in books) {
      if (book.pages != null) {
        if (book.pages! > longestBookPages) {
          longestBookPages = book.pages!;
          longestBook = '${book.title} - ${book.author}';
        }
      }
    }

    if (longestBookPages == 0) {
      _longestFetcher.sink.add(null);
    } else {
      _longestFetcher.sink.add(
        BookStat(
          title: longestBook!,
          value: longestBookPages.toString(),
        ),
      );
    }
  }

  getShortestBook() async {
    List<Book> books = await repository.getBooks(0);

    int shortestBookPages = 99999999;
    String? shortestBook;

    for (Book book in books) {
      if (book.pages != null && book.pages! > 0) {
        if (book.pages! < shortestBookPages) {
          shortestBookPages = book.pages!;
          shortestBook = '${book.title} - ${book.author}';
        }
      }
    }

    if (shortestBookPages == 99999999) {
      _shortestFetcher.sink.add(null);
    } else {
      _shortestFetcher.sink.add(
        BookStat(
          title: shortestBook!,
          value: shortestBookPages.toString(),
        ),
      );
    }
  }

  getFastestReadBook() async {
    List<Book> books = await repository.getBooks(0);

    int? fastestReadTimeInMs;
    int? fastestReadTimeInDays;
    String? fastestReadBook;

    for (Book book in books) {
      if (book.startDate != null && book.finishDate != null) {
        final startDate = DateTime.parse(book.startDate!);
        final finishDate = DateTime.parse(book.finishDate!);

        final timeDifference = finishDate.difference(startDate);

        if (fastestReadTimeInMs == null) {
          fastestReadTimeInMs = timeDifference.inMilliseconds;
          fastestReadTimeInDays = timeDifference.inDays;
          fastestReadBook = '${book.title} - ${book.author}';
        }

        if (timeDifference.inMilliseconds < fastestReadTimeInMs) {
          fastestReadTimeInMs = timeDifference.inMilliseconds;
          fastestReadTimeInDays = timeDifference.inDays;
          fastestReadBook = '${book.title} - ${book.author}';
        }
      }
    }

    if (fastestReadTimeInMs == null) {
      _fastestFetcher.sink.add(null);
    } else {
      _fastestFetcher.sink.add(
        BookStat(
          title: fastestReadBook!,
          value: fastestReadTimeInDays.toString(),
        ),
      );
    }
  }

  getSlowestReadBook() async {
    List<Book> books = await repository.getBooks(0);

    int? slowestReadTimeInMs;
    int? slowestReadTimeInDays;
    String? slowestReadBook;

    for (Book book in books) {
      if (book.startDate != null && book.finishDate != null) {
        final startDate = DateTime.parse(book.startDate!);
        final finishDate = DateTime.parse(book.finishDate!);

        final timeDifference = finishDate.difference(startDate);

        if (slowestReadTimeInMs == null) {
          slowestReadTimeInMs = timeDifference.inMilliseconds;
          slowestReadTimeInDays = timeDifference.inDays;
          slowestReadBook = '${book.title} - ${book.author}';
        }

        if (timeDifference.inMilliseconds > slowestReadTimeInMs) {
          slowestReadTimeInMs = timeDifference.inMilliseconds;
          slowestReadTimeInDays = timeDifference.inDays;
          slowestReadBook = '${book.title} - ${book.author}';
        }
      }
    }

    if (slowestReadTimeInMs == null) {
      _slowestFetcher.sink.add(null);
    } else {
      _slowestFetcher.sink.add(
        BookStat(
          title: slowestReadBook!,
          value: slowestReadTimeInDays.toString(),
        ),
      );
    }
  }

  getAverageReadingTime() async {
    List<Book> books = await repository.getBooks(0);

    int readTimeInDays = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.startDate != null && book.finishDate != null) {
        final startDate = DateTime.parse(book.startDate!);
        final finishDate = DateTime.parse(book.finishDate!);
        final timeDifference = finishDate.difference(startDate).inDays;

        readTimeInDays += timeDifference;
        countedBooks += 1;
      }
    }

    if (readTimeInDays == 0 || countedBooks == 0) {
      _avgReadingTimeFetcher.sink.add(null);
    } else {
      _avgReadingTimeFetcher.sink.add(readTimeInDays / countedBooks);
    }
  }
}
