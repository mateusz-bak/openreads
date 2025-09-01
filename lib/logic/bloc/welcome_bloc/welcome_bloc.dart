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
    final showWelcomeScreen = json['show_welcome_screen'] as bool?;

    if (showWelcomeScreen == false) {
      return HideWelcomeState();
      // return HideWelcomeState();
    } else {
      return ShowWelcomeState();
    }
  }

  @override
  Map<String, dynamic>? toJson(WelcomeState state) {
    if (state is ShowWelcomeState) {
      return {
        'show_welcome_screen': true,
      };
    } else if (state is HideWelcomeState) {
      return {
        'show_welcome_screen': false,
      };
    } else {
      return null;
    }
  }
}
