import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';

class DisplayTypeChip extends StatelessWidget {
  const DisplayTypeChip({
    super.key,
    required this.currentDisplayType,
    required this.displayText,
    required this.displayType,
  });

  final DisplayType currentDisplayType;
  final String displayText;
  final DisplayType displayType;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      selected: currentDisplayType == displayType,
      label: Text(
        displayText,
        style: TextStyle(
          color: currentDisplayType == displayType
              ? Theme.of(context).colorScheme.onPrimaryContainer
              : null,
        ),
      ),
      showCheckmark: false,
      onSelected: (_) {
        context.read<DisplayCubit>().setDisplayType(
              displayType,
            );
      },
    );
  }
}
