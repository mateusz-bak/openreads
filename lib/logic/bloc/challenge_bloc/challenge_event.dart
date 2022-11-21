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

class RemoveChallengeEvent extends ChallengeEvent {
  const RemoveChallengeEvent();

  @override
  List<Object?> get props => [];
}
