import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';

class ChallengeDialog extends StatefulWidget {
  const ChallengeDialog({
    super.key,
    required this.setChallenge,
    required this.year,
    this.booksTarget,
    this.pagesTarget,
  });

  final Function(int, int, int) setChallenge;
  final int? booksTarget;
  final int? pagesTarget;
  final int year;

  @override
  State<ChallengeDialog> createState() => _ChallengeDialogState();
}

class _ChallengeDialogState extends State<ChallengeDialog>
    with TickerProviderStateMixin {
  static const double minBooks = 0;
  static const double maxBooks = 50;

  static const double minPages = 0;
  static const double maxPages = 15000;

  double _booksSliderValue = 0;
  double _pagesSliderValue = 0;
  bool _showPagesChallenge = false;

  int? _booksTarget;
  int? _pagesTarget;

  final _booksController = TextEditingController();
  final _pagesController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void dispose() {
    _booksController.dispose();
    _pagesController.dispose();
    _animController.dispose();

    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _booksController.addListener(() {
      try {
        final newValue = double.parse(_booksController.text);

        setState(() {
          if (newValue > maxBooks) {
            _booksSliderValue = maxBooks;
          } else if (newValue < minBooks) {
            _booksSliderValue = minBooks;
          } else {
            _booksSliderValue = newValue;
          }

          _booksTarget = newValue.toInt();
        });
      } catch (error) {
        return;
      }
    });

    void prefillBooksTarget() {
      _booksTarget = widget.booksTarget;
      _booksController.text = widget.booksTarget.toString();

      if (widget.booksTarget! > maxBooks.toInt()) {
        _booksSliderValue = maxBooks;
      } else if (widget.booksTarget! < minBooks.toInt()) {
        _booksSliderValue = minBooks;
      } else {
        _booksSliderValue = widget.booksTarget!.toDouble();
      }
    }

    void prefillPagesTarget() {
      _showPagesChallenge = true;
      _animController.forward();
      _pagesTarget = widget.pagesTarget;
      _pagesController.text = widget.pagesTarget.toString();

      if (widget.pagesTarget! > maxPages.toInt()) {
        _pagesSliderValue = maxPages;
      } else if (widget.pagesTarget! < minPages.toInt()) {
        _pagesSliderValue = minPages;
      } else {
        _pagesSliderValue = widget.pagesTarget!.toDouble();
      }
    }

    _pagesController.addListener(() {
      try {
        final newValue = double.parse(_pagesController.text);

        setState(() {
          if (newValue > maxPages) {
            _pagesSliderValue = maxPages;
          } else if (newValue < minPages) {
            _pagesSliderValue = minPages;
          } else {
            _pagesSliderValue = newValue;
          }

          _pagesTarget = newValue.toInt();
        });
      } catch (error) {
        return;
      }
    });

    if (widget.booksTarget != null) {
      prefillBooksTarget();
    }

    if (widget.pagesTarget != null) {
      prefillPagesTarget();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cornerRadius),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${LocaleKeys.set_books_goal_for_year.tr()} ${widget.year}:',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider.adaptive(
              value: _booksSliderValue,
              min: minBooks,
              max: maxBooks,
              divisions: 50,
              label: _booksSliderValue.round().toString(),
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (double value) {
                setState(() {
                  _booksSliderValue = value;
                  _booksController.text = _booksSliderValue.round().toString();
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 150,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    child: Platform.isIOS
                        ? CupertinoTextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller: _booksController,
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(cornerRadius),
                              border: Border.all(color: dividerColor),
                            ),
                            child: TextField(
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              controller: _booksController,
                              style: const TextStyle(fontSize: 14),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Switch.adaptive(
                  value: _showPagesChallenge,
                  activeColor: Theme.of(context).colorScheme.primary,
                  onChanged: (value) {
                    setState(() {
                      _showPagesChallenge = value;
                    });

                    if (value) {
                      _animController.forward();
                    } else {
                      _animController.animateBack(0,
                          duration: const Duration(
                            milliseconds: 250,
                          ));
                    }
                  },
                ),
                const SizedBox(width: 10),
                Text(
                  LocaleKeys.add_pages_goal.tr(),
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizeTransition(
              sizeFactor: _animation,
              child: Column(
                children: [
                  Text(
                    LocaleKeys.set_pages_goal.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Slider.adaptive(
                    value: _pagesSliderValue,
                    min: minPages,
                    max: maxPages,
                    divisions: 150,
                    label: _pagesSliderValue.round().toString(),
                    activeColor: Theme.of(context).colorScheme.primary,
                    onChanged: (double value) {
                      setState(() {
                        _pagesSliderValue = value;
                        _pagesController.text =
                            _pagesSliderValue.round().toString();
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 150,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          child: Platform.isIOS
                              ? CupertinoTextField(
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  controller: _pagesController,
                                )
                              : Container(
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.surface,
                                    borderRadius:
                                        BorderRadius.circular(cornerRadius),
                                    border: Border.all(color: dividerColor),
                                  ),
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    controller: _pagesController,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Platform.isIOS
                ? CupertinoButton(
                    child: const Text("Save"),
                    onPressed: () {
                      widget.setChallenge(
                          _booksTarget ?? 0,
                          _showPagesChallenge ? _pagesTarget ?? 0 : 0,
                          widget.year);

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  )
                : FilledButton(
                    onPressed: () {
                      widget.setChallenge(
                          _booksTarget ?? 0,
                          _showPagesChallenge ? _pagesTarget ?? 0 : 0,
                          widget.year);

                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cornerRadius),
                      ),
                    ),
                    child: const Center(
                      child: Text("Save"),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
