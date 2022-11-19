part of 'challenge_bloc.dart';

abstract class ChallengeState extends Equatable {
  const ChallengeState();
}

class SetChallengeState extends ChallengeState {
  final int? books;
  final int? pages;

  const SetChallengeState({
    required this.books,
    required this.pages,
  });

  @override
  List<Object?> get props => [books, pages];
}

class UnsetChallengeState extends ChallengeState {
  @override
  List<Object?> get props => [];
}
