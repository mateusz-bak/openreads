import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';

class BookDetail extends StatelessWidget {
  const BookDetail({
    super.key,
    required this.title,
    required this.text,
    this.onTap,
  });

  final String title;
  final String text;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: onTap != null
                ? Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(cornerRadius),
                      onTap: onTap,
                      child: _buildText(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  )
                : _buildText(null),
          ),
        ],
      ),
    );
  }

  Text _buildText(Color? color) {
    return Text(
      text,
      textAlign: TextAlign.end,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: color,
      ),
    );
  }
}
