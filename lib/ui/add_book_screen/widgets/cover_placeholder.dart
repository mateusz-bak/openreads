import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

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
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
            BorderRadius.circular(5),
      ),
      onTap: onPressed,
      child: Ink(
        height: defaultHeight,
        decoration: BoxDecoration(
          borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
          color: Theme.of(context).backgroundColor,
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 10,
          ),
          child: Center(
            child: Row(
              children: [
                const SizedBox(width: 8),
                Icon(
                  Icons.image,
                  size: 24,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 15),
                Text(
                  'Click to add a cover',
                  style: TextStyle(
                    color: Theme.of(context).secondaryTextColor,
                    fontFamily: context.read<ThemeBloc>().fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
