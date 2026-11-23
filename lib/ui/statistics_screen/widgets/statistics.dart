import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/stats_bloc/stats_bloc.dart';

import 'package:openreads/model/book_read_stat.dart';
import 'package:openreads/model/yearly_challenge.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';
import 'package:openreads/ui/year_summary_screen/year_summary_screen.dart';

class Statistics extends StatelessWidget {
  final StatsLoaded state;
  final Function(
    int books,
    int pages,
    int year,
  ) setChallenge;

  const Statistics({
    super.key,
    required this.state,
    required this.setChallenge,
  });

  List<YearlyChallenge> _parseYearlyChallenges(String yearlyChallenges) {
    final challenges = List<YearlyChallenge>.empty(
      growable: true,
    );

    final jsons = yearlyChallenges.split('|||||');
    for (var json in jsons) {
      final decodedJson = jsonDecode(json);
      final yearlyChallenge = YearlyChallenge.fromJSON(decodedJson);
      challenges.add(yearlyChallenge);
    }

    return challenges;
  }

  void _openYearSummary(BuildContext context, int year) {
    YearlyChallenge? challenge;
    final challengeState = context.read<ChallengeBloc>().state;
    if (challengeState is SetChallengeState &&
        challengeState.yearlyChallenges != null) {
      final yearlyChallenges = _parseYearlyChallenges(
        challengeState.yearlyChallenges!,
      );
      // same entry as in the challenge cards
      for (var yearlyChallenge in yearlyChallenges) {
        if (yearlyChallenge.year == year) {
          challenge = yearlyChallenge;
          break;
        }
      }
    }

    int sumForYear(List<BookReadStat> stats) {
      final statsForYear = stats.where((element) => element.year == year);

      return statsForYear.isNotEmpty
          ? statsForYear.first.values.reduce((a, b) => a + b)
          : 0;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => YearSummaryScreen(
          year: year,
          books: state.finishedBooks,
          finishedBooks: sumForYear(state.finishedBooksByMonthAllTypes),
          finishedPages: sumForYear(state.finishedPagesByMonthAllTypes),
          booksTarget: challenge?.books,
          pagesTarget: challenge?.pages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: state.years.length + 1,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TabBar(
                  tabAlignment: TabAlignment.start,
                  isScrollable: true,
                  tabs: _buildYearsTabBars(context, state.years),
                ),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: _buildYearsTabBarViews(context, state),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildYearsTabBars(BuildContext context, List<int> years) {
    final tabs = List<Widget>.empty(growable: true);

    tabs.add(Tab(
      child: Text(
        LocaleKeys.all_years.tr(),
      ),
    ));

    for (var year in years) {
      tabs.add(Tab(
        child: Text(
          '$year',
        ),
      ));
    }

    return tabs;
  }

  List<Widget> _buildYearsTabBarViews(
    BuildContext context,
    StatsLoaded state,
  ) {
    final tabs = List<Widget>.empty(growable: true);

    tabs.add(
      Tab(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildReadingGoal(context, state, null),
                _buildAllBooksStat(context),
                _buildFinishedBooksByMonth(context, state, null),
                _buildFinishedPagesByMonth(context, state, null),
                _buildNumberOfFinishedBooks(context, state, null),
                _buildNumberOfFinishedPages(context, state, null),
                _buildAverageRating(context, state, null),
                _buildAveragePages(context, state, null),
                _buildAverageReadingTime(context, state, null),
                _buildLongestBook(context, state, null),
                _buildShortestBook(context, state, null),
                _buildFastestRead(context, state, null),
                _buildSlowestRead(context, state, null),
                const SizedBox(height: 100)
              ],
            ),
          ),
        ),
      ),
    );

    for (var year in state.years) {
      tabs.add(Tab(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      _buildReadingGoal(context, state, year),
                      _buildFinishedBooksByMonth(context, state, year),
                      _buildFinishedPagesByMonth(context, state, year),
                      _buildNumberOfFinishedBooks(context, state, year),
                      _buildNumberOfFinishedPages(context, state, year),
                      _buildAverageRating(context, state, year),
                      _buildAveragePages(context, state, year),
                      _buildAverageReadingTime(context, state, year),
                      _buildLongestBook(context, state, year),
                      _buildShortestBook(context, state, year),
                      _buildFastestRead(context, state, year),
                      _buildSlowestRead(context, state, year),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ));
    }

