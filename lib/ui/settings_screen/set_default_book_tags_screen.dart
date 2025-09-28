import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/cubit/default_book_tags_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/add_book_screen/widgets/book_text_field.dart';
import 'package:openreads/ui/books_screen/widgets/tag_filter_chip.dart';
import 'package:openreads/ui/common/themed_scaffold.dart';
import 'package:openreads/ui/common/keyboard_dismissable.dart';

class SetDefaultBookTagsScreen extends StatelessWidget {
  SetDefaultBookTagsScreen({super.key});
  final _searchController = TextEditingController();

  void onTagChipPressed(BuildContext context, String tag) {
    FocusScope.of(context).unfocus();
    context.read<DefaultBookTagsCubit>().updateTag(tag);
  }

  void _submitNewTag(BuildContext context, String input) {
    final newTag = input.trim();

    if (newTag.isEmpty) {
      _searchController.clear();
      return;
    }

    context.read<DefaultBookTagsCubit>().updateTag(newTag);

    _searchController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardDismissible(
      child: ThemedScaffold(
        appBar: AppBar(
          title: Text(
            LocaleKeys.set_default_tags.tr(),
            style: const TextStyle(fontSize: 18),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreamBuilder<List<String>>(
                stream: bookCubit.tags,
                builder: (
                  context,
                  AsyncSnapshot<List<String>?> allTagsSnapshot,
                ) {
                  return BlocBuilder<DefaultBookTagsCubit, List<String>>(
                      buildWhen: (previous, current) => previous != current,
                      builder: (_, defaultTags) {
                        return Wrap(
                          children: _buildTagChips(
                            context,
                            allTagsSnapshot.data ?? [],
                            defaultTags,
                          ),
                        );
                      });
                },
              ),
              const SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            LocaleKeys.add_new_default_tag.tr(),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    BookTextField(
                      controller: _searchController,
                      keyboardType: TextInputType.name,
                      maxLength: 99,
                      textInputAction: TextInputAction.done,
                      textCapitalization: TextCapitalization.none,
                      padding: EdgeInsets.zero,
                      onSubmitted: (input) => _submitNewTag(context, input),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTagChips(
    BuildContext context,
    List<String> allTags,
    List<String> defaultTags,
  ) {
    final chips = List<Widget>.empty(growable: true);

    for (var tag in defaultTags) {
      TagFilterChip chip = TagFilterChip(
        tag: tag,
        selected: true,
        onTagChipPressed: (_) => onTagChipPressed(context, tag),
        invertColors: true,
      );

      chips.add(chip);
    }

    for (var tag in allTags) {
      if (defaultTags.contains(tag)) continue;

      TagFilterChip chip = TagFilterChip(
        tag: tag,
        selected: defaultTags.contains(tag),
        onTagChipPressed: (_) => onTagChipPressed(context, tag),
        invertColors: true,
      );

      chips.add(chip);
    }

    return chips;
  }
}
