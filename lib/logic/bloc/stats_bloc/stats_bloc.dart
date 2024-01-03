import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_read_stat.dart';
import 'package:openreads/model/book_yearly_stat.dart';
import 'package:openreads/model/reading_time.dart';

part 'stats_event.dart';
part 'stats_state.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  StatsBloc() : super(StatsLoading()) {
    on<StatsLoad>((event, emit) {
      final allBooks = event.books;
      final finishedBooks = _filterFinishedBooks(allBooks, 0);

      if (finishedBooks.isEmpty) {
        emit(StatsError(LocaleKeys.add_books_and_come_back.tr()));
        return;
      }

      final years = getYears(finishedBooks);
      final inProgressBooks = _filterFinishedBooks(allBooks, 1);
      final forLaterBooks = _filterFinishedBooks(allBooks, 2);
      final unfinishedBooks = _filterFinishedBooks(allBooks, 3);

      final finishedBooksByMonthAllTypes =
          _getFinishedBooksByMonth(finishedBooks, null);
      final finishedBooksByMonthPaperbackBooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.paperback);
      final finishedBooksByMonthHardcoverBooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.hardcover);
      final finishedBooksByMonthEbooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.ebook);
      final finishedBooksByMonthAudiobooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.audiobook);

      final finishedPagesByMonthAllTypes =
          _getFinishedPagesByMonth(finishedBooks, null);
      final finishedPagesByMonthPaperbackBooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.paperback);
      final finishedPagesByMonthHardcoverBooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.hardcover);
      final finishedPagesByMonthEbooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.ebook);
      final finishedPagesByMonthAudiobooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.audiobook);

      final finishedPagesAll = _calculateAllReadPages(finishedBooks);

      final averageRating = _getAverageRating(finishedBooks);
      final averagePages = _getAveragePages(finishedBooks);
      final averageReadingTime = _getAverageReadingTime(finishedBooks);
      final longestBook = _getLongestBook(finishedBooks);
      final shortestBook = _getShortestBook(finishedBooks);
      final fastestBook = _getFastestReadBook(finishedBooks);
      final slowestBook = _getSlowestReadBook(finishedBooks);

      emit(StatsLoaded(
        years: years,
        finishedBooks: finishedBooks,
        inProgressBooks: inProgressBooks,
        forLaterBooks: forLaterBooks,
        unfinishedBooks: unfinishedBooks,
        finishedBooksByMonthAllTypes: finishedBooksByMonthAllTypes,
        finishedBooksByMonthPaperbackBooks: finishedBooksByMonthPaperbackBooks,
        finishedBooksByMonthHardcoverBooks: finishedBooksByMonthHardcoverBooks,
        finishedBooksByMonthEbooks: finishedBooksByMonthEbooks,
        finishedBooksByMonthAudiobooks: finishedBooksByMonthAudiobooks,
        finishedPagesByMonthAllTypes: finishedPagesByMonthAllTypes,
        finishedPagesByMonthPaperbackBooks: finishedPagesByMonthPaperbackBooks,
        finishedPagesByMonthHardcoverBooks: finishedPagesByMonthHardcoverBooks,
        finishedPagesByMonthEbooks: finishedPagesByMonthEbooks,
        finishedPagesByMonthAudiobooks: finishedPagesByMonthAudiobooks,
        finishedBooksAll: finishedBooks.length,
        finishedPagesAll: finishedPagesAll,
        averageRating: averageRating,
        averagePages: averagePages,
        averageReadingTime: averageReadingTime,
        longestBook: longestBook,
        shortestBook: shortestBook,
        fastestBook: fastestBook,
        slowestBook: slowestBook,
      ));
    });
  }

  int _calculateAllReadPages(List<Book> books) {
    int pages = 0;

    for (var book in books) {
      if (book.pages != null) {
        pages = pages + book.pages!;
      }
    }

    return pages;
  }

  List<BookYearlyStat> _getSlowestReadBook(List<Book> books) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final slowestBook = _getSlowestReadBookInYear(books, null);

    if (slowestBook != null) {
      bookYearlyStats.add(slowestBook);
    }

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.rating != null) {
          final finishYear = book.finishDate!.year;

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
    return bookYearlyStats;
  }

  BookYearlyStat? _getSlowestReadBookInYear(List<Book> books, int? year) {
    int? slowestReadTimeInMs;
    String? slowestReadBook;

    for (Book book in books) {
      int? readTimeInMs;
      if (book.readingTime != null) {
        readTimeInMs = book.readingTime!.milliSeconds;
      } else if (book.startDate != null && book.finishDate != null) {
        final startDate = book.startDate!;
        final finishDate = book.finishDate!;
        final readTimeinDays = finishDate.difference(startDate).inDays +
            1; // should be at least 1 day
        readTimeInMs =
            ReadingTime.toMilliSeconds(readTimeinDays, 0, 0).milliSeconds;
      } else {
        continue;
      }
      if (slowestReadTimeInMs == null) {
        slowestReadTimeInMs = readTimeInMs;
        slowestReadBook = '${book.title} - ${book.author}';
      }

      if (readTimeInMs > slowestReadTimeInMs) {
        slowestReadTimeInMs = readTimeInMs;
        slowestReadBook = '${book.title} - ${book.author}';
      }
    }

    if (slowestReadTimeInMs == null) {
      return null;
    } else {
      return BookYearlyStat(
        title: slowestReadBook,
        value: ReadingTime.fromMilliSeconds(slowestReadTimeInMs).toString(),
        year: year,
      );
    }
  }

  List<BookYearlyStat> _getFastestReadBook(List<Book> books) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final fastestBook = _getFastestReadBookInYear(books, null);

    if (fastestBook != null) {
      bookYearlyStats.add(fastestBook);
    }

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.rating != null) {
          final finishYear = book.finishDate!.year;

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

    return bookYearlyStats;
  }

  BookYearlyStat? _getFastestReadBookInYear(List<Book> books, int? year) {
    int? fastestReadTimeInMs;
    String? fastestReadBook;

    for (Book book in books) {
      int? readTimeInMs;
      if (book.readingTime != null) {
        readTimeInMs = book.readingTime!.milliSeconds;
      } else if (book.startDate != null && book.finishDate != null) {
        final startDate = book.startDate!;
        final finishDate = book.finishDate!;
        final readTimeinDays = finishDate.difference(startDate).inDays +
            1; // should be at least 1 day
        readTimeInMs =
            ReadingTime.toMilliSeconds(readTimeinDays, 0, 0).milliSeconds;
      } else {
        continue;
      }
      if (fastestReadTimeInMs == null) {
        fastestReadTimeInMs = readTimeInMs;
        fastestReadBook = '${book.title} - ${book.author}';
      }

      if (readTimeInMs < fastestReadTimeInMs) {
        fastestReadTimeInMs = readTimeInMs;
        fastestReadBook = '${book.title} - ${book.author}';
      }
    }

    if (fastestReadTimeInMs == null) {
      return null;
    } else {
      return BookYearlyStat(
        title: fastestReadBook,
        value: ReadingTime.fromMilliSeconds(fastestReadTimeInMs).toString(),
        year: year,
      );
    }
  }

  List<BookYearlyStat> _getShortestBook(List<Book> books) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final shortestBook = _getShortestBookInYear(books, null);

    if (shortestBook != null) {
      bookYearlyStats.add(shortestBook);
    }

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.rating != null) {
          final finishYear = book.finishDate!.year;

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

    return bookYearlyStats;
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

  List<BookYearlyStat> _getLongestBook(List<Book> books) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    final longestBook = _getLongestBookInYear(books, null);

    if (longestBook != null) {
      bookYearlyStats.add(longestBook);
    }

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.rating != null) {
          final finishYear = book.finishDate!.year;

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

    return bookYearlyStats;
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

  List<BookYearlyStat> _getAverageReadingTime(List<Book> books) {
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
        if ((book.finishDate != null) && book.rating != null) {
          final finishYear = book.finishDate!.year;

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

    return bookYearlyStats;
  }

  String _getAverageReadingTimeInYear(List<Book> books) {
    int readTimeInMilliSeconds = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.readingTime != null) {
        readTimeInMilliSeconds += book.readingTime!.milliSeconds;
        countedBooks += 1;
        continue;
      }
      if (book.startDate != null && book.finishDate != null) {
        final startDate = book.startDate!;
        final finishDate = book.finishDate!;
        final readTimeinDays = finishDate.difference(startDate).inDays +
            1; // should be at least 1 day
        final timeDifference =
            ReadingTime.toMilliSeconds(readTimeinDays, 0, 0).milliSeconds;

        readTimeInMilliSeconds += timeDifference;
        countedBooks += 1;
      }
    }

    if (readTimeInMilliSeconds == 0 || countedBooks == 0) {
      return '';
    } else {
      int avgTime = readTimeInMilliSeconds ~/ countedBooks;
      return ReadingTime.fromMilliSeconds(avgTime).toString();
    }
  }

  List<BookYearlyStat> _getAveragePages(List<Book> books) {
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
          final finishYear = book.finishDate!.year;

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

    return bookYearlyStats;
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

  List<BookYearlyStat> _getAverageRating(List<Book> books) {
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
          final finishYear = book.finishDate!.year;

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

    return bookYearlyStats;
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

  List<BookReadStat> _getFinishedPagesByMonth(
      List<Book> books, BookFormat? bookType) {
    List<BookReadStat> bookReadStats = List<BookReadStat>.empty(growable: true);

    bookReadStats.add(
      BookReadStat(values: _getPagesByMonth(books, bookType)),
    );

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInYear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null && book.pages != null) {
          final finishYear = book.finishDate!.year;

          if (finishYear == year) {
            booksInYear.add(book);
          }
        }
      }

      bookReadStats.add(
        BookReadStat(
          year: year,
          values: _getPagesByMonth(booksInYear, bookType),
        ),
      );
    }
    return bookReadStats;
  }

  List<int> _getPagesByMonth(List<Book> books, BookFormat? bookType) {
    List<int> finishedPagesByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (bookType != null && book.bookFormat != bookType) {
        continue;
      }

      if (book.finishDate != null && book.pages != null) {
        final finishMonth = book.finishDate!.month;

        finishedPagesByMonth[finishMonth - 1] += book.pages!;
      }
    }
    return finishedPagesByMonth;
  }

  List<BookReadStat> _getFinishedBooksByMonth(
    List<Book> books,
    BookFormat? bookType,
  ) {
    List<BookReadStat> bookReadStats = List<BookReadStat>.empty(growable: true);

    bookReadStats.add(
      BookReadStat(values: _getBooksByMonth(books, bookType)),
    );

    final booksWithYears = _getBooksWithFinishDate(books);
    final years = _calculateYears(booksWithYears);

    for (var year in years) {
      final booksInyear = List<Book>.empty(growable: true);
      for (Book book in books) {
        if (book.finishDate != null) {
          final finishYear = book.finishDate!.year;

          if (finishYear == year) {
            booksInyear.add(book);
          }
        }
      }

      bookReadStats.add(
        BookReadStat(
          year: year,
          values: _getBooksByMonth(booksInyear, bookType),
        ),
      );
    }

    return bookReadStats;
  }

  List<int> _getBooksByMonth(List<Book> books, BookFormat? bookType) {
    List<int> finishedBooksByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (bookType != null && book.bookFormat != bookType) {
        continue;
      }

      if (book.finishDate != null) {
        final finishMonth = book.finishDate!.month;

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

  List<Book> _filterFinishedBooks(List<Book> books, int status) {
    final filteredBooks = List<Book>.empty(growable: true);

    for (var book in books) {
      if (book.status == status) {
        filteredBooks.add(book);
      }
    }

    return filteredBooks;
  }

  List<int> _calculateYears(List<Book> books) {
    final years = List<int>.empty(growable: true);

    for (var book in books) {
      final year = book.finishDate!.year;

      if (!years.contains(year)) {
        years.add(year);
      }
    }

    years.sort((a, b) {
      return b.compareTo(a);
    });

    return years;
  }

  List<int> getYears(List<Book> books) {
    final bookWithYears = List<Book>.empty(growable: true);

    for (var book in books) {
      if (book.finishDate != null) {
        bookWithYears.add(book);
      }
    }

    return _calculateYears(bookWithYears);
  }
}
