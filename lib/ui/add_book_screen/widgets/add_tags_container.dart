import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:openreads/core/themes/app_theme.dart';

class AddTagsContainer extends StatelessWidget {
  const AddTagsContainer({
    Key? key,
    required double defaultHeight,
  })  : _defaultHeight = defaultHeight,
        super(key: key);

  final double _defaultHeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _defaultHeight,
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FontAwesomeIcons.tags,
                color: Theme.of(context).secondaryTextColor,
              ),
              const SizedBox(width: 10),
              Text(
                'Tags',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).secondaryTextColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
