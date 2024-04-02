import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import 'package:openreads/core/themes/app_theme.dart';

class BookTextField extends StatefulWidget {
  const BookTextField({
    super.key,
    required this.controller,
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
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.onSubmitted,
    this.suggestions,
  });

  final TextEditingController controller;
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
  final EdgeInsets padding;
  final List<String>? suggestions;

  @override
  State<BookTextField> createState() => _BookTextFieldState();
}

class _BookTextFieldState extends State<BookTextField> {
  bool showClearButton = false;

  @override
  void initState() {
    super.initState();

    if (widget.controller.text.isNotEmpty) {
      showClearButton = true;
    }

    widget.controller.addListener(() {
      setState(() {
        if (widget.controller.text.isNotEmpty) {
          showClearButton = true;
        } else {
          showClearButton = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(cornerRadius),
          border: Border.all(color: dividerColor),
        ),
        child: Scrollbar(
          child: widget.suggestions != null && widget.suggestions!.isNotEmpty
              ? _buildTypeAheadField()
              : _buildTextField(context),
        ),
      ),
    );
  }

  TypeAheadField<String> _buildTypeAheadField() {
    return TypeAheadField(
        controller: widget.controller,
        hideOnLoading: true,
        hideOnEmpty: true,
        itemBuilder: (context, suggestion) {
          return Container(
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: ListTile(
              title: Text(suggestion),
            ),
          );
        },
        decorationBuilder: (context, child) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(color: dividerColor),
            ),
            child: child,
          );
        },
        suggestionsCallback: (pattern) {
          return widget.suggestions!.where((String option) {
            return option.toLowerCase().startsWith(pattern.toLowerCase());
          }).toList();
        },
        onSelected: (suggestion) {
          widget.controller.text = suggestion;
        },
        builder: (_, __, focusNode) {
          return _buildTextField(context, focusNode: focusNode);
        });
  }

  TextField _buildTextField(
    BuildContext context, {
    FocusNode? focusNode,
  }) {
    return TextField(
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
      onSubmitted: widget.onSubmitted ?? (_) {},
      decoration: InputDecoration(
        labelText: widget.hint,
        labelStyle: const TextStyle(fontSize: 14),
        icon: (widget.icon != null)
            ? Icon(
                widget.icon,
                color: Theme.of(context).colorScheme.primary,
              )
            : null,
        border: InputBorder.none,
        counterText: widget.hideCounter ? "" : null,
        suffixIcon: showClearButton
            ? IconButton(
                onPressed: () {
                  widget.controller.clear();
                  setState(() {
                    showClearButton = false;
                  });
                  focusNode?.requestFocus();
                },
                icon: const Icon(Icons.clear),
              )
            : null,
      ),
    );
  }
}
