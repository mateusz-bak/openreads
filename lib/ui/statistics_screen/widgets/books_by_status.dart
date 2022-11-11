import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
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

  late Color finishedColor;
  late Color inProgressColor;
  late Color forLaterColor;
  late Color unfinishedColor;

  @override
  Widget build(BuildContext context) {
    finishedColor = Theme.of(context).finishedColor;
    inProgressColor = Theme.of(context).inProgressColor;
    forLaterColor = Theme.of(context).forLaterColor;
    unfinishedColor = Theme.of(context).unfinishedColor;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
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
                                sections: showingSections(),
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              PieChartIndicator(
                                color: finishedColor,
                                text: 'Finished',
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              PieChartIndicator(
                                color: inProgressColor,
                                text: 'In progress',
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              PieChartIndicator(
                                color: forLaterColor,
                                text: 'For later',
                              ),
                              SizedBox(
                                height: (widget.list![3] != 0) ? 5 : 0,
                              ),
                              (widget.list![3] != 0)
                                  ? PieChartIndicator(
                                      color: unfinishedColor,
                                      text: 'Unfinished',
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

  List<PieChartSectionData> showingSections() {
    final sum = widget.list!.reduce((a, b) => a + b);
    return List.generate(4, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: finishedColor,
            value: widget.list![0].toDouble(),
            title: '${((widget.list![0] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 1:
          return PieChartSectionData(
            color: inProgressColor,
            value: widget.list![1].toDouble(),
            title: '${((widget.list![1] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 2:
          return PieChartSectionData(
            color: forLaterColor,
            value: widget.list![2].toDouble(),
            title: '${((widget.list![2] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        case 3:
          return PieChartSectionData(
            color: unfinishedColor,
            value: widget.list![3].toDouble(),
            title: '${((widget.list![3] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: const Color(0xffffffff),
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
