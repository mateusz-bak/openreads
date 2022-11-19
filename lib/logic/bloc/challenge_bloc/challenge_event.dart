part of 'challenge_bloc.dart';

abstract class ChallengeEvent extends Equatable {
  const ChallengeEvent();
}

class ChangeChallengeEvent extends ChallengeEvent {
  final int? books;
  final int? pages;

  const ChangeChallengeEvent({
    required this.books,
    required this.pages,
  });

  @override
  List<Object?> get props => [books, pages];
}
