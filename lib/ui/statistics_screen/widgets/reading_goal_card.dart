import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:openreads/core/helpers/cross_platform/alert_dialog.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/ui/statistics_screen/widgets/widgets.dart';

class ReadingGoalCard extends StatefulWidget {
  const ReadingGoalCard({
    super.key,
    required this.year,
    required this.booksValue,
    required this.pagesValue,
    required this.setChallenge,
    this.booksTarget,
    this.pagesTarget,
    this.onSharePressed,
    this.isCompact = false,
  });

  final int year;
  final int booksValue;
  final int pagesValue;
  final Function(int, int, int) setChallenge;
  final int? booksTarget;
  final int? pagesTarget;
  final Function()? onSharePressed;
  final bool isCompact;

  @override
  State<ReadingGoalCard> createState() => _ReadingGoalCardState();
}

class _ReadingGoalCardState extends State<ReadingGoalCard> {
  static const int booksStep = 1;
  static const int pagesStep = 500;
  static const double inputHeight = 48;
  static const int maxValue = 999999;

  final _booksController = TextEditingController();
  final _pagesController = TextEditingController();

  bool _isEditing = false;
  bool _showPagesGoal = false;

  bool get _hasGoal => widget.booksTarget != null || widget.pagesTarget != null;

  void _startEditing() {
    _booksController.text = widget.booksTarget?.toString() ?? '0';
    _pagesController.text = widget.pagesTarget?.toString() ?? '0';

    setState(() {
      _showPagesGoal = widget.pagesTarget != null;
      _isEditing = true;
    });
  }

  void _stopEditing() {
    FocusScope.of(context).unfocus();
    setState(() => _isEditing = false);
  }

  void _changeValue(TextEditingController controller, int change) {
    final currentValue = int.tryParse(controller.text) ?? 0;
    final newValue = currentValue + change;

    controller.text = newValue.clamp(0, maxValue).toString();
  }

  Future<void> _saveGoal() async {
    final books = int.tryParse(_booksController.text) ?? 0;
    final pages = _showPagesGoal ? int.tryParse(_pagesController.text) ?? 0 : 0;

    final isChanged = books != (widget.booksTarget ?? 0) ||
        pages != (widget.pagesTarget ?? 0);

    if (!isChanged) {
      _stopEditing();
      return;
    }

    // no confirmation when the goal is set for the first time
    if (_hasGoal) {
      final confirmed = await _showChangeConfirmation();
      if (confirmed != true) return;
    }

    widget.setChallenge(books, pages, widget.year);

    if (!mounted) return;
    _stopEditing();
  }

  Future<bool?> _showChangeConfirmation() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return buildPlatformSpecificAlertDialog(
          title: Text(
            LocaleKeys.are_you_sure.tr(),
          ),
          content: Text(
            LocaleKeys.reading_goal_change_warning.tr(),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: Platform.isIOS
              ? [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(LocaleKeys.no.tr()),
                  ),
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(LocaleKeys.yes.tr()),
                  ),
                ]
              : [
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(LocaleKeys.no.tr()),
                  ),
                  FilledButton.tonal(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(LocaleKeys.yes.tr()),
                  ),
                ],
        );
      },
    );
  }

  @override
  void dispose() {
    _booksController.dispose();
    _pagesController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact && !_isEditing) {
      return _buildCompactButton();
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Card.filled(
      color: colorScheme.primaryContainer.withAlpha(255),
      child: InkWell(
        onTap: _isEditing ? null : _startEditing,
        borderRadius: BorderRadius.circular(cornerRadius),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 10),
                if (_isEditing)
                  _buildEditor()
                else if (_hasGoal)
                  ..._buildProgress()
                else
                  _buildNoGoalText(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompactButton() {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: TextButton.icon(
        onPressed: _startEditing,
        icon: const Icon(Icons.flag_outlined, size: 18),
        label: Text(
          '${LocaleKeys.reading_goal.tr()} ${widget.year}',
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${LocaleKeys.reading_goal.tr()} ${widget.year}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        if (widget.onSharePressed != null && !_isEditing)
          ShareYearButton(onPressed: widget.onSharePressed!),
      ],
    );
  }

  Widget _buildNoGoalText() {
    return Text(
      LocaleKeys.click_here_to_set_challenge.tr(),
      style: TextStyle(
        fontSize: 16,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
    );
  }

  List<Widget> _buildProgress() {
    return [
      if (widget.booksTarget != null)
        _buildProgressRow(
          widget.booksValue,
          widget.booksTarget!,
          LocaleKeys.books_lowercase.tr(),
        ),
      if (widget.booksTarget != null && widget.pagesTarget != null)
        const SizedBox(height: 15),
      if (widget.pagesTarget != null)
        _buildProgressRow(
          widget.pagesValue,
          widget.pagesTarget!,
          LocaleKeys.pages_lowercase.tr(),
        ),
    ];
  }

  Widget _buildProgressRow(int value, int target, String unit) {
    final onCardColor = Theme.of(context).colorScheme.onPrimaryContainer;
    final progress = (value / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$value / $target $unit',
                style: TextStyle(fontSize: 16, color: onCardColor),
              ),
            ),
            Text(
              '${(progress * 100).floor()}%',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onCardColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          minHeight: 10,
          color: onCardColor,
          backgroundColor: onCardColor.withAlpha(50),
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
      ],
    );
  }

  Widget _buildEditor() {
    final onCardColor = Theme.of(context).colorScheme.onPrimaryContainer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGoalInput(
          _booksController,
          booksStep,
          LocaleKeys.books_lowercase.tr(),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                LocaleKeys.add_pages_goal.tr(),
                style: TextStyle(fontSize: 16, color: onCardColor),
              ),
            ),
            Switch.adaptive(
              value: _showPagesGoal,
              onChanged: (value) => setState(() => _showPagesGoal = value),
            ),
          ],
        ),
        if (_showPagesGoal) ...[
          const SizedBox(height: 10),
          _buildGoalInput(
            _pagesController,
            pagesStep,
            LocaleKeys.pages_lowercase.tr(),
          ),
        ],
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              flex: 10,
              child: FilledButton.tonal(
                onPressed: _stopEditing,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                ),
                child: Center(child: Text(LocaleKeys.cancel.tr())),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 19,
              child: FilledButton(
                onPressed: _saveGoal,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cornerRadius),
                  ),
                ),
                child: Center(child: Text(LocaleKeys.save.tr())),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGoalInput(
    TextEditingController controller,
    int step,
    String unit,
  ) {
    return Row(
      children: [
        IconButton.filledTonal(
          onPressed: () => _changeValue(controller, -step),
          icon: const Icon(Icons.remove_rounded),
          style: IconButton.styleFrom(
            minimumSize: const Size.square(inputHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 100,
          height: inputHeight,
          child: _buildNumberField(controller),
        ),
        const SizedBox(width: 5),
        IconButton.filledTonal(
          onPressed: () => _changeValue(controller, step),
          icon: const Icon(Icons.add_rounded),
          style: IconButton.styleFrom(
            minimumSize: const Size.square(inputHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            unit,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField(TextEditingController controller) {
    final inputFormatters = [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(6),
    ];

    if (Platform.isIOS) {
      return CupertinoTextField(
        controller: controller,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        inputFormatters: inputFormatters,
      );
    }

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: inputFormatters,
        style: const TextStyle(fontSize: 16),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
