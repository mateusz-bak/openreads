import 'package:flutter/material.dart';

class BooksTabChip extends StatefulWidget {
  const BooksTabChip({
    super.key,
    required this.selected,
    required this.index,
    required this.changeTab,
    required this.tabController,
    required this.title,
  });

  final bool selected;
  final int index;
  final Function(int) changeTab;
  final TabController tabController;
  final String title;

  @override
  State<BooksTabChip> createState() => _BookTabChipState();
}

class _BookTabChipState extends State<BooksTabChip> {
  _scrollToChip(int index, BuildContext context) {
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void initState() {
    super.initState();
    widget.tabController.addListener(() {
      // Scrolls the chip into view when the tab changes
      if (widget.index == widget.tabController.index) {
        _scrollToChip(widget.index, context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: FilterChip(
        selected: widget.selected,
        label: Text(widget.title),
        visualDensity: VisualDensity.compact,
        showCheckmark: false,
        onSelected: (bool _) {
          _scrollToChip(widget.index, context);
          widget.changeTab(widget.index);
        },
      ),
    );
  }
}
