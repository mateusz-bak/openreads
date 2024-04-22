import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/main.dart';

class SetDateButton extends StatefulWidget {
  const SetDateButton({
    super.key,
    required this.defaultHeight,
    required this.icon,
    required this.text,
    required this.date,
    required this.onPressed,
    required this.onClearPressed,
    required this.showClearButton,
  });

  final double defaultHeight;
  final IconData icon;
  final String text;
  final DateTime? date;
  final Function() onPressed;
  final Function() onClearPressed;
  final bool showClearButton;

  @override
  State<SetDateButton> createState() => _SetDateButtonState();
}

class _SetDateButtonState extends State<SetDateButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.defaultHeight,
      child: Stack(
        children: [
          InkWell(
            customBorder: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            onTap: widget.onPressed,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cornerRadius),
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withOpacity(0.5),
                border: Border.all(color: dividerColor),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.icon,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.date != null
                            ? dateFormat.format(widget.date!)
                            : widget.text,
                        maxLines: 1,
                        style: const TextStyle(fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    (widget.showClearButton)
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                            ),
                            visualDensity: VisualDensity.compact,
                            onPressed: widget.onClearPressed,
                          )
                        : const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
