import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openreads/core/themes/app_theme.dart';

class TagsField extends StatefulWidget {
  const TagsField({
    Key? key,
    this.controller,
    this.hint,
    this.icon,
    required this.keyboardType,
    required this.maxLength,
    this.inputFormatters,
    this.autofocus = false,
    this.maxLines = 1,
    this.hideCounter = true,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.onSubmitted,
    this.onEditingComplete,
    this.tags,
    this.selectedTags,
    this.selectTag,
    this.unselectTag,
  }) : super(key: key);

  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool autofocus;
  final int maxLines;
  final bool hideCounter;
  final int maxLength;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Function(String)? onSubmitted;
  final Function()? onEditingComplete;
  final List<String>? tags;
  final List<String>? selectedTags;
  final Function(String)? selectTag;
  final Function(String)? unselectTag;

  @override
  State<TagsField> createState() => _TagsFieldState();
}

class _TagsFieldState extends State<TagsField> {
  final FocusNode focusNode = FocusNode();
  bool showClearButton = false;

  Widget _buildTagChip({required String tag, required bool selected}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: FilterChip(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        side: BorderSide(
          color: Theme.of(context).dividerColor,
          width: 1,
        ),
        label: Text(
          tag,
          style: TextStyle(
            color: selected ? Colors.white : Theme.of(context).mainTextColor,
          ),
        ),
        checkmarkColor: Colors.white,
        selected: selected,
        selectedColor: Theme.of(context).primaryColor,
        onSelected: (newState) {
          if (widget.selectTag == null || widget.unselectTag == null) return;
          newState ? widget.selectTag!(tag) : widget.unselectTag!(tag);
        },
      ),
    );
  }

  List<Widget> _generateTagChips() {
    final chips = List<Widget>.empty(growable: true);

    if (widget.tags == null) {
      return [];
    }

    for (var tag in widget.tags!) {
      chips.add(_buildTagChip(
        tag: tag,
        selected: (widget.selectedTags?.contains(tag) == true) ? true : false,
      ));
    }

    return chips;
  }

  @override
  void initState() {
    super.initState();

    if (widget.controller == null) return;

    widget.controller!.addListener(() {
      setState(() {
        if (widget.controller!.text.isNotEmpty) {
          showClearButton = true;
        } else {
          showClearButton = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius,
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Scrollbar(
            child: TextField(
              autofocus: widget.autofocus,
              keyboardType: widget.keyboardType,
              inputFormatters: widget.inputFormatters,
              textCapitalization: widget.textCapitalization,
              controller: widget.controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: widget.maxLines,
              maxLength: widget.maxLength,
              textInputAction: widget.textInputAction,
              style: const TextStyle(fontSize: 14),
              onSubmitted: widget.onSubmitted,
              onEditingComplete: widget.onEditingComplete,
              decoration: InputDecoration(
                labelText: widget.hint,
                icon: (widget.icon != null) ? Icon(widget.icon) : null,
                border: InputBorder.none,
                counterText: widget.hideCounter ? "" : null,
                suffixIcon: showClearButton
                    ? IconButton(
                        onPressed: () {
                          if (widget.controller == null) return;

                          widget.controller!.clear();
                          setState(() {
                            showClearButton = false;
                          });
                          focusNode.requestFocus();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 2.5,
                  ),
                  child: Wrap(
                    children: _generateTagChips(),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
