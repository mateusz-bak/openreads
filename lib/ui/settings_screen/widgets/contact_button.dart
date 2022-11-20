import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class ContactButton extends StatelessWidget {
  const ContactButton({
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
      shape: RoundedRectangleBorder(
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
            BorderRadius.circular(5),
      ),
      child: InkWell(
        customBorder: RoundedRectangleBorder(
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
              BorderRadius.circular(5),
        ),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
            color: Theme.of(context).backgroundColor,
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 10),
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
