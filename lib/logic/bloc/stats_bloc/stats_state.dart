part of 'stats_bloc.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object> get props => [];
}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final List<int> years;
  final List<Book> finishedBooks;
  final List<Book> inProgressBooks;
  final List<Book> forLaterBooks;
  final List<Book> unfinishedBooks;
  final List<BookReadStat> finishedBooksByMonthAllTypes;
  final List<BookReadStat> finishedBooksByMonthPaperbackBooks;
  final List<BookReadStat> finishedBooksByMonthHardcoverBooks;
  final List<BookReadStat> finishedBooksByMonthEbooks;
  final List<BookReadStat> finishedBooksByMonthAudiobooks;
  final List<BookReadStat> finishedPagesByMonthAllTypes;
  final List<BookReadStat> finishedPagesByMonthPaperbackBooks;
  final List<BookReadStat> finishedPagesByMonthHardcoverBooks;
  final List<BookReadStat> finishedPagesByMonthEbooks;
  final List<BookReadStat> finishedPagesByMonthAudiobooks;
  final int finishedBooksAll;
  final int finishedPagesAll;
  final List<BookYearlyStat> averageRating;
  final List<BookYearlyStat> averagePages;
  final List<BookYearlyStat> averageReadingTime;
  final List<BookYearlyStat> longestBook;
  final List<BookYearlyStat> shortestBook;
  final List<BookYearlyStat> fastestBook;
  final List<BookYearlyStat> slowestBook;

  const StatsLoaded({
    required this.years,
    required this.finishedBooks,
    required this.inProgressBooks,
    required this.forLaterBooks,
    required this.unfinishedBooks,
    required this.finishedBooksByMonthAllTypes,
    required this.finishedBooksByMonthPaperbackBooks,
    required this.finishedBooksByMonthHardcoverBooks,
    required this.finishedBooksByMonthEbooks,
    required this.finishedBooksByMonthAudiobooks,
    required this.finishedPagesByMonthAllTypes,
    required this.finishedPagesByMonthPaperbackBooks,
    required this.finishedPagesByMonthHardcoverBooks,
    required this.finishedPagesByMonthEbooks,
    required this.finishedPagesByMonthAudiobooks,
    required this.finishedBooksAll,
    required this.finishedPagesAll,
    required this.averageRating,
    required this.averagePages,
    required this.averageReadingTime,
    required this.longestBook,
    required this.shortestBook,
    required this.fastestBook,
    required this.slowestBook,
  });

  @override
  List<Object> get props => [
        years,
        finishedBooks,
        inProgressBooks,
        forLaterBooks,
        unfinishedBooks,
        finishedBooksByMonthAllTypes,
        finishedBooksByMonthPaperbackBooks,
        finishedBooksByMonthHardcoverBooks,
        finishedBooksByMonthEbooks,
        finishedBooksByMonthAudiobooks,
        finishedPagesByMonthAllTypes,
        finishedPagesByMonthPaperbackBooks,
        finishedPagesByMonthHardcoverBooks,
        finishedPagesByMonthEbooks,
        finishedPagesByMonthAudiobooks,
        finishedBooksAll,
        finishedPagesAll,
        averageRating,
        averagePages,
        averageReadingTime,
        longestBook,
        shortestBook,
        fastestBook,
        slowestBook,
      ];
}

class StatsError extends StatsState {
  final String msg;

  const StatsError(
    this.msg,
  );

  @override
  List<Object> get props => [msg];
}
