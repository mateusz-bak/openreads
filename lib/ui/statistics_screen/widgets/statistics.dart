import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/stats_bloc/stats_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

import 'package:openreads/model/yearly_challenge.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: state.years.length + 1,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).backgroundColor,
              borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TabBar(
                    isScrollable: true,
                    tabs: _buildYearsTabBars(context, state.years),
                  ),
                ),
              ],
            ),
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
        l10n.all_years,
        style: TextStyle(
          fontFamily: context.read<ThemeBloc>().fontFamily,
        ),
      ),
    ));

    for (var year in years) {
      tabs.add(Tab(
        child: Text(
          '$year',
          style: TextStyle(
            fontFamily: context.read<ThemeBloc>().fontFamily,
          ),
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
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildBooksChallenge(context, state, null),
                _buildPagesChallenge(context, state, null),
                _buildAllBooksPieChart(context),
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
                      _buildBooksChallenge(context, state, year),
                      _buildPagesChallenge(context, state, year),
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

  BlocBuilder<dynamic, dynamic> _buildBooksChallenge(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, challengeState) {
        if (challengeState is SetChallengeState &&
            challengeState.yearlyChallenges != null) {
          if (state.finishedBooksByMonth.isEmpty) {
            return Center(
              child: Text(
                l10n.no_finished_books,
                style: TextStyle(
                  fontFamily: context.read<ThemeBloc>().fontFamily,
                ),
              ),
            );
          }

          final yearlyChallenges = List<YearlyChallenge>.empty(
            growable: true,
          );

          final jsons = challengeState.yearlyChallenges!.split('|||||');
          for (var json in jsons) {
            final decodedJson = jsonDecode(json);
            final yearlyChallenge = YearlyChallenge.fromJSON(decodedJson);
            yearlyChallenges.add(yearlyChallenge);
          }

          final selectedTarget = yearlyChallenges.where((element) {
            return (year == null)
                ? element.year == DateTime.now().year
                : element.year == year;
          });

          final selectedValue = state.finishedBooksByMonth.where((element) {
            return (year == null)
                ? element.year == DateTime.now().year
                : element.year == year;
          });

          final value = selectedValue.isNotEmpty
              ? selectedValue.first.values.reduce((a, b) => a + b)
              : 0;

          if (selectedTarget.isEmpty || selectedTarget.first.books == null) {
            return (year == null)
                ? SetChallengeBox(
                    setChallenge: setChallenge,
                    year: year ?? DateTime.now().year,
                  )
                : const SizedBox();
          } else {
            return ReadingChallenge(
              title: l10n.books_challenge,
              value: value,
              target: selectedTarget.first.books ?? 0,
              setChallenge: setChallenge,
              booksTarget: selectedTarget.first.books,
              pagesTarget: selectedTarget.first.pages,
              year: year ?? DateTime.now().year,
            );
          }
        } else {
          return (year == null)
              ? SetChallengeBox(
                  setChallenge: setChallenge,
                  year: year ?? DateTime.now().year,
                )
              : const SizedBox();
        }
      },
    );
  }

  BlocBuilder<dynamic, dynamic> _buildPagesChallenge(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, challengeState) {
        if (challengeState is SetChallengeState &&
            challengeState.yearlyChallenges != null) {
          if (state.finishedPagesByMonth.isEmpty) {
            return Center(
              child: Text(
                l10n.no_finished_books,
                style: TextStyle(
                  fontFamily: context.read<ThemeBloc>().fontFamily,
                ),
              ),
            );
          }

          final yearlyChallenges = List<YearlyChallenge>.empty(
            growable: true,
          );

          final jsons = challengeState.yearlyChallenges!.split('|||||');
          for (var json in jsons) {
            final decodedJson = jsonDecode(json);
            final yearlyChallenge = YearlyChallenge.fromJSON(decodedJson);
            yearlyChallenges.add(yearlyChallenge);
          }

          final selectedTarget = yearlyChallenges.where((element) {
            return (year == null)
                ? element.year == DateTime.now().year
                : element.year == year;
          });

          final selectedValue = state.finishedPagesByMonth.where((element) {
            return (year == null)
                ? element.year == DateTime.now().year
                : element.year == year;
          });

          final value = selectedValue.isNotEmpty
              ? selectedValue.first.values.reduce((a, b) => a + b)
              : 0;

          if (selectedTarget.isEmpty) {
            return const SizedBox();
          } else if (selectedTarget.first.pages == null) {
            return const SizedBox();
          } else {
            return ReadingChallenge(
              title: l10n.pages_challenge,
              value: value,
              target: selectedTarget.first.pages ?? 0,
              setChallenge: setChallenge,
              booksTarget: selectedTarget.first.books,
              pagesTarget: selectedTarget.first.pages,
              year: year ?? DateTime.now().year,
            );
          }
        } else {
          return (year == null)
              ? SetChallengeBox(
                  setChallenge: setChallenge,
                  year: year ?? DateTime.now().year,
                )
              : const SizedBox();
        }
      },
    );
  }

  Widget _buildAllBooksPieChart(BuildContext context) {
    return BooksByStatus(
      title: l10n.all_books_by_status,
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
    for (var bookReadStat in state.finishedBooksByMonth) {
      if (bookReadStat.year == year) {
        return ReadStatsByMonth(
          title: l10n.finished_books_by_month,
          list: bookReadStat.values,
          theme: Theme.of(context),
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildFinishedPagesByMonth(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookReadStat in state.finishedPagesByMonth) {
      if (bookReadStat.year == year) {
        return ReadStatsByMonth(
          title: l10n.finished_pages_by_month,
          list: bookReadStat.values,
          theme: Theme.of(context),
        );
      }
    }

    return const SizedBox();
  }

  Widget _buildNumberOfFinishedBooks(
    BuildContext context,
    StatsLoaded state,
    int? year,
  ) {
    for (var bookReadStat in state.finishedBooksByMonth) {
      if (bookReadStat.year == year) {
        return ReadStats(
          title: l10n.finished_books,
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
    for (var bookReadStat in state.finishedPagesByMonth) {
      if (bookReadStat.year == year) {
        return ReadStats(
          title: l10n.finished_pages,
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
          title: l10n.average_rating,
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
          title: l10n.average_pages,
          value: (bookYearlyStat.value != '')
              ? '${bookYearlyStat.value} ${l10n.pages_lowercase}'
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
          title: l10n.average_reading_time,
          value: (bookYearlyStat.value != '')
              ? '${bookYearlyStat.value} ${l10n.days}'
              : '0',
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
          title: l10n.longest_book,
          value: bookYearlyStat.title.toString(),
          secondValue: '${bookYearlyStat.value} ${l10n.pages_lowercase}',
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
          title: l10n.shortest_book,
          value: bookYearlyStat.title.toString(),
          secondValue: (bookYearlyStat.value != '')
              ? '${bookYearlyStat.value} ${l10n.pages_lowercase}'
              : '',
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
          title: l10n.fastest_book,
          value: bookYearlyStat.title.toString(),
          secondValue: '${bookYearlyStat.value} ${l10n.days}',
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
          title: l10n.slowest_book,
          value: bookYearlyStat.title.toString(),
          secondValue: '${bookYearlyStat.value} ${l10n.days}',
        );
      }
    }

    return const SizedBox();
  }
}
