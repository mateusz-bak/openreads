import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/logic/cubit/stats_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/model/book_read_stat.dart';
import 'package:openreads/model/book_yearly_stat.dart';
import 'package:openreads/model/yearly_challenge.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  void _setChallenge(int books, int pages, int year) {
    BlocProvider.of<ChallengeBloc>(context).add(
      ChangeChallengeEvent(
        books: (books == 0) ? null : books,
        pages: (pages == 0) ? null : pages,
        year: year,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<StatsCubit>(
      create: (context) => StatsCubit(),
      child: Builder(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Theme.of(context).scaffoldBackgroundColor,
            title: const Text('Statistics'),
          ),
          body: StreamBuilder<List<Book>>(
            stream: bookCubit.allBooks,
            builder: (context, AsyncSnapshot<List<Book>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(50),
                      child: Text(
                        'Add some books and come here again',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, letterSpacing: 1.5),
                      ),
                    ),
                  );
                }
                return _buildStatistics(context);
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: Text(
                      'Add some books and come here again',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, letterSpacing: 1.5),
                    ),
                  ),
                );
              }
            },
          ),
        );
      }),
    );
  }

  Widget _buildStatistics(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: BlocProvider.of<StatsCubit>(context).years,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No books with finish date'));
          }
          return _buildDefaultTabController(
            context: context,
            years: snapshot.data!,
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  List<Widget> _buildYearsTabBars(List<int> years) {
    final tabs = List<Widget>.empty(growable: true);

    tabs.add(const Tab(
      child: Text('All'),
    ));

    for (var year in years) {
      tabs.add(Tab(
        child: Text('$year'),
      ));
    }

    return tabs;
  }

  List<Widget> _buildYearsTabBarViews(BuildContext context, List<int> years) {
    final tabs = List<Widget>.empty(growable: true);

    tabs.add(Tab(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildBooksChallenge(context, null),
              _buildPagesChallenge(context, null),
              _buildAllBooksPieChart(context),
              _buildFinishedBooksByMonth(context, null),
              _buildFinishedPagesByMonth(context, null),
              _buildNumberOfFinishedBooks(context, null),
              _buildNumberOfFinishedPages(context, null),
              _buildAverageRating(context, null),
              _buildAveragePages(context, null),
              _buildAverageReadingTime(context, null),
              _buildLongestBook(context, null),
              _buildShortestBook(context, null),
              _buildFastestRead(context, null),
              _buildSlowestRead(context, null),
            ],
          ),
        ),
      ),
    ));

    for (var year in years) {
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
                      _buildBooksChallenge(context, year),
                      _buildPagesChallenge(context, year),
                      _buildFinishedBooksByMonth(context, year),
                      _buildFinishedPagesByMonth(context, year),
                      _buildNumberOfFinishedBooks(context, year),
                      _buildNumberOfFinishedPages(context, year),
                      _buildAverageRating(context, year),
                      _buildAveragePages(context, year),
                      _buildAverageReadingTime(context, year),
                      _buildLongestBook(context, year),
                      _buildShortestBook(context, year),
                      _buildFastestRead(context, year),
                      _buildSlowestRead(context, year),
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

  DefaultTabController _buildDefaultTabController({
    required BuildContext context,
    required List<int> years,
  }) {
    return DefaultTabController(
      length: years.length + 1,
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
                    padding: const EdgeInsets.symmetric(horizontal: 13),
                    labelColor: Theme.of(context).mainTextColor,
                    indicatorColor: Theme.of(context).primaryColor,
                    unselectedLabelColor: Theme.of(context).primaryColor,
                    indicator: BoxDecoration(
                      borderRadius:
                          Theme.of(context).extension<CustomBorder>()?.radius,
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    tabs: _buildYearsTabBars(years),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: _buildYearsTabBarViews(context, years),
            ),
          ),
        ],
      ),
    );
  }

  StreamBuilder<List<BookYearlyStat>?> _buildSlowestRead(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookYearlyStat>?>(
      stream: BlocProvider.of<StatsCubit>(context).slowest,
      builder: (context, AsyncSnapshot<List<BookYearlyStat>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookYearlyStat in snapshot.data!) {
            if (bookYearlyStat.year == year) {
              return ReadStats(
                title: 'Slowest read book',
                value: bookYearlyStat.title.toString(),
                secondValue: '${bookYearlyStat.value} days',
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookYearlyStat>?> _buildFastestRead(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookYearlyStat>?>(
      stream: BlocProvider.of<StatsCubit>(context).fastest,
      builder: (context, AsyncSnapshot<List<BookYearlyStat>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookYearlyStat in snapshot.data!) {
            if (bookYearlyStat.year == year) {
              return ReadStats(
                title: 'Fastest read book',
                value: bookYearlyStat.title.toString(),
                secondValue: '${bookYearlyStat.value} days',
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookYearlyStat>?> _buildShortestBook(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookYearlyStat>?>(
      stream: BlocProvider.of<StatsCubit>(context).shortest,
      builder: (context, AsyncSnapshot<List<BookYearlyStat>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookYearlyStat in snapshot.data!) {
            if (bookYearlyStat.year == year) {
              return ReadStats(
                title: 'Shortest book',
                value: bookYearlyStat.title.toString(),
                secondValue: (bookYearlyStat.value != '')
                    ? '${bookYearlyStat.value} pages'
                    : '',
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookYearlyStat>?> _buildLongestBook(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookYearlyStat>?>(
      stream: BlocProvider.of<StatsCubit>(context).longest,
      builder: (context, AsyncSnapshot<List<BookYearlyStat>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookYearlyStat in snapshot.data!) {
            if (bookYearlyStat.year == year) {
              return ReadStats(
                title: 'Longest book',
                value: bookYearlyStat.title.toString(),
                secondValue: '${bookYearlyStat.value} pages',
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookYearlyStat>?> _buildAverageReadingTime(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookYearlyStat>?>(
      stream: BlocProvider.of<StatsCubit>(context).avgReadingTime,
      builder: (context, AsyncSnapshot<List<BookYearlyStat>?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookYearlyStat in snapshot.data!) {
            if (bookYearlyStat.year == year) {
              return ReadStats(
                title: 'Average reading time',
                value: (bookYearlyStat.value != '')
                    ? '${bookYearlyStat.value} days'
                    : '0',
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookYearlyStat>> _buildAveragePages(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookYearlyStat>>(
      stream: BlocProvider.of<StatsCubit>(context).avgPages,
      builder: (context, AsyncSnapshot<List<BookYearlyStat>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookYearlyStat in snapshot.data!) {
            if (bookYearlyStat.year == year) {
              return ReadStats(
                title: 'Average number of pages',
                value: (bookYearlyStat.value != '')
                    ? '${bookYearlyStat.value} pages'
                    : '0',
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookYearlyStat>> _buildAverageRating(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookYearlyStat>>(
      stream: BlocProvider.of<StatsCubit>(context).avgRating,
      builder: (context, AsyncSnapshot<List<BookYearlyStat>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookYearlyStat in snapshot.data!) {
            if (bookYearlyStat.year == year) {
              return ReadStats(
                title: 'Average rating',
                value: bookYearlyStat.value,
                iconData: Icons.star_rounded,
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookReadStat>> _buildNumberOfFinishedPages(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookReadStat>>(
      stream: BlocProvider.of<StatsCubit>(context).finishedPagesByMonth,
      builder: (context, AsyncSnapshot<List<BookReadStat>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookReadStat in snapshot.data!) {
            if (bookReadStat.year == year) {
              return ReadStats(
                title: 'Finished pages',
                value: bookReadStat.values.reduce((a, b) => a + b).toString(),
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookReadStat>> _buildNumberOfFinishedBooks(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookReadStat>>(
      stream: BlocProvider.of<StatsCubit>(context).finishedBooksByMonth,
      builder: (context, AsyncSnapshot<List<BookReadStat>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookReadStat in snapshot.data!) {
            if (bookReadStat.year == year) {
              return ReadStats(
                title: 'Finished books',
                value: bookReadStat.values.reduce((a, b) => a + b).toString(),
              );
            }
          }

          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookReadStat>> _buildFinishedPagesByMonth(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookReadStat>>(
      stream: BlocProvider.of<StatsCubit>(context).finishedPagesByMonth,
      builder: (context, AsyncSnapshot<List<BookReadStat>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookReadStat in snapshot.data!) {
            if (bookReadStat.year == year) {
              return ReadStatsByMonth(
                title: 'Finished pages by month',
                list: bookReadStat.values,
                theme: Theme.of(context),
              );
            }
          }
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<BookReadStat>> _buildFinishedBooksByMonth(
    BuildContext context,
    int? year,
  ) {
    return StreamBuilder<List<BookReadStat>>(
      stream: BlocProvider.of<StatsCubit>(context).finishedBooksByMonth,
      builder: (context, AsyncSnapshot<List<BookReadStat>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No finished books'));
          }

          for (var bookReadStat in snapshot.data!) {
            if (bookReadStat.year == year) {
              return ReadStatsByMonth(
                title: 'Finished books by month',
                list: bookReadStat.values,
                theme: Theme.of(context),
              );
            }
          }
          return const SizedBox();
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const SizedBox();
        }
      },
    );
  }

  StreamBuilder<List<int>> _buildAllBooksPieChart(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: BlocProvider.of<StatsCubit>(context).allBooksByStatus,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const SizedBox();
          }

          return BooksByStatus(
            title: 'All books by status',
            list: snapshot.data!,
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const BooksByStatus(
            title: 'All books by status',
            list: null,
          );
        }
      },
    );
  }

  BlocBuilder<dynamic, dynamic> _buildPagesChallenge(
    BuildContext context,
    int? year,
  ) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        if (state is SetChallengeState && state.yearlyChallenges != null) {
          return StreamBuilder<List<BookReadStat>>(
            stream: BlocProvider.of<StatsCubit>(context).finishedPagesByMonth,
            builder: (context, AsyncSnapshot<List<BookReadStat>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No finished books'));
                }

                final yearlyChallenges = List<YearlyChallenge>.empty(
                  growable: true,
                );

                final jsons = state.yearlyChallenges!.split('|||||');
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

                final selectedValue = snapshot.data!.where((element) {
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
                    title: 'Finished pages challenge',
                    value: value,
                    target: selectedTarget.first.pages ?? 0,
                    setChallenge: _setChallenge,
                    booksTarget: selectedTarget.first.books,
                    pagesTarget: selectedTarget.first.pages,
                    year: year ?? DateTime.now().year,
                  );
                }
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          return (year == null)
              ? SetChallengeBox(
                  setChallenge: _setChallenge,
                  year: year ?? DateTime.now().year,
                )
              : const SizedBox();
        }
      },
    );
  }

  BlocBuilder<dynamic, dynamic> _buildBooksChallenge(
    BuildContext context,
    int? year,
  ) {
    return BlocBuilder<ChallengeBloc, ChallengeState>(
      builder: (context, state) {
        if (state is SetChallengeState && state.yearlyChallenges != null) {
          return StreamBuilder<List<BookReadStat>>(
            stream: BlocProvider.of<StatsCubit>(context).finishedBooksByMonth,
            builder: (context, AsyncSnapshot<List<BookReadStat>> snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No finished books'));
                }

                final yearlyChallenges = List<YearlyChallenge>.empty(
                  growable: true,
                );

                final jsons = state.yearlyChallenges!.split('|||||');
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

                final selectedValue = snapshot.data!.where((element) {
                  return (year == null)
                      ? element.year == DateTime.now().year
                      : element.year == year;
                });

                final value = selectedValue.isNotEmpty
                    ? selectedValue.first.values.reduce((a, b) => a + b)
                    : 0;

                if (selectedTarget.isEmpty ||
                    selectedTarget.first.books == null) {
                  return (year == null)
                      ? SetChallengeBox(
                          setChallenge: _setChallenge,
                          year: year ?? DateTime.now().year,
                          booksTarget: selectedTarget.first.books,
                          pagesTarget: selectedTarget.first.pages,
                        )
                      : const SizedBox();
                } else {
                  return ReadingChallenge(
                    title: 'Finished books challenge',
                    value: value,
                    target: selectedTarget.first.books ?? 0,
                    setChallenge: _setChallenge,
                    booksTarget: selectedTarget.first.books,
                    pagesTarget: selectedTarget.first.pages,
                    year: year ?? DateTime.now().year,
                  );
                }
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              } else {
                return const SizedBox();
              }
            },
          );
        } else {
          return (year == null)
              ? SetChallengeBox(
                  setChallenge: _setChallenge,
                  year: year ?? DateTime.now().year,
                )
              : const SizedBox();
        }
      },
    );
  }
}
