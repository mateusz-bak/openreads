import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class BooksByStatus extends StatefulWidget {
  const BooksByStatus({
    super.key,
    required this.title,
    required this.list,
  });

  final String title;
  final List<int>? list;

  @override
  State<StatefulWidget> createState() => BooksByStatusState();
}

class BooksByStatusState extends State<BooksByStatus> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
            BorderRadius.circular(5),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: context.read<ThemeBloc>().fontFamily,
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: AspectRatio(
                aspectRatio: 2.2,
                child: (widget.list == null)
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AspectRatio(
                            aspectRatio: 1,
                            child: PieChart(
                              PieChartData(
                                pieTouchData: PieTouchData(
                                  touchCallback: (
                                    FlTouchEvent event,
                                    pieTouchResponse,
                                  ) {
                                    setState(() {
                                      if (!event.isInterestedForInteractions ||
                                          pieTouchResponse == null ||
                                          pieTouchResponse.touchedSection ==
                                              null) {
                                        touchedIndex = -1;
                                        return;
                                      }
                                      touchedIndex = pieTouchResponse
                                          .touchedSection!.touchedSectionIndex;
                                    });
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: false,
                                ),
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: showingSections(theme),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PieChartIndicator(
                                color: theme.primaryGreen,
                                text: 'Finished',
                                number: widget.list![0],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              PieChartIndicator(
                                color: theme.primaryYellow,
                                text: 'In progress',
                                number: widget.list![1],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              PieChartIndicator(
                                color: theme.primaryBlue,
                                text: 'For later',
                                number: widget.list![2],
                              ),
                              SizedBox(
                                height: (widget.list![3] != 0) ? 5 : 0,
                              ),
                              (widget.list![3] != 0)
                                  ? PieChartIndicator(
                                      color: theme.primaryRed,
                                      text: 'Unfinished',
                                      number: widget.list![3],
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections(ThemeData theme) {
    final sum = widget.list!.reduce((a, b) => a + b);
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: theme.primaryGreen,
            value: widget.list![0].toDouble(),
            title: '${((widget.list![0] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: theme.primaryYellow,
            value: widget.list![1].toDouble(),
            title: '${((widget.list![1] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: theme.primaryBlue,
            value: widget.list![2].toDouble(),
            title: '${((widget.list![2] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: theme.primaryRed,
            value: widget.list![3].toDouble(),
            title: '${((widget.list![3] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
              fontFamily: context.read<ThemeBloc>().fontFamily,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
