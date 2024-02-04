import 'package:flutter/material.dart';

class WelcomeChoiceButton extends StatelessWidget {
  const WelcomeChoiceButton({
    super.key,
    required this.description,
    required this.onPressed,
    this.isSkipImporting = false,
  });

  final String description;
  final Function() onPressed;
  final bool isSkipImporting;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.tonal(
              style: ButtonStyle(
                backgroundColor: isSkipImporting
                    ? MaterialStateProperty.all(
                        Theme.of(context).colorScheme.secondary,
                      )
                    : MaterialStateProperty.all(
                        Theme.of(context)
                            .colorScheme
                            .surfaceVariant
                            .withOpacity(0.3),
                      ),
                foregroundColor: MaterialStateProperty.all(
                  isSkipImporting
                      ? Theme.of(context).colorScheme.onSecondary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: isSkipImporting
                        ? BorderSide(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant
                                .withOpacity(0.5),
                          )
                        : BorderSide.none,
                  ),
                ),
              ),
              onPressed: onPressed,
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        0,
                        10,
                        0,
                        10,
                      ),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: isSkipImporting ? 20 : 18,
                          fontWeight: isSkipImporting
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        textAlign: isSkipImporting
                            ? TextAlign.center
                            : TextAlign.start,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
