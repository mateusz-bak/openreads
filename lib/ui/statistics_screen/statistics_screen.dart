import 'package:flutter/material.dart';
import 'package:openreads/logic/cubit/stats_cubit.dart';
import 'package:openreads/model/book_stat.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              StreamBuilder<List<int>>(
                stream: statsCubit.finishedBooksByMonth,
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
              ),
              StreamBuilder<List<int>>(
                stream: statsCubit.finishedPagesByMonth,
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
              ),
              StreamBuilder<int>(
                stream: statsCubit.numberOfFinishedBooks,
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
              ),
              StreamBuilder<int>(
                stream: statsCubit.numberOfFinishedPages,
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
              ),
              StreamBuilder<double>(
                stream: statsCubit.avgRating,
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
              ),
              StreamBuilder<double>(
                stream: statsCubit.avgPages,
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
              ),
              StreamBuilder<double?>(
                stream: statsCubit.avgReadingTime,
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
              ),
              StreamBuilder<BookStat?>(
                stream: statsCubit.longest,
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
              ),
              StreamBuilder<BookStat?>(
                stream: statsCubit.shortest,
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
              ),
              StreamBuilder<BookStat?>(
                stream: statsCubit.fastest,
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
              ),
              StreamBuilder<BookStat?>(
                stream: statsCubit.slowest,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
