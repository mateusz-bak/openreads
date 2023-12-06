import 'package:flutter/material.dart';

class SettingsDialogButton extends StatelessWidget {
  const SettingsDialogButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.fontFamily,
  });

  final String text;
  final Function() onPressed;
  final String? fontFamily;

  static const example =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SimpleDialogOption(
            padding: EdgeInsets.zero,
            onPressed: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(fontSize: 16, fontFamily: fontFamily),
                  ),
                  fontFamily != null
                      ? const Divider(
                          height: 8,
                        )
                      : const SizedBox(),
                  fontFamily != null
                      ? Text(
                          example,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamily,
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
