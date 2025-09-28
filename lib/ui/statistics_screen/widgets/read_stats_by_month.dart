import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';
import 'package:collection/collection.dart';

class ReadStatsByMonth extends StatelessWidget {
  ReadStatsByMonth({
    super.key,
    required this.listPaperbackBooks,
    required this.listHardcoverBooks,
    required this.listEbooks,
    required this.listAudiobooks,
    required this.title,
    required this.theme,
  });

  final List<int> listPaperbackBooks;
  final List<int> listHardcoverBooks;
  final List<int> listEbooks;
  final List<int> listAudiobooks;
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
              meta: meta,
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

  List<BarChartGroupData> barGroups(BuildContext context) {
    final firstColor = Theme.of(context).colorScheme.primary;
    final secondColor = Theme.of(context).colorScheme.tertiaryContainer;
    final thirdColor = Theme.of(context).colorScheme.secondary;

    final List<BarChartGroupData> barList = List.empty(growable: true);

    for (var i = 0; i < 12; i++) {
      barList.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: (listPaperbackBooks[i] +
                      listHardcoverBooks[i] +
                      listEbooks[i] +
                      listAudiobooks[i])
                  .toDouble(),
              width: MediaQuery.of(context).size.width / 20,
              color: firstColor,
              borderRadius: BorderRadius.circular(3),
              rodStackItems: [
                listPaperbackBooks[i] != 0
                    ? BarChartRodStackItem(
                        0,
                        (listPaperbackBooks[i] + listHardcoverBooks[i])
                            .toDouble(),
                        firstColor,
                      )
                    : BarChartRodStackItem(0, 0, Colors.transparent),
                listEbooks[i] != 0
                    ? BarChartRodStackItem(
                        (listPaperbackBooks[i] + listHardcoverBooks[i])
                            .toDouble(),
                        (listPaperbackBooks[i] +
                                listHardcoverBooks[i] +
                                listEbooks[i])
                            .toDouble(),
                        secondColor,
                      )
                    : BarChartRodStackItem(0, 0, Colors.transparent),
                listAudiobooks[i] != 0
                    ? BarChartRodStackItem(
                        (listPaperbackBooks[i] +
                                listHardcoverBooks[i] +
                                listEbooks[i])
                            .toDouble(),
                        (listPaperbackBooks[i] +
                                listHardcoverBooks[i] +
                                listEbooks[i] +
                                listAudiobooks[i])
                            .toDouble(),
                        thirdColor,
                      )
                    : BarChartRodStackItem(0, 0, Colors.transparent),
              ],
            )
          ],
          showingTooltipIndicators: ((listPaperbackBooks[i] +
                      listHardcoverBooks[i] +
                      listEbooks[i] +
                      listAudiobooks[i]) >
                  0)
              ? [0]
              : [1],
        ),
      );
    }

    return barList;
  }

  double calculateMaxY() {
    int maxBooksInMonth = 0;

    for (var i = 0; i < 12; i++) {
      if ((listPaperbackBooks[i] +
              listHardcoverBooks[i] +
              listEbooks[i] +
              listAudiobooks[i]) >
          maxBooksInMonth) {
        maxBooksInMonth = (listPaperbackBooks[i] +
            listHardcoverBooks[i] +
            listEbooks[i] +
            listAudiobooks[i]);
      }
    }

    return maxBooksInMonth * 1.2;
  }

  @override
  Widget build(BuildContext context) {
    return StatsCard(
        child: Padding(
      padding: const EdgeInsets.all(15),
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
          const SizedBox(height: 15),
          _buildBarChart(context),
          const Divider(),
          const SizedBox(height: 10),
          _buildLegend(context),
        ],
      ),
    ));
  }

  AspectRatio _buildBarChart(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.5,
      child: BarChart(
        BarChartData(
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => Colors.transparent,
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
          barGroups: barGroups(context),
          gridData: const FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: calculateMaxY(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 150),
        swapAnimationCurve: Curves.linear,
      ),
    );
  }

  Column _buildLegend(BuildContext context) {
    final firstColor = Theme.of(context).colorScheme.primary;
    final secondColor = Theme.of(context).colorScheme.tertiaryContainer;
    final thirdColor = Theme.of(context).colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        ChartLegendElement(
          color: firstColor,
          text: LocaleKeys.book_format_audiobook_plural.tr(),
          number: listAudiobooks.sum,
          size: 16,
        ),
        const SizedBox(height: 5),
        ChartLegendElement(
          color: secondColor,
          text: LocaleKeys.book_format_ebook_plural.tr(),
          number: listEbooks.sum,
          size: 16,
        ),
        const SizedBox(height: 5),
        ChartLegendElement(
          color: thirdColor,
          text: LocaleKeys.book_format_paper_plural.tr(),
          number: listPaperbackBooks.sum + listHardcoverBooks.sum,
          size: 16,
        ),
      ],
    );
  }
}
