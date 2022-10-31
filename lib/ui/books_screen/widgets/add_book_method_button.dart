import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class AddBookMethodButton extends StatelessWidget {
  const AddBookMethodButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  final String text;
  final IconData icon;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: Theme.of(context).backgroundColor,
            border: Border.all(color: Theme.of(context).outlineColor),
          ),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 5),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
