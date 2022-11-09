import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BookTextField extends StatefulWidget {
  const BookTextField({
    Key? key,
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
    this.onSubmitted,
  }) : super(key: key);

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

  @override
  State<BookTextField> createState() => _BookTextFieldState();
}

class _BookTextFieldState extends State<BookTextField> {
  final FocusNode focusNode = FocusNode();
  bool showClearButton = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).backgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Scrollbar(
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
          onChanged: (text) {
            setState(() {
              if (text.isNotEmpty) {
                showClearButton = true;
              } else {
                showClearButton = false;
              }
            });
          },
          onSubmitted: widget.onSubmitted ?? (_) {},
          decoration: InputDecoration(
            labelText: widget.hint,
            icon: (widget.icon != null) ? Icon(widget.icon) : null,
            border: InputBorder.none,
            counterText: widget.hideCounter ? "" : null,
            suffixIcon: showClearButton
                ? IconButton(
                    onPressed: () {
                      widget.controller.clear();
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
    );
  }
}
