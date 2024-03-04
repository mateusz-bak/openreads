import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class ReadingChallenge extends StatelessWidget {
  const ReadingChallenge({
    super.key,
    required this.value,
    required this.target,
    required this.title,
    required this.setChallenge,
    required this.year,
    this.booksTarget,
    this.pagesTarget,
  });

  final int value;
  final int target;
  final String title;
  final Function(int, int, int) setChallenge;
  final int? booksTarget;
  final int? pagesTarget;
  final int year;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: InkWell(
        onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return ChallengeDialog(
                setChallenge: setChallenge,
                booksTarget: booksTarget,
                pagesTarget: pagesTarget,
                year: year,
              );
            }),
        borderRadius: BorderRadius.circular(cornerRadius),
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
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(cornerRadius),
                      ),
                      child: Row(
                        children: [
                          (target != 0)
                              ? Expanded(
                                  flex: ((value / target) * 100).toInt(),
                                  child: Container(
                                    height: 15,
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius:
                                          BorderRadius.circular(cornerRadius),
                                    ),
                                  ),
                                )
                              : const SizedBox(
                                  height: 15,
                                ),
                          (target != 0 &&
                                  (100 - ((value / target) * 100)).toInt() > 0)
                              ? Spacer(
                                  flex:
                                      (100 - ((value / target) * 100)).toInt(),
                                )
                              : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$value/$target',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    (target == 0)
                        ? ''
                        : '${((value / target * 100) <= 100) ? (value / target * 100).toStringAsFixed(2) : 100}%',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
