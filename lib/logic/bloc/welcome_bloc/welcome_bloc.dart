import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'welcome_state.dart';
part 'welcome_event.dart';

class WelcomeBloc extends HydratedBloc<WelcomeEvent, WelcomeState> {
  WelcomeBloc() : super(ShowWelcomeState()) {
    on<ChangeWelcomeEvent>((event, emit) {
      if (event.showWelcome) {
        emit(ShowWelcomeState());
      } else {
        emit(HideWelcomeState());
      }
    });
  }

  @override
  WelcomeState? fromJson(Map<String, dynamic> json) {
    final storedValue = json['welcome_state'] as int;

    switch (storedValue) {
      case 0:
        return HideWelcomeState();
      default:
        return ShowWelcomeState();
    }
  }

  @override
  Map<String, dynamic>? toJson(WelcomeState state) {
    if (state is ShowWelcomeState) {
      return {'welcome_state': 1};
    } else {
      return {'welcome_state': 0};
    }
  }
}
