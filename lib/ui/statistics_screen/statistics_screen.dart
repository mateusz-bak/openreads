import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/stats_bloc/stats_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/main.dart';
import 'package:openreads/model/book.dart';

import 'package:openreads/ui/statistics_screen/widgets/statistics.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late FocusNode _focusNode;

  void _setChallenge(int books, int pages, int year) {
    BlocProvider.of<ChallengeBloc>(context).add(
      ChangeChallengeEvent(
        books: (books == 0) ? null : books,
        pages: (pages == 0) ? null : pages,
        year: year,
      ),
    );
  }

  @override
  void initState() {
    _focusNode = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state is SetThemeState) {
          return Padding(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            child: StreamBuilder<List<Book>>(
                stream: bookCubit.allBooks,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return BlocProvider(
                      create: (context) =>
                          StatsBloc()..add(StatsLoad(snapshot.data!)),
                      child: SelectableRegion(
                        selectionControls: materialTextSelectionControls,
                        focusNode: _focusNode,
                        child: BlocBuilder<StatsBloc, StatsState>(
                          builder: (context, state) {
                            if (state is StatsLoaded) {
                              return Statistics(
                                state: state,
                                setChallenge: _setChallenge,
                              );
                            } else if (state is StatsError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(50),
                                  child: Text(
                                    state.msg,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Center(
                                child: Platform.isIOS
                                    ? CupertinoActivityIndicator(
                                        radius: 20,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      )
                                    : LoadingAnimationWidget.fourRotatingDots(
                                        color: Theme.of(context).primaryColor,
                                        size: 42,
                                      ),
                              );
                            }
                          },
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox();
                  }
                }),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
