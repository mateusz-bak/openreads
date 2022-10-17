import 'package:flutter/material.dart';

class CoverPlaceholder extends StatelessWidget {
  const CoverPlaceholder({
    Key? key,
    required this.defaultHeight,
    required this.onPressed,
  }) : super(key: key);

  final double defaultHeight;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      onTap: onPressed,
      child: Ink(
        height: defaultHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10,
          ),
          child: Center(
            child: Row(
              children: const [
                SizedBox(width: 8),
                Icon(
                  Icons.image,
                  size: 24,
                  color: Colors.black54,
                ),
                SizedBox(width: 15),
                Text('Click to add a cover'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
