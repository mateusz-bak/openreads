import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class ReadStatsByMonth extends StatelessWidget {
  ReadStatsByMonth({
    Key? key,
    required this.list,
    required this.title,
    required this.theme,
  }) : super(key: key);

  final List<int> list;
  final String title;
  final ThemeData theme;

  final List<String> listOfMonthsShort = [
    LocaleKeys.january_short.tr(),
    LocaleKeys.february_short.tr(),
    LocaleKeys.march_short.tr(),
    LocaleKeys.april_short.tr(),
    LocaleKeys.may_short.tr(),
    LocaleKeys.june_short.tr(),
    LocaleKeys.july_short.tr(),
    LocaleKeys.august_short.tr(),
    LocaleKeys.september_short.tr(),
    LocaleKeys.october_short.tr(),
    LocaleKeys.november_short.tr(),
    LocaleKeys.december_short.tr(),
  ];

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 32,
            getTitlesWidget: getTitles,
            interval: 2,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    String text;

    switch (value.toInt()) {
      case 0:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 1:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 2:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 3:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 4:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 5:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 6:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 7:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 8:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 9:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 10:
        text = listOfMonthsShort[value.toInt()];
        break;
      case 11:
        text = listOfMonthsShort[value.toInt()];
        break;
      default:
        text = '';
        break;
    }

    return (value % meta.appliedInterval == 0)
        ? Builder(builder: (context) {
            return SideTitleWidget(
              axisSide: meta.axisSide,
              space: 8,
              child: Text(
                text,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          })
        : const SizedBox();
  }

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  List<BarChartGroupData> barGroups() {
    final List<BarChartGroupData> barList = List.empty(growable: true);

    for (var i = 0; i < 12; i++) {
      barList.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: list[i].toDouble(),
              width: 14,
              color: theme.colorScheme.primary,
            )
          ],
          showingTooltipIndicators: (list[i] > 0) ? [0] : [1],
        ),
      );
    }

    return barList;
  }

  double calculateMaxY() {
    int maxBooksInMonth = 0;

    for (int month in list) {
      if (month > maxBooksInMonth) {
        maxBooksInMonth = month;
      }
    }

    return maxBooksInMonth * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 2.2,
              child: BarChart(
                BarChartData(
                  barTouchData: BarTouchData(
                    enabled: false,
                    touchTooltipData: BarTouchTooltipData(
                      tooltipBgColor: Colors.transparent,
                      tooltipPadding: EdgeInsets.zero,
                      tooltipMargin: 8,
                      fitInsideHorizontally: true,
                      fitInsideVertically: true,
                      getTooltipItem: (
                        BarChartGroupData group,
                        int groupIndex,
                        BarChartRodData rod,
                        int rodIndex,
                      ) {
                        return BarTooltipItem(
                          rod.toY.round().toString(),
                          const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: titlesData,
                  borderData: borderData,
                  barGroups: barGroups(),
                  gridData: const FlGridData(show: false),
                  alignment: BarChartAlignment.spaceAround,
                  maxY: calculateMaxY(),
                ),
                swapAnimationDuration: const Duration(milliseconds: 150),
                swapAnimationCurve: Curves.linear,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
