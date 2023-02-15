import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/resources/l10n.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class SetChallengeBox extends StatelessWidget {
  const SetChallengeBox({
    Key? key,
    required this.setChallenge,
    required this.year,
    this.booksTarget,
    this.pagesTarget,
  }) : super(key: key);

  final Function(int, int, int) setChallenge;
  final int year;
  final int? booksTarget;
  final int? pagesTarget;

  @override
  Widget build(BuildContext context) {
    return Card(
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: dividerColor, width: 1),
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      color: Theme.of(context).colorScheme.surfaceVariant,
      child: InkWell(
        borderRadius: BorderRadius.circular(cornerRadius),
        onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return ChallengeDialog(
                setChallenge: setChallenge,
                year: year,
                booksTarget: booksTarget,
                pagesTarget: pagesTarget,
              );
            }),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25,
            horizontal: 10,
          ),
          child: Row(
            children: [
              Text(
                l10n.click_here_to_set_challenge,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
