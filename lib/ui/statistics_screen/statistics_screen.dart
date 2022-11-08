import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/logic/cubit/stats_cubit.dart';
import 'package:openreads/model/book_stat.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
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
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  _buildFinishedBooksByMonth(context),
                  _buildFinishedPagesByMonth(context),
                  _buildNumberOfFinishedBooks(context),
                  _buildNumberOfFinishedPages(context),
                  _buildAverageRating(context),
                  _buildAveragePages(context),
                  _buildAverageReadingTime(context),
                  _buildLongestBook(context),
                  _buildShortestBook(context),
                  _buildFastestRead(context),
                  _buildSlowestRead(context),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  StreamBuilder<BookStat?> _buildSlowestRead(BuildContext context) {
    return StreamBuilder<BookStat?>(
      stream: BlocProvider.of<StatsCubit>(context).slowest,
      builder: (context, AsyncSnapshot<BookStat?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Slowest read book',
            value: snapshot.data!.title,
            secondValue: '${snapshot.data!.value} days',
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<BookStat?> _buildFastestRead(BuildContext context) {
    return StreamBuilder<BookStat?>(
      stream: BlocProvider.of<StatsCubit>(context).fastest,
      builder: (context, AsyncSnapshot<BookStat?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Fastest read book',
            value: snapshot.data!.title,
            secondValue: '${snapshot.data!.value} days',
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<BookStat?> _buildShortestBook(BuildContext context) {
    return StreamBuilder<BookStat?>(
      stream: BlocProvider.of<StatsCubit>(context).shortest,
      builder: (context, AsyncSnapshot<BookStat?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Shortest book',
            value: snapshot.data!.title,
            secondValue: '${snapshot.data!.value} pages',
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<BookStat?> _buildLongestBook(BuildContext context) {
    return StreamBuilder<BookStat?>(
      stream: BlocProvider.of<StatsCubit>(context).longest,
      builder: (context, AsyncSnapshot<BookStat?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Longest book',
            value: snapshot.data!.title,
            secondValue: '${snapshot.data!.value} pages',
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<double?> _buildAverageReadingTime(BuildContext context) {
    return StreamBuilder<double?>(
      stream: BlocProvider.of<StatsCubit>(context).avgReadingTime,
      builder: (context, AsyncSnapshot<double?> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Average reading time',
            value: '${snapshot.data!.toStringAsFixed(0)} days',
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<double> _buildAveragePages(BuildContext context) {
    return StreamBuilder<double>(
      stream: BlocProvider.of<StatsCubit>(context).avgPages,
      builder: (context, AsyncSnapshot<double> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Average number of pages',
            value: snapshot.data!.toStringAsFixed(0),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<double> _buildAverageRating(BuildContext context) {
    return StreamBuilder<double>(
      stream: BlocProvider.of<StatsCubit>(context).avgRating,
      builder: (context, AsyncSnapshot<double> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Average book rating',
            value: snapshot.data!.toStringAsFixed(2),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<int> _buildNumberOfFinishedPages(BuildContext context) {
    return StreamBuilder<int>(
      stream: BlocProvider.of<StatsCubit>(context).numberOfFinishedPages,
      builder: (context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Finished pages',
            value: snapshot.data!.toString(),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<int> _buildNumberOfFinishedBooks(BuildContext context) {
    return StreamBuilder<int>(
      stream: BlocProvider.of<StatsCubit>(context).numberOfFinishedBooks,
      builder: (context, AsyncSnapshot<int> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStats(
            title: 'Finished books',
            value: snapshot.data!.toString(),
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<List<int>> _buildFinishedPagesByMonth(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: BlocProvider.of<StatsCubit>(context).finishedPagesByMonth,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStatsByMonth(
            title: 'Finished pages by month',
            list: snapshot.data!,
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }

  StreamBuilder<List<int>> _buildFinishedBooksByMonth(BuildContext context) {
    return StreamBuilder<List<int>>(
      stream: BlocProvider.of<StatsCubit>(context).finishedBooksByMonth,
      builder: (context, AsyncSnapshot<List<int>> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No finished books'));
          }
          return ReadStatsByMonth(
            title: 'Finished books by month',
            list: snapshot.data!,
          );
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        } else {
          return const Center(
            child: SizedBox(),
          );
        }
      },
    );
  }
}
