import 'package:flutter/material.dart';

class AnimatedStatusButton extends StatelessWidget {
  const AnimatedStatusButton({
    Key? key,
    required Duration duration,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
  })  : _duration = duration,
        super(key: key);

  final Duration _duration;
  final double width;
  final double height;
  final Function() onPressed;
  final IconData icon;
  final String text;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: _duration,
      height: height,
      width: width,
      alignment: Alignment.center,
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: backgroundColor,
          ),
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(icon, color: color),
                  FittedBox(
                    child: Text(
                      text,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 13,
                        color: color,
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