    return tabs;
  }

  Widget _buildReadingGoal(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    final currentYear = DateTime.now().year;
    final goalYear = year ?? currentYear;

    int sumForYear(List<BookReadStat> stats) {
      final statsForYear = stats.where((element) => element.year == goalYear);

      return statsForYear.isNotEmpty
          ? statsForYear.first.values.reduce((a, b) => a + b)
          : 0;
    }

    final onSharePressed = state.years.contains(goalYear)
        ? () => _openYearSummary(context, goalYear)
        : null;

    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, challengeState) {
        YearlyChallenge? challenge;
        if (challengeState is SetChallengeState &&
            challengeState.yearlyChallenges != null) {
          final yearlyChallenges = _parseYearlyChallenges(
            challengeState.yearlyChallenges!,
          );

          for (var yearlyChallenge in yearlyChallenges) {
            if (yearlyChallenge.year == goalYear) {
              challenge = yearlyChallenge;
              break;
            }
          }
        }

        // targets of 0 can come from old backups and mean no goal
        final booksTarget =
            (challenge?.books ?? 0) > 0 ? challenge!.books : null;
        final pagesTarget =
            (challenge?.pages ?? 0) > 0 ? challenge!.pages : null;
        final hasGoal = booksTarget != null || pagesTarget != null;

        final card = ReadingGoalCard(
          // keeps the editor state separate for every year tab
          key: ValueKey('reading_goal_$goalYear'),
          year: goalYear,
          booksValue: sumForYear(state.finishedBooksByMonthAllTypes),
          pagesValue: sumForYear(state.finishedPagesByMonthAllTypes),
          booksTarget: booksTarget,
          pagesTarget: pagesTarget,
          setChallenge: setChallenge,
          onSharePressed: onSharePressed,
          isCompact: !hasGoal && goalYear < currentYear,
        );

        // past years without a goal only get a small button to set it
        if (!hasGoal && goalYear < currentYear) {
          return Column(
            children: [
              if (onSharePressed != null)
                ShareYearBox(onPressed: onSharePressed),
              card,
            ],
          );
        }

        return card;
      },
    );
  }

  Widget _buildAllBooksStat(BuildContext context) {
    return BooksByStatus(
      title: LocaleKeys.all_books_by_status.tr(),
      list: [
        state.finishedBooks.length,
        state.inProgressBooks.length,
        state.forLaterBooks.length,
        state.unfinishedBooks.length,
      ],
    );
  }

  Widget _buildFinishedBooksByMonth(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    final emptyList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    List<int> finishedBooksByMonthPaperbackBooks = emptyList;
    List<int> finishedBooksByMonthHardcoverBooks = emptyList;
    List<int> finishedBooksByMonthEbooks = emptyList;
    List<int> finishedBooksByMonthAudiobooks = emptyList;

    for (var bookReadStat in state.finishedBooksByMonthPaperbackBooks) {
      if (bookReadStat.year == year) {
        finishedBooksByMonthPaperbackBooks = bookReadStat.values;
      }
    }

    for (var bookReadStat in state.finishedBooksByMonthHardcoverBooks) {
      if (bookReadStat.year == year) {
        finishedBooksByMonthHardcoverBooks = bookReadStat.values;
      }
    }

    for (var bookReadStat in state.finishedBooksByMonthEbooks) {
      if (bookReadStat.year == year) {
        finishedBooksByMonthEbooks = bookReadStat.values;
      }
    }

    for (var bookReadStat in state.finishedBooksByMonthAudiobooks) {
      if (bookReadStat.year == year) {
        finishedBooksByMonthAudiobooks = bookReadStat.values;
      }
    }

    if (state.finishedBooksByMonthAllTypes.isEmpty) {
      return const SizedBox();
    }

    return ReadStatsByMonth(
      title: LocaleKeys.finished_books_by_month.tr(),
      listPaperbackBooks: finishedBooksByMonthPaperbackBooks,
      listHardcoverBooks: finishedBooksByMonthHardcoverBooks,
      listEbooks: finishedBooksByMonthEbooks,
      listAudiobooks: finishedBooksByMonthAudiobooks,
      theme: Theme.of(context),
    );
  }

  Widget _buildFinishedPagesByMonth(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    final emptyList = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    List<int> finishedPagesByMonthPaperbackBooks = emptyList;
    List<int> finishedPagesByMonthHardcoverBooks = emptyList;
    List<int> finishedPagesByMonthEbooks = emptyList;
    List<int> finishedPagesByMonthAudiobooks = emptyList;

    for (var bookReadStat in state.finishedPagesByMonthPaperbackBooks) {
      if (bookReadStat.year == year) {
        finishedPagesByMonthPaperbackBooks = bookReadStat.values;
      }
    }
    for (var bookReadStat in state.finishedPagesByMonthHardcoverBooks) {
      if (bookReadStat.year == year) {
        finishedPagesByMonthHardcoverBooks = bookReadStat.values;
      }
    }
    for (var bookReadStat in state.finishedPagesByMonthEbooks) {
      if (bookReadStat.year == year) {
        finishedPagesByMonthEbooks = bookReadStat.values;
      }
    }
    for (var bookReadStat in state.finishedPagesByMonthAudiobooks) {
      if (bookReadStat.year == year) {
        finishedPagesByMonthAudiobooks = bookReadStat.values;
      }
    }

    if (state.finishedPagesByMonthAllTypes.isEmpty) {
      return const SizedBox();
    }

    return ReadStatsByMonth(
      title: LocaleKeys.finished_pages_by_month.tr(),
      listPaperbackBooks: finishedPagesByMonthPaperbackBooks,
      listHardcoverBooks: finishedPagesByMonthHardcoverBooks,
      listEbooks: finishedPagesByMonthEbooks,
      listAudiobooks: finishedPagesByMonthAudiobooks,
      theme: Theme.of(context),
    );
  }

  Widget _buildNumberOfFinishedBooks(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    if (year == null) {
      return ReadStats(
        title: LocaleKeys.finished_books.tr(),
        value: state.finishedBooksAll.toString(),
      );
    }

    for (var bookReadStat in state.finishedBooksByMonthAllTypes) {
      if (bookReadStat.year == year) {
        return ReadStats(
          title: LocaleKeys.finished_books.tr(),
          value: bookReadStat.values.reduce((a, b) => a + b).toString(),
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildNumberOfFinishedPages(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    if (year == null) {
      return ReadStats(
        title: LocaleKeys.finished_pages.tr(),
        value: state.finishedPagesAll.toString(),
      );
    }

    for (var bookReadStat in state.finishedPagesByMonthAllTypes) {
      if (bookReadStat.year == year) {
        return ReadStats(
          title: LocaleKeys.finished_pages.tr(),
          value: bookReadStat.values.reduce((a, b) => a + b).toString(),
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildAverageRating(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookYearlyStat in state.averageRating) {
      if (bookYearlyStat.year == year) {
        return ReadStats(
          title: LocaleKeys.average_rating.tr(),
          value: bookYearlyStat.value,
          iconData: Icons.star_rounded,
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildAveragePages(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookYearlyStat in state.averagePages) {
      if (bookYearlyStat.year == year) {
        return ReadStats(
          title: LocaleKeys.average_pages.tr(),
          value: (bookYearlyStat.value != '')
              ? '${bookYearlyStat.value} ${LocaleKeys.pages_lowercase.tr()}'
              : '0',
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildAverageReadingTime(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookYearlyStat in state.averageReadingTime) {
      if (bookYearlyStat.year == year) {
        return ReadStats(
          title: LocaleKeys.average_reading_time.tr(),
          value: (bookYearlyStat.value != '') ? bookYearlyStat.value : '0',
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildLongestBook(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookYearlyStat in state.longestBook) {
      if (bookYearlyStat.year == year) {
        return ReadStats(
          title: LocaleKeys.longest_book.tr(),
          value: bookYearlyStat.title.toString(),
          secondValue:
              '${bookYearlyStat.value} ${LocaleKeys.pages_lowercase.tr()}',
          book: bookYearlyStat.book,
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildShortestBook(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookYearlyStat in state.shortestBook) {
      if (bookYearlyStat.year == year) {
        return ReadStats(
          title: LocaleKeys.shortest_book.tr(),
          value: bookYearlyStat.title.toString(),
          secondValue: (bookYearlyStat.value != '')
              ? '${bookYearlyStat.value} ${LocaleKeys.pages_lowercase.tr()}'
              : '',
          book: bookYearlyStat.book,
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildFastestRead(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookYearlyStat in state.fastestBook) {
      if (bookYearlyStat.year == year) {
        return ReadStats(
          title: LocaleKeys.fastest_book.tr(),
          value: bookYearlyStat.title.toString(),
          secondValue: bookYearlyStat.value,
          book: bookYearlyStat.book,
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildSlowestRead(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookYearlyStat in state.slowestBook) {
      if (bookYearlyStat.year == year) {
        return ReadStats(
          title: LocaleKeys.slowest_book.tr(),
          value: bookYearlyStat.title.toString(),
          secondValue: bookYearlyStat.value,
          book: bookYearlyStat.book,
        );
      }
    }

    return const SizedBox();
  }
}
