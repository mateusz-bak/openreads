import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

class ReadStats extends StatelessWidget {
  const ReadStats({
    Key? key,
    required this.title,
    required this.value,
    this.secondValue,
    this.iconData,
  }) : super(key: key);

  final String title;
  final String value;
  final String? secondValue;
  final IconData? iconData;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
            BorderRadius.circular(5),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
      ),
      color: Theme.of(context).backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).mainTextColor,
                fontFamily: context.read<ThemeBloc>().fontFamily,
              ),
            ),
            const SizedBox(height: 5),
            (iconData == null)
                ? Text(
                    value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).secondaryTextColor,
                      fontFamily: context.read<ThemeBloc>().fontFamily,
                    ),
                  )
                : Row(
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Theme.of(context).secondaryTextColor,
                          fontFamily: context.read<ThemeBloc>().fontFamily,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Icon(
                        iconData,
                        size: 16,
                        color: Theme.of(context).ratingColor,
                      ),
                    ],
                  ),
            (secondValue == null)
                ? const SizedBox()
                : Text(
                    secondValue!,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Theme.of(context).secondaryTextColor,
                      fontFamily: context.read<ThemeBloc>().fontFamily,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
