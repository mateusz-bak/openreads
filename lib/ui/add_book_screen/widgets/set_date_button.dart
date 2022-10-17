import 'package:flutter/material.dart';

class SetDateButton extends StatelessWidget {
  const SetDateButton({
    Key? key,
    required this.defaultHeight,
    required this.icon,
    required this.text,
    required this.onPressed,
  }) : super(key: key);

  final double defaultHeight;
  final IconData icon;
  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: defaultHeight,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Colors.white,
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
                  Icon(icon),
                  const SizedBox(width: 15),
                  FittedBox(
                    child: Text(
                      text,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
