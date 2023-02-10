import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  late final List<String> listOfMonthsShort;

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
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: AxisTitles(
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
                style: TextStyle(
                  color: Theme.of(context).mainTextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  fontFamily: context.read<ThemeBloc>().fontFamily,
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
              width: 15,
              color: theme.primaryColor,
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
    listOfMonthsShort = [
      AppLocalizations.of(context)!.january_short,
      AppLocalizations.of(context)!.february_short,
      AppLocalizations.of(context)!.march_short,
      AppLocalizations.of(context)!.april_short,
      AppLocalizations.of(context)!.may_short,
      AppLocalizations.of(context)!.june_short,
      AppLocalizations.of(context)!.july_short,
      AppLocalizations.of(context)!.august_short,
      AppLocalizations.of(context)!.september_short,
      AppLocalizations.of(context)!.october_short,
      AppLocalizations.of(context)!.november_short,
      AppLocalizations.of(context)!.december_short,
    ];

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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: context.read<ThemeBloc>().fontFamily,
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
                          TextStyle(
                            color: Theme.of(context).mainTextColor,
                            fontWeight: FontWeight.bold,
                            fontFamily: context.read<ThemeBloc>().fontFamily,
                            fontSize: 11,
                          ),
                        );
                      },
                    ),
                  ),
                  titlesData: titlesData,
                  borderData: borderData,
                  barGroups: barGroups(),
                  gridData: FlGridData(show: false),
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
