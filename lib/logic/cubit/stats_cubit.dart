import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_read_stat.dart';
import 'package:openreads/model/book_stat.dart';
import 'package:openreads/model/book_yearly_stat.dart';
import 'package:openreads/resources/repository.dart';
import 'package:rxdart/rxdart.dart';

class StatsCubit extends Cubit {
  final Repository repository = Repository();

  final BehaviorSubject<List<int>> _yearsFetcher = BehaviorSubject<List<int>>();
  final BehaviorSubject<List<int>> _allBooksByStatusFetcher =
      BehaviorSubject<List<int>>();
  final BehaviorSubject<List<BookReadStat>> _finishedBooksByMonthFetcher =
      BehaviorSubject<List<BookReadStat>>();
  final BehaviorSubject<List<BookReadStat>> _finishedPagesByMonthFetcher =
      BehaviorSubject<List<BookReadStat>>();
  final BehaviorSubject<List<BookYearlyStat>> _avgRatingFetcher =
      BehaviorSubject<List<BookYearlyStat>>();
  final BehaviorSubject<List<BookYearlyStat>> _avgPagesFetcher =
      BehaviorSubject<List<BookYearlyStat>>();
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

  Stream<List<int>> get years => _yearsFetcher.stream;
  Stream<List<int>> get allBooksByStatus => _allBooksByStatusFetcher.stream;
  Stream<List<BookReadStat>> get finishedBooksByMonth =>
      _finishedBooksByMonthFetcher.stream;
  Stream<List<BookReadStat>> get finishedPagesByMonth =>
      _finishedPagesByMonthFetcher.stream;
  Stream<List<BookYearlyStat>> get avgRating => _avgRatingFetcher.stream;
  Stream<List<BookYearlyStat>> get avgPages => _avgPagesFetcher.stream;
  Stream<BookStat?> get longest => _longestFetcher.stream;
  Stream<BookStat?> get shortest => _shortestFetcher.stream;
  Stream<BookStat?> get fastest => _fastestFetcher.stream;
  Stream<BookStat?> get slowest => _slowestFetcher.stream;
  Stream<double?> get avgReadingTime => _avgReadingTimeFetcher.stream;

  StatsCubit() : super(null) {
    getYears();
    getAllBooksByStatus();
    getFinishedBooksByMonth();
    getFinishedPagesByMonth();

    getAverageRating();
    getAveragePages();
    getAverageReadingTime();
    getLongestBook();
    getShortestBook();
    getFastestReadBook();
    getSlowestReadBook();
  }

  getYears() async {
    final books = await repository.getBooks(0);
    final bookWithYears = List<Book>.empty(growable: true);

    for (var book in books) {
      if (book.finishDate != null) {
        bookWithYears.add(book);
      }
    }

    _yearsFetcher.sink.add(
      _calculateYears(bookWithYears),
    );
  }

  List<int> _calculateYears(List<Book> books) {
    final years = List<int>.empty(growable: true);

    for (var book in books) {
      final year = DateTime.parse(book.finishDate!).year;

      if (!years.contains(year)) {
        years.add(year);
      }
    }

    years.sort((a, b) {
      return b.compareTo(a);
    });

    return years;
  }

  getAllBooksByStatus() async {
    final finishedBooks = await repository.countBooks(0);
    final inprogressBooks = await repository.countBooks(1);
    final forLaterBooks = await repository.countBooks(2);
    final unfinishedBooks = await repository.countBooks(3);

    _allBooksByStatusFetcher.sink.add([
      finishedBooks,
      inprogressBooks,
      forLaterBooks,
      unfinishedBooks,
    ]);
  }

  getFinishedBooksByMonth() async {
    List<Book> books = await repository.getBooks(0);
    List<BookReadStat> bookReadStats = List<BookReadStat>.empty(growable: true);

    bookReadStats.add(
      BookReadStat(values: _getBooksByMonth(books)),
    );

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null) {
          final finishYear = DateTime.parse(book.finishDate!).year;

          if (finishYear == year) {
            booksInyear.add(book);
          }
        }
      }

      bookReadStats.add(
        BookReadStat(
          year: year,
          values: _getBooksByMonth(booksInyear),
        ),
      );
    }

    _finishedBooksByMonthFetcher.sink.add(bookReadStats);
  }

  List<int> _getBooksByMonth(List<Book> books) {
    List<int> finishedBooksByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (book.finishDate != null) {
        final finishMonth = DateTime.parse(book.finishDate!).month;

        finishedBooksByMonth[finishMonth - 1] += 1;
      }
    }
    return finishedBooksByMonth;
  }

  List<Book> _getBooksWithFinishDate(List<Book> books) {
    final booksWithYears = List<Book>.empty(growable: true);

    for (var book in books) {
      if (book.finishDate != null) {
        booksWithYears.add(book);
      }
    }
    return booksWithYears;
  }

  getFinishedPagesByMonth() async {
    List<Book> books = await repository.getBooks(0);
    List<BookReadStat> bookReadStats = List<BookReadStat>.empty(growable: true);

    bookReadStats.add(
      BookReadStat(values: _getPagesByMonth(books)),
    );

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInYear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.pages != null) {
          final finishYear = DateTime.parse(book.finishDate!).year;

          if (finishYear == year) {
            booksInYear.add(book);
          }
        }
      }

      bookReadStats.add(
        BookReadStat(
          year: year,
          values: _getPagesByMonth(booksInYear),
        ),
      );
    }

    _finishedPagesByMonthFetcher.sink.add(bookReadStats);
  }

  List<int> _getPagesByMonth(List<Book> books) {
    List<int> finishedPagesByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (book.finishDate != null) {
        final finishMonth = DateTime.parse(book.finishDate!).month;

        finishedPagesByMonth[finishMonth - 1] += book.pages!;
      }
    }
    return finishedPagesByMonth;
  }

  getAverageRating() async {
    List<Book> books = await repository.getBooks(0);
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    bookYearlyStats.add(
      BookYearlyStat(value: _getAverageRatingInYear(books)),
    );

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.rating != null) {
          final finishYear = DateTime.parse(book.finishDate!).year;

          if (finishYear == year) {
            booksInyear.add(book);
          }
        }
      }

      bookYearlyStats.add(
        BookYearlyStat(
          year: year,
          value: _getAverageRatingInYear(booksInyear),
        ),
      );
    }

    _avgRatingFetcher.sink.add(bookYearlyStats);
  }

  String _getAverageRatingInYear(List<Book> books) {
    double sumRating = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.rating != null) {
        sumRating += book.rating! / 10;
        countedBooks += 1;
      }
    }

    if (countedBooks == 0) {
      return '0';
    } else {
      return (sumRating / countedBooks).toStringAsFixed(2);
    }
  }

  getAveragePages() async {
    List<Book> books = await repository.getBooks(0);
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    bookYearlyStats.add(
      BookYearlyStat(value: _getAveragePagesInYear(books)),
    );

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.rating != null) {
          final finishYear = DateTime.parse(book.finishDate!).year;

          if (finishYear == year) {
            booksInyear.add(book);
          }
        }
      }

      bookYearlyStats.add(
        BookYearlyStat(
          year: year,
          value: _getAveragePagesInYear(booksInyear),
        ),
      );
    }

    _avgPagesFetcher.sink.add(bookYearlyStats);
  }

  String _getAveragePagesInYear(List<Book> books) {
    int finishedPages = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.pages != null) {
        finishedPages += book.pages!;
        countedBooks += 1;
      }
    }

    if (countedBooks == 0) {
      return '0';
    } else {
      return (finishedPages / countedBooks).toStringAsFixed(0);
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
