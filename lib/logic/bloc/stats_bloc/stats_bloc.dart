import 'package:easy_localization/easy_localization.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
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
      final finishedBooks = _filterBooksByStatus(allBooks, BookStatus.read);

      if (finishedBooks.isEmpty) {
        emit(StatsError(LocaleKeys.add_books_and_come_back.tr()));
        return;
      }

      final years = _calculateYears(finishedBooks);

      final inProgressBooks = _filterBooksByStatus(
        allBooks,
        BookStatus.inProgress,
      );
      final forLaterBooks = _filterBooksByStatus(
        allBooks,
        BookStatus.forLater,
      );
      final unfinishedBooks = _filterBooksByStatus(
        allBooks,
        BookStatus.unfinished,
      );

      final finishedBooksByMonthAllTypes =
          _getFinishedBooksByMonth(finishedBooks, null, years);
      final finishedBooksByMonthPaperbackBooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.paperback, years);
      final finishedBooksByMonthHardcoverBooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.hardcover, years);
      final finishedBooksByMonthEbooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.ebook, years);
      final finishedBooksByMonthAudiobooks =
          _getFinishedBooksByMonth(finishedBooks, BookFormat.audiobook, years);

      final finishedPagesByMonthAllTypes =
          _getFinishedPagesByMonth(finishedBooks, null, years);
      final finishedPagesByMonthPaperbackBooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.paperback, years);
      final finishedPagesByMonthHardcoverBooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.hardcover, years);
      final finishedPagesByMonthEbooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.ebook, years);
      final finishedPagesByMonthAudiobooks =
          _getFinishedPagesByMonth(finishedBooks, BookFormat.audiobook, years);

      final averageRating = _getAverageRating(finishedBooks, years);
      final averagePages = _getAveragePages(finishedBooks, years);
      final averageReadingTime = _getAverageReadingTime(finishedBooks, years);
      final longestBook = _getLongestBook(finishedBooks, years);
      final shortestBook = _getShortestBook(finishedBooks, years);
      final fastestBook = _getFastestReadBook(finishedBooks, years);
      final slowestBook = _getSlowestReadBooks(finishedBooks, years);
      final allFinishedBooks = _countFinishedBooks(finishedBooks);
      final allFinishedPages = _countFinishedPages(finishedBooks);

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
        finishedBooksAll: allFinishedBooks,
        finishedPagesAll: allFinishedPages,
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

  List<BookYearlyStat> _getSlowestReadBooks(List<Book> books, List<int> years) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    // Calculate stats for all time
    final slowestBook = _getSlowestReadBookInYear(books, null);
    if (slowestBook != null) {
      bookYearlyStats.add(slowestBook);
    }

    // Calculate stats for each year
    for (var year in years) {
      final slowestBookInAYear = _getSlowestReadBookInYear(books, year);

      if (slowestBookInAYear != null) {
        bookYearlyStats.add(slowestBookInAYear);
      }
    }
    return bookYearlyStats;
  }

  BookYearlyStat? _getSlowestReadBookInYear(List<Book> books, int? year) {
    int? slowestReadTimeInMs;
    String? slowestReadBookString;
    Book? slowestReadBook;

    for (Book book in books) {
      int? readTimeInMs;

      for (final reading in book.readings) {
        if (year != null && reading.finishDate?.year != year) {
          continue;
        }

        if (reading.customReadingTime != null) {
          readTimeInMs = reading.customReadingTime!.milliSeconds;
        } else if (reading.startDate != null && reading.finishDate != null) {
          // Reading duration should be at least 1 day
          final readTimeinDays =
              reading.finishDate!.difference(reading.startDate!).inDays + 1;

          readTimeInMs =
              ReadingTime.toMilliSeconds(readTimeinDays, 0, 0).milliSeconds;
        } else {
          continue;
        }

        if (slowestReadTimeInMs == null) {
          slowestReadTimeInMs = readTimeInMs;
          slowestReadBookString = '${book.title} - ${book.author}';
          slowestReadBook = book;
        } else {
          if (readTimeInMs > slowestReadTimeInMs) {
            slowestReadTimeInMs = readTimeInMs;
            slowestReadBookString = '${book.title} - ${book.author}';
            slowestReadBook = book;
          }
        }
      }
    }

    if (slowestReadTimeInMs == null) {
      return null;
    } else {
      return BookYearlyStat(
        title: slowestReadBookString,
        value: ReadingTime.fromMilliSeconds(slowestReadTimeInMs).toString(),
        year: year,
        book: slowestReadBook,
      );
    }
  }

  List<BookYearlyStat> _getFastestReadBook(List<Book> books, List<int> years) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    // Calculate stats for all time
    final fastestBook = _getFastestReadBookInYear(books, null);
    if (fastestBook != null) {
      bookYearlyStats.add(fastestBook);
    }

    // Calculate stats for each year
    for (var year in years) {
      final fastestBookInAYear = _getFastestReadBookInYear(books, year);

      if (fastestBookInAYear != null) {
        bookYearlyStats.add(fastestBookInAYear);
      }
    }

    return bookYearlyStats;
  }

  BookYearlyStat? _getFastestReadBookInYear(List<Book> books, int? year) {
    int? fastestReadTimeInMs;
    String? fastestReadBookString;
    Book? fastestReadBook;

    for (Book book in books) {
      int? readTimeInMs;

      for (final reading in book.readings) {
        if (year != null && reading.finishDate?.year != year) {
          continue;
        }

        if (reading.customReadingTime != null) {
          readTimeInMs = reading.customReadingTime!.milliSeconds;
        } else if (reading.startDate != null && reading.finishDate != null) {
          // Reading duration should be at least 1 day
          final readTimeinDays =
              reading.finishDate!.difference(reading.startDate!).inDays + 1;

          readTimeInMs =
              ReadingTime.toMilliSeconds(readTimeinDays, 0, 0).milliSeconds;
        } else {
          continue;
        }

        if (fastestReadTimeInMs == null) {
          fastestReadTimeInMs = readTimeInMs;
          fastestReadBookString = '${book.title} - ${book.author}';
          fastestReadBook = book;
        } else {
          if (readTimeInMs < fastestReadTimeInMs) {
            fastestReadTimeInMs = readTimeInMs;
            fastestReadBookString = '${book.title} - ${book.author}';
            fastestReadBook = book;
          }
        }
      }
    }

    if (fastestReadTimeInMs == null) {
      return null;
    } else {
      return BookYearlyStat(
        title: fastestReadBookString,
        value: ReadingTime.fromMilliSeconds(fastestReadTimeInMs).toString(),
        year: year,
        book: fastestReadBook,
      );
    }
  }

  List<BookYearlyStat> _getShortestBook(List<Book> books, List<int> years) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    // Calculate stats for all time
    final shortestBook = _getShortestBookInYear(books, null);
    if (shortestBook != null) {
      bookYearlyStats.add(shortestBook);
    }

    // Calculate stats for each year
    for (var year in years) {
      final shortestBookInAYear = _getShortestBookInYear(books, year);

      if (shortestBookInAYear != null) {
        bookYearlyStats.add(shortestBookInAYear);
      }
    }

    return bookYearlyStats;
  }

  BookYearlyStat? _getShortestBookInYear(List<Book> books, int? year) {
    int? shortestBookPages;
    String? shortestBookString;
    Book? shortestBook;

    for (Book book in books) {
      if (book.pages == null || book.pages! == 0) continue;

      if (book.readings.isEmpty) {
        if (shortestBookPages == null || book.pages! < shortestBookPages) {
          shortestBookPages = book.pages!;
          shortestBookString = '${book.title} - ${book.author}';
          shortestBook = book;
        }
      } else {
        for (final reading in book.readings) {
          if (year != null && reading.finishDate?.year != year) {
            continue;
          }

          if (shortestBookPages == null || book.pages! < shortestBookPages) {
            shortestBookPages = book.pages!;
            shortestBookString = '${book.title} - ${book.author}';
            shortestBook = book;
          }
        }
      }
    }

    if (shortestBookPages == null) {
      return null;
    } else {
      return BookYearlyStat(
        book: shortestBook,
        title: shortestBookString,
        value: shortestBookPages.toString(),
        year: year,
      );
    }
  }

  List<BookYearlyStat> _getLongestBook(List<Book> books, List<int> years) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    // Calculate stats for all time
    final longestBook = _getLongestBookInYear(books, null);
    if (longestBook != null) {
      bookYearlyStats.add(longestBook);
    }

    // Calculate stats for each year
    for (var year in years) {
      final longestBookInAYear = _getLongestBookInYear(books, year);

      if (longestBookInAYear != null) {
        bookYearlyStats.add(longestBookInAYear);
      }
    }

    return bookYearlyStats;
  }

  BookYearlyStat? _getLongestBookInYear(List<Book> books, int? year) {
    int? longestBookPages;
    String? longestBookString;
    Book? longestBook;

    for (Book book in books) {
      if (book.pages == null || book.pages! == 0) continue;

      if (book.readings.isEmpty) {
        if (longestBookPages == null || book.pages! > longestBookPages) {
          longestBookPages = book.pages!;
          longestBookString = '${book.title} - ${book.author}';
          longestBook = book;
        }
      } else {
        for (final reading in book.readings) {
          if (year != null && reading.finishDate?.year != year) {
            continue;
          }

          if (longestBookPages == null || book.pages! > longestBookPages) {
            longestBookPages = book.pages!;
            longestBookString = '${book.title} - ${book.author}';
            longestBook = book;
          }
        }
      }
    }

    if (longestBookPages == null) {
      return null;
    } else {
      return BookYearlyStat(
        book: longestBook,
        title: longestBookString,
        value: longestBookPages.toString(),
        year: year,
      );
    }
  }

  List<BookYearlyStat> _getAverageReadingTime(
    List<Book> books,
    List<int> years,
  ) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    // Calculate stats for all time
    bookYearlyStats.add(
      BookYearlyStat(value: _getAverageReadingTimeInYear(books, null)),
    );

    // Calculate stats for each year
    for (var year in years) {
      final averageReadingTimeInAYear = _getAverageReadingTimeInYear(
        books,
        year,
      );

      bookYearlyStats.add(
        BookYearlyStat(
          year: year,
          value: averageReadingTimeInAYear,
        ),
      );
    }

    return bookYearlyStats;
  }

  String _getAverageReadingTimeInYear(List<Book> books, int? year) {
    int readTimeInMilliSeconds = 0;
    int countedBooks = 0;

    for (Book book in books) {
      for (final reading in book.readings) {
        if (year != null && reading.finishDate?.year != year) {
          continue;
        }

        if (reading.customReadingTime != null) {
          readTimeInMilliSeconds += reading.customReadingTime!.milliSeconds;
          countedBooks += 1;
        } else if (reading.startDate != null && reading.finishDate != null) {
          // Reading duration should be at least 1 day
          final readTimeinDays =
              reading.finishDate!.difference(reading.startDate!).inDays + 1;

          final timeDifference =
              ReadingTime.toMilliSeconds(readTimeinDays, 0, 0).milliSeconds;

          readTimeInMilliSeconds += timeDifference;
          countedBooks += 1;
        }
      }
    }

    if (readTimeInMilliSeconds == 0 || countedBooks == 0) {
      return '';
    } else {
      int avgTime = readTimeInMilliSeconds ~/ countedBooks;
      return ReadingTime.fromMilliSeconds(avgTime).toString();
    }
  }

  List<BookYearlyStat> _getAveragePages(List<Book> books, List<int> years) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    // Calculate stats for all time
    bookYearlyStats.add(
      BookYearlyStat(value: _getAveragePagesInYear(books, null)),
    );

    // Calculate stats for each year
    for (var year in years) {
      bookYearlyStats.add(
        BookYearlyStat(
          year: year,
          value: _getAveragePagesInYear(books, year),
        ),
      );
    }

    return bookYearlyStats;
  }

  String _getAveragePagesInYear(List<Book> books, int? year) {
    int finishedPages = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.pages == null) continue;

      if (book.readings.isEmpty) {
        finishedPages += book.pages!;
        countedBooks += 1;
      } else {
        for (final reading in book.readings) {
          if (year != null && reading.finishDate?.year != year) {
            continue;
          }

          finishedPages += book.pages!;
          countedBooks += 1;
        }
      }
    }

    if (countedBooks == 0) {
      return '0';
    } else {
      return (finishedPages / countedBooks).toStringAsFixed(0);
    }
  }

  List<BookYearlyStat> _getAverageRating(List<Book> books, List<int> years) {
    List<BookYearlyStat> bookYearlyStats = List<BookYearlyStat>.empty(
      growable: true,
    );

    // Calculate stats for all time
    bookYearlyStats.add(
      BookYearlyStat(value: _getAverageRatingInYear(books, null)),
    );

    // Calculate stats for each year
    for (var year in years) {
      bookYearlyStats.add(
        BookYearlyStat(
          year: year,
          value: _getAverageRatingInYear(books, year),
        ),
      );
    }

    return bookYearlyStats;
  }

  String _getAverageRatingInYear(List<Book> books, int? year) {
    double sumRating = 0;
    int countedBooks = 0;

    for (Book book in books) {
      if (book.rating == null) continue;

      if (year == null && book.readings.isEmpty) {
        sumRating += book.rating! / 10;
        countedBooks += 1;
      } else {
        for (final reading in book.readings) {
          if (year != null && reading.finishDate?.year != year) {
            continue;
          }

          sumRating += book.rating! / 10;
          countedBooks += 1;
        }
      }
    }

    if (countedBooks == 0) {
      return '0';
    } else {
      return (sumRating / countedBooks).toStringAsFixed(1);
    }
  }

  List<BookReadStat> _getFinishedPagesByMonth(
    List<Book> books,
    BookFormat? bookType,
    List<int> years,
  ) {
    List<BookReadStat> bookReadStats = List<BookReadStat>.empty(growable: true);

    // Calculate stats for all time
    bookReadStats.add(
      BookReadStat(
        values: _getFinishedPagesInSpecificMonths(books, bookType, null),
      ),
    );

    // Calculate stats for each year
    for (var year in years) {
      bookReadStats.add(
        BookReadStat(
          year: year,
          values: _getFinishedPagesInSpecificMonths(books, bookType, year),
        ),
      );
    }
    return bookReadStats;
  }

  List<int> _getFinishedPagesInSpecificMonths(
    List<Book> books,
    BookFormat? bookType,
    int? year,
  ) {
    List<int> finishedPagesByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (bookType != null && book.bookFormat != bookType) {
        continue;
      }

      for (final reading in book.readings) {
        if (reading.finishDate != null && book.pages != null) {
          if (year == null || reading.finishDate!.year == year) {
            final finishMonth = reading.finishDate!.month;

            finishedPagesByMonth[finishMonth - 1] += book.pages!;
          }
        }
      }
    }

    return finishedPagesByMonth;
  }

  List<BookReadStat> _getFinishedBooksByMonth(
    List<Book> books,
    BookFormat? bookType,
    List<int> years,
  ) {
    List<BookReadStat> bookReadStats = List<BookReadStat>.empty(growable: true);

    // Calculate stats for all time
    bookReadStats.add(
      BookReadStat(
        values: _getFinishedBooksInSpecificMonths(books, bookType, null),
      ),
    );

    // Calculate stats for each year
    for (var year in years) {
      bookReadStats.add(
        BookReadStat(
          year: year,
          values: _getFinishedBooksInSpecificMonths(
            books,
            bookType,
            year,
          ),
        ),
      );
    }

    return bookReadStats;
  }

  List<int> _getFinishedBooksInSpecificMonths(
    List<Book> books,
    BookFormat? bookType,
    int? year,
  ) {
    List<int> finishedBooksByMonth = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    for (Book book in books) {
      if (bookType != null && book.bookFormat != bookType) {
        continue;
      }

      for (final reading in book.readings) {
        if (reading.finishDate != null) {
          if (year == null || reading.finishDate!.year == year) {
            final finishMonth = reading.finishDate!.month;

            finishedBooksByMonth[finishMonth - 1] += 1;
          }
        }
      }
    }

    return finishedBooksByMonth;
  }

  List<Book> _filterBooksByStatus(List<Book> books, BookStatus status) {
    final filteredBooks = List<Book>.empty(growable: true);

    for (var book in books) {
      if (book.status == status) {
        filteredBooks.add(book);
      }
    }

    return filteredBooks;
  }

  int _countFinishedBooks(List<Book> books) {
    int finishedBooks = 0;

    for (var book in books) {
      if (book.readings.isEmpty) {
        finishedBooks += 1;
      } else {
        for (final reading in book.readings) {
          if (reading.finishDate != null) {
            finishedBooks += 1;
          }
        }
      }
    }

    return finishedBooks;
  }

  int _countFinishedPages(List<Book> books) {
    int finishedPages = 0;

    for (var book in books) {
      if (book.pages != null) {
        if (book.readings.isEmpty) {
          finishedPages += book.pages!;
        } else {
          for (final reading in book.readings) {
            if (reading.finishDate != null) {
              finishedPages += book.pages!;
            }
          }
        }
      }
    }

    return finishedPages;
  }

  List<int> _calculateYears(List<Book> books) {
    final years = List<int>.empty(growable: true);

    for (var book in books) {
      for (final reading in book.readings) {
        if (reading.finishDate != null) {
          final year = reading.finishDate!.year;

          if (!years.contains(year)) {
            years.add(year);
          }
        }
      }
    }

    // Sorting years in descending order
    years.sort((a, b) {
      return b.compareTo(a);
    });

    return years;
  }
}
