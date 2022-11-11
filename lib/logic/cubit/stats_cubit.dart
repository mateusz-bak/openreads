import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_read_stat.dart';
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
  final BehaviorSubject<List<BookYearlyStat>?> _avgReadingTimeFetcher =
      BehaviorSubject<List<BookYearlyStat>?>();
  final BehaviorSubject<List<BookYearlyStat>?> _longestFetcher =
      BehaviorSubject<List<BookYearlyStat>?>();
  final BehaviorSubject<List<BookYearlyStat>?> _shortestFetcher =
      BehaviorSubject<List<BookYearlyStat>?>();
  final BehaviorSubject<List<BookYearlyStat>?> _fastestFetcher =
      BehaviorSubject<List<BookYearlyStat>?>();
  final BehaviorSubject<List<BookYearlyStat>?> _slowestFetcher =
      BehaviorSubject<List<BookYearlyStat>?>();

  Stream<List<int>> get years => _yearsFetcher.stream;
  Stream<List<int>> get allBooksByStatus => _allBooksByStatusFetcher.stream;
  Stream<List<BookReadStat>> get finishedBooksByMonth =>
      _finishedBooksByMonthFetcher.stream;
  Stream<List<BookReadStat>> get finishedPagesByMonth =>
      _finishedPagesByMonthFetcher.stream;
  Stream<List<BookYearlyStat>> get avgRating => _avgRatingFetcher.stream;
  Stream<List<BookYearlyStat>> get avgPages => _avgPagesFetcher.stream;
  Stream<List<BookYearlyStat>?> get avgReadingTime =>
      _avgReadingTimeFetcher.stream;
  Stream<List<BookYearlyStat>?> get longest => _longestFetcher.stream;
  Stream<List<BookYearlyStat>?> get shortest => _shortestFetcher.stream;
  Stream<List<BookYearlyStat>?> get fastest => _fastestFetcher.stream;
  Stream<List<BookYearlyStat>?> get slowest => _slowestFetcher.stream;

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
      return (sumRating / countedBooks).toStringAsFixed(1);
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

  getAverageReadingTime() async {
    List<Book> books = await repository.getBooks(0);
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    bookYearlyStats.add(
      BookYearlyStat(value: _getAverageReadingTimeInYear(books)),
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
          value: _getAverageReadingTimeInYear(booksInyear),
        ),
      );
    }

    _avgPagesFetcher.sink.add(bookYearlyStats);

    _avgReadingTimeFetcher.sink.add(bookYearlyStats);
  }

  String _getAverageReadingTimeInYear(List<Book> books) {
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
      return '';
    } else {
      return (readTimeInDays / countedBooks).toStringAsFixed(0);
    }
  }

  getLongestBook() async {
    List<Book> books = await repository.getBooks(0);
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final longestBook = _getLongestBookInYear(books, null);

    if (longestBook == null) return;
    bookYearlyStats.add(longestBook);

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
      final longestBookInAYear = _getLongestBookInYear(booksInyear, year);

      if (longestBookInAYear != null) {
        bookYearlyStats.add(longestBookInAYear);
      }
    }

    _longestFetcher.sink.add(bookYearlyStats);
  }

  BookYearlyStat? _getLongestBookInYear(List<Book> books, int? year) {
    int longestBookPages = 0;
    String? longestBook;

    for (Book book in books) {
      if (book.pages != null && book.pages! > 0) {
        if (book.pages! > longestBookPages) {
          longestBookPages = book.pages!;
          longestBook = '${book.title} - ${book.author}';
        }
      }
    }

    if (longestBookPages == 0) {
      return null;
    } else {
      return BookYearlyStat(
          title: longestBook, value: longestBookPages.toString(), year: year);
    }
  }

  getShortestBook() async {
    List<Book> books = await repository.getBooks(0);
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final shortestBook = _getShortestBookInYear(books, null);

    if (shortestBook == null) return;
    bookYearlyStats.add(shortestBook);

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
      final shortestBookInAYear = _getShortestBookInYear(booksInyear, year);

      if (shortestBookInAYear != null) {
        bookYearlyStats.add(shortestBookInAYear);
      }
    }

    _shortestFetcher.sink.add(bookYearlyStats);
  }

  BookYearlyStat? _getShortestBookInYear(List<Book> books, int? year) {
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
      return null;
    } else {
      return BookYearlyStat(
          title: shortestBook, value: shortestBookPages.toString(), year: year);
    }
  }

  getFastestReadBook() async {
    List<Book> books = await repository.getBooks(0);
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final fastestBook = _getFastestReadBookInYear(books, null);

    if (fastestBook == null) return;
    bookYearlyStats.add(fastestBook);

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
      final fastestBookInAYear = _getFastestReadBookInYear(booksInyear, year);

      if (fastestBookInAYear != null) {
        bookYearlyStats.add(fastestBookInAYear);
      }
    }

    _fastestFetcher.sink.add(bookYearlyStats);
  }

  BookYearlyStat? _getFastestReadBookInYear(List<Book> books, int? year) {
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
      return null;
    } else {
      return BookYearlyStat(
        title: fastestReadBook,
        value: fastestReadTimeInDays.toString(),
        year: year,
      );
    }
  }

  getSlowestReadBook() async {
    List<Book> books = await repository.getBooks(0);
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final slowestBook = _getSlowestReadBookInYear(books, null);

    if (slowestBook == null) return;
    bookYearlyStats.add(slowestBook);

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
      final slowestBookInAYear = _getSlowestReadBookInYear(booksInyear, year);

      if (slowestBookInAYear != null) {
        bookYearlyStats.add(slowestBookInAYear);
      }
    }

    _slowestFetcher.sink.add(bookYearlyStats);
  }

  BookYearlyStat? _getSlowestReadBookInYear(List<Book> books, int? year) {
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
      return null;
    } else {
      return BookYearlyStat(
        title: slowestReadBook,
        value: slowestReadTimeInDays.toString(),
        year: year,
      );
    }
  }
}
