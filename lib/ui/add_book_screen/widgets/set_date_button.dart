import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class SetDateButton extends StatelessWidget {
  const SetDateButton({
    Key? key,
    required this.defaultHeight,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.onClearPressed,
    required this.showClearButton,
  }) : super(key: key);

  final double defaultHeight;
  final IconData icon;
  final String text;
  final Function() onPressed;
  final Function() onClearPressed;
  final bool showClearButton;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: defaultHeight,
      child: Stack(
        children: [
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius:
                  Theme.of(context).extension<CustomBorder>()?.radius ??
                      BorderRadius.circular(5),
            ),
            onTap: onPressed,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius:
                    Theme.of(context).extension<CustomBorder>()?.radius,
                color: Theme.of(context).backgroundColor,
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 15),
                      FittedBox(
                        child: Text(
                          text,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).mainTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                (showClearButton)
                    ? IconButton(
                        icon: Icon(
                          Icons.close,
                          size: 20,
                          color: Theme.of(context).mainTextColor,
                        ),
                        onPressed: onClearPressed,
                      )
                    : const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
