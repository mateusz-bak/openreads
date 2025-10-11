import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';
import 'package:openreads/ui/display_screen/widgets/widgets.dart';

class DisplayScreen extends StatelessWidget {
  const DisplayScreen({super.key});

  void _switchBookFormatDisplay(BuildContext context) {
    final currentState = context.read<DisplayCubit>().state;

    context.read<DisplayCubit>().setShowBookFormatOnList(
          !currentState.bookFormatOnList,
        );
  }

  void _switchSortAttributesOnList(BuildContext context) {
    final currentState = context.read<DisplayCubit>().state;

    context.read<DisplayCubit>().setShowSortAttributesOnList(
          !currentState.sortAttributesOnList,
        );
  }

  void _switchTagsOnList(BuildContext context) {
    final currentState = context.read<DisplayCubit>().state;

    context.read<DisplayCubit>().setShowTagsOnList(
          !currentState.tagsOnList,
        );
  }

  void _switchShowTitleOverCover(BuildContext context) {
    final currentState = context.read<DisplayCubit>().state;

    context.read<DisplayCubit>().setShowTitleOverCover(
          !currentState.showTitleOverCover,
        );
  }

  void _switchNumberOfBooksDisplay(BuildContext context) {
    final currentState = context.read<DisplayCubit>().state;

    context.read<DisplayCubit>().setShowNumberOfBooks(
          !currentState.showNumberOfBooks,
        );
  }

  void _setGridSize(BuildContext context, double value) {
    context.read<DisplayCubit>().setGridSize(value.toInt());
  }

  bool _displayIsAnyGrid(DisplayState state) {
    return state.type == DisplayType.grid ||
        state.type == DisplayType.detailedGrid;
  }

  bool _displayIsList(DisplayState state) {
    return state.type == DisplayType.list;
  }

  bool _displayIsDetailedGrid(DisplayState state) {
    return state.type == DisplayType.detailedGrid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.display.tr(),
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: BlocBuilder<DisplayCubit, DisplayState>(builder: (context, state) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDisplayModeButtons(context, state),
              _buildShowNumberOfBooks(context, state),
              _buildListOptions(context, state),
              _buildGridOptions(context, state),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildListOptions(BuildContext context, DisplayState state) {
    if (_displayIsAnyGrid(state)) return const SizedBox.shrink();

    return Column(
      children: [
        _buildShowBookFormat(context, state),
        _buildShowSortAttributes(context, state),
        _buildShowTags(context, state),
      ],
    );
  }

  Widget _buildGridOptions(BuildContext context, DisplayState state) {
    if (!_displayIsAnyGrid(state)) return const SizedBox.shrink();

    return Column(
      children: [
        _buildShowTitleOverCover(context, state),
        _buildGridSize(context, state),
      ],
    );
  }

  Widget _buildShowNumberOfBooks(BuildContext context, DisplayState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Switch.adaptive(
            value: state.showNumberOfBooks,
            onChanged: (value) {
              _switchNumberOfBooksDisplay(context);
            },
          ),
          const SizedBox(width: 10),
          Text(
            LocaleKeys.show_number_of_books.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildShowBookFormat(BuildContext context, DisplayState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Switch.adaptive(
            value: state.bookFormatOnList,
            onChanged: (value) {
              _switchBookFormatDisplay(context);
            },
          ),
          const SizedBox(width: 10),
          Text(
            LocaleKeys.show_book_format.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildShowSortAttributes(BuildContext context, DisplayState state) {
    if (!_displayIsList(state)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Switch.adaptive(
            value: state.sortAttributesOnList,
            onChanged: (value) {
              _switchSortAttributesOnList(context);
            },
          ),
          const SizedBox(width: 10),
          Text(
            LocaleKeys.show_sort_attributes.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildShowTags(BuildContext context, DisplayState state) {
    if (!_displayIsList(state)) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Switch.adaptive(
            value: state.tagsOnList,
            onChanged: (value) {
              _switchTagsOnList(context);
            },
          ),
          const SizedBox(width: 10),
          Text(
            LocaleKeys.show_tags.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSize(BuildContext context, DisplayState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                LocaleKeys.grid_size.tr(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                ' (${state.gridSize})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface.withAlpha(200),
                ),
              ),
            ],
          ),
          Slider.adaptive(
            value: state.gridSize.toDouble(),
            min: 2,
            max: 4,
            divisions: 2,
            label: state.gridSize.toString(),
            onChanged: (double value) {
              _setGridSize(context, value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShowTitleOverCover(BuildContext context, DisplayState state) {
    if (!_displayIsDetailedGrid(state)) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Switch.adaptive(
            value: state.showTitleOverCover,
            onChanged: (value) {
              _switchShowTitleOverCover(context);
            },
          ),
          const SizedBox(width: 10),
          Text(
            LocaleKeys.show_title_over_cover.tr(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Padding _buildDisplayModeButtons(BuildContext context, DisplayState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            children: [
              DisplayTypeChip(
                currentDisplayType: state.type,
                displayText: LocaleKeys.list.tr(),
                displayType: DisplayType.list,
              ),
              const SizedBox(width: 10),
              DisplayTypeChip(
                currentDisplayType: state.type,
                displayText: LocaleKeys.compact_list.tr(),
                displayType: DisplayType.compactList,
              ),
              const SizedBox(width: 10),
              DisplayTypeChip(
                currentDisplayType: state.type,
                displayText: LocaleKeys.grid.tr(),
                displayType: DisplayType.grid,
              ),
              const SizedBox(width: 10),
              DisplayTypeChip(
                currentDisplayType: state.type,
                displayText: LocaleKeys.detailed_grid.tr(),
                displayType: DisplayType.detailedGrid,
              ),
              const SizedBox(width: 10),
            ],
          ),
          const Divider(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
