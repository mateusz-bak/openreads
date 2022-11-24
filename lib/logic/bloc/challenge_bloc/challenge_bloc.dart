import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/model/yearly_challenge.dart';

part 'challenge_state.dart';
part 'challenge_event.dart';

class ChallengeBloc extends HydratedBloc<ChallengeEvent, ChallengeState> {
  String? _yearlyChallenges;

  ChallengeBloc() : super(const SetChallengeState()) {
    on<RemoveAllChallengesEvent>((event, emit) {
      _yearlyChallenges = null;
      emit(SetChallengeState(yearlyChallenges: _yearlyChallenges));
    });
    on<RestoreChallengesEvent>((event, emit) {
      _yearlyChallenges = event.challenges;
      emit(SetChallengeState(yearlyChallenges: _yearlyChallenges));
    });
    on<ChangeChallengeEvent>((event, emit) {
      if (_yearlyChallenges == null) {
        final newJson = json
            .encode(YearlyChallenge(
              year: event.year,
              books: event.books,
              pages: event.pages,
            ).toJSON())
            .toString();

        _yearlyChallenges = [
          newJson,
        ].join('|||||');
      } else {
        final splittedReadingChallenges = _yearlyChallenges!.split('|||||');

        splittedReadingChallenges.removeWhere((element) {
          final decodedReadingChallenge = YearlyChallenge.fromJSON(
            jsonDecode(element),
          );

          return decodedReadingChallenge.year == event.year;
        });

        splittedReadingChallenges.add(json
            .encode(YearlyChallenge(
              year: event.year,
              books: event.books,
              pages: event.pages,
            ).toJSON())
            .toString());

        _yearlyChallenges = splittedReadingChallenges.join('|||||');
      }

      emit(SetChallengeState(yearlyChallenges: _yearlyChallenges));
    });
  }

  @override
  ChallengeState? fromJson(Map<String, dynamic> json) {
    final yearlyChallenges = json['reading_challenges'] as String?;

    _yearlyChallenges = yearlyChallenges;
    return SetChallengeState(
      yearlyChallenges: _yearlyChallenges,
    );
  }

  @override
  Map<String, dynamic>? toJson(ChallengeState state) {
    if (state is SetChallengeState) {
      return {
        'reading_challenges': state.yearlyChallenges,
      };
    } else {
      return {
        'reading_challenges': null,
      };
    }
  }
}
