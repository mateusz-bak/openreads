part of 'challenge_bloc.dart';

abstract class ChallengeState extends Equatable {
  const ChallengeState();
}

class SetChallengeState extends ChallengeState {
  final String? yearlyChallenges;

  const SetChallengeState({
    this.yearlyChallenges,
  });

  @override
  List<Object?> get props => [yearlyChallenges];
}
