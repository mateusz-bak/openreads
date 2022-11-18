import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class ReadingChallenge extends StatelessWidget {
  const ReadingChallenge({
    Key? key,
    required this.value,
    required this.target,
    required this.title,
  }) : super(key: key);

  final int value;
  final int target;
  final String title;

  @override
  Widget build(BuildContext context) {
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
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius:
                          Theme.of(context).extension<CustomBorder>()?.radius,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: ((value / target) * 100).toInt(),
                          child: Container(
                            height: 15,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: Theme.of(context)
                                  .extension<CustomBorder>()
                                  ?.radius,
                            ),
                          ),
                        ),
                        Spacer(
                          flex: (100 - ((value / target) * 100)).toInt(),
                        )
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
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).secondaryTextColor,
                  ),
                ),
                Text(
                  '${(value / target * 100).toStringAsPrecision(2)}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).secondaryTextColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
