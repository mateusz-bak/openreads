import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'challenge_state.dart';
part 'challenge_event.dart';

class ChallengeBloc extends HydratedBloc<ChallengeEvent, ChallengeState> {
  ChallengeBloc() : super(UnsetChallengeState()) {
    on<ChangeChallengeEvent>((event, emit) {
      if (event.books == null && event.pages == null) {
        emit(UnsetChallengeState());
      } else {
        emit(SetChallengeState(
          books: event.books,
          pages: event.pages,
        ));
      }
    });
  }

  @override
  ChallengeState? fromJson(Map<String, dynamic> json) {
    final books = json['books'] as int?;
    final pages = json['pages'] as int?;

    if (books == null && pages == null) {
      return UnsetChallengeState();
    } else {
      return SetChallengeState(
        books: books,
        pages: pages,
      );
    }
  }

  @override
  Map<String, dynamic>? toJson(ChallengeState state) {
    if (state is SetChallengeState) {
      return {
        'books': state.books,
        'pages': state.pages,
      };
    } else {
      return {
        'books': null,
        'pages': null,
      };
    }
  }
}
