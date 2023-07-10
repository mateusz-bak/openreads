import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
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
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
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
                aspectRatio: 2,
                child: (widget.list == null)
                    ? const SizedBox()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 5,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 1,
                                sections: showingSections(),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                ChartLegendElement(
                                  color: Colors.green.shade400,
                                  text: LocaleKeys.books_finished.tr(),
                                  number: widget.list![0],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ChartLegendElement(
                                  color: Colors.yellow.shade400,
                                  text: LocaleKeys.books_in_progress.tr(),
                                  number: widget.list![1],
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                ChartLegendElement(
                                  color: Colors.blue.shade400,
                                  text: LocaleKeys.books_for_later.tr(),
                                  number: widget.list![2],
                                ),
                                SizedBox(
                                  height: (widget.list![3] != 0) ? 5 : 0,
                                ),
                                (widget.list![3] != 0)
                                    ? ChartLegendElement(
                                        color: Colors.red.shade400,
                                        text: LocaleKeys.books_unfinished.tr(),
                                        number: widget.list![3],
                                      )
                                    : const SizedBox(),
                              ],
                            ),
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
      const fontSize = 14.0;
      final radius = isTouched ? 60.0 : 50.0;
      switch (i) {
        case 0:
          return PieChartSectionData(
            color: Colors.green.shade400,
            value: widget.list![0].toDouble(),
            title: '${((widget.list![0] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        case 1:
          return PieChartSectionData(
            color: Colors.yellow.shade400,
            value: widget.list![1].toDouble(),
            title: '${((widget.list![1] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        case 2:
          return PieChartSectionData(
            color: Colors.blue.shade400,
            value: widget.list![2].toDouble(),
            title: '${((widget.list![2] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        case 3:
          return PieChartSectionData(
            color: Colors.red.shade400,
            value: widget.list![3].toDouble(),
            title: '${((widget.list![3] / sum) * 100).toStringAsFixed(0)}%',
            radius: radius,
            titleStyle: const TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          );
        default:
          throw Error();
      }
    });
  }
}
