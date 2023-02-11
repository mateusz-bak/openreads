import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';

class ChallengeDialog extends StatefulWidget {
  const ChallengeDialog({
    Key? key,
    required this.setChallenge,
    required this.year,
    this.booksTarget,
    this.pagesTarget,
  }) : super(key: key);

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
        borderRadius: Theme.of(context).extension<CustomBorder>()?.radius ??
            BorderRadius.circular(5.0),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n.set_books_goal_for_year} ${widget.year}:',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: context.read<ThemeBloc>().fontFamily,
              ),
            ),
            Slider(
              value: _booksSliderValue,
              min: minBooks,
              max: maxBooks,
              divisions: 50,
              label: _booksSliderValue.round().toString(),
              activeColor: Theme.of(context).primaryColor,
              inactiveColor: Theme.of(context).secondaryTextColor,
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
                    width: 100,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).backgroundColor,
                      borderRadius:
                          Theme.of(context).extension<CustomBorder>()?.radius,
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: TextField(
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      controller: _booksController,
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: context.read<ThemeBloc>().fontFamily,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius:
                    Theme.of(context).extension<CustomBorder>()?.radius,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: Row(
                children: [
                  Switch(
                    value: _showPagesChallenge,
                    activeColor: Theme.of(context).primaryColor,
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
                    l10n.add_pages_goal,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: context.read<ThemeBloc>().fontFamily,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizeTransition(
              sizeFactor: _animation,
              child: Column(
                children: [
                  Text(
                    l10n.set_pages_goal,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: context.read<ThemeBloc>().fontFamily,
                    ),
                  ),
                  Slider(
                    value: _pagesSliderValue,
                    min: minPages,
                    max: maxPages,
                    divisions: 150,
                    label: _pagesSliderValue.round().toString(),
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Theme.of(context).secondaryTextColor,
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
                          width: 100,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).backgroundColor,
                            borderRadius: Theme.of(context)
                                .extension<CustomBorder>()
                                ?.radius,
                            border: Border.all(
                                color: Theme.of(context).dividerColor),
                          ),
                          child: TextField(
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller: _pagesController,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: context.read<ThemeBloc>().fontFamily,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
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
            ElevatedButton(
              onPressed: () {
                widget.setChallenge(_booksTarget ?? 0,
                    _showPagesChallenge ? _pagesTarget ?? 0 : 0, widget.year);

                if (mounted) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      Theme.of(context).extension<CustomBorder>()?.radius ??
                          BorderRadius.circular(5.0),
                ),
              ),
              child: Center(
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: context.read<ThemeBloc>().fontFamily,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
