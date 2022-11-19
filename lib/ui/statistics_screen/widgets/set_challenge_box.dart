import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class SetChallengeBox extends StatelessWidget {
  const SetChallengeBox({
    Key? key,
    required this.setChallenge,
  }) : super(key: key);

  final Function(int, int) setChallenge;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
            BorderRadius.circular(5),
        side: BorderSide(color: Theme.of(context).dividerColor, width: 1),
      ),
      color: Theme.of(context).backgroundColor,
      child: InkWell(
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
            BorderRadius.circular(5),
        onTap: () => showDialog(
            context: context,
            builder: (BuildContext context) {
              return ChallengeDialog(setChallenge: setChallenge);
            }),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 25,
            horizontal: 10,
          ),
          child: Row(
            children: const [
              Text(
                'Click here to set a yearly challenge',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
