part of 'challenge_bloc.dart';

abstract class ChallengeEvent extends Equatable {
  const ChallengeEvent();
}

class ChangeChallengeEvent extends ChallengeEvent {
  final int year;
  final int? books;
  final int? pages;

  const ChangeChallengeEvent({
    required this.year,
    required this.books,
    required this.pages,
  });

  @override
  List<Object?> get props => [year, books, pages];
}

class RestoreChallengesEvent extends ChallengeEvent {
  final String? challenges;

  const RestoreChallengesEvent({
    required this.challenges,
  });

  @override
  List<Object?> get props => [challenges];
}

class RemoveAllChallengesEvent extends ChallengeEvent {
  const RemoveAllChallengesEvent();

  @override
  List<Object?> get props => [];
}
