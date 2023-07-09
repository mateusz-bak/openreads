import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'display_state.dart';
part 'display_event.dart';

class DisplayBloc extends HydratedBloc<DisplayEvent, DisplayState> {
  DisplayBloc() : super(const ListDisplayState()) {
    on<ChangeDisplayEvent>((event, emit) {
      if (event.displayAsGrid) {
        emit(const GridDisplayState());
      } else {
        emit(const ListDisplayState());
      }
    });
  }

  @override
  DisplayState? fromJson(Map<String, dynamic> json) {
    final displayAsGrid = json['display_as_grid'] as bool?;

    switch (displayAsGrid) {
      case true:
        return const GridDisplayState();
      default:
        return const ListDisplayState();
    }
  }

  @override
  Map<String, dynamic>? toJson(DisplayState state) {
    if (state is GridDisplayState) {
      return {'display_as_grid': true};
    } else {
      return {
        'display_as_grid': false,
      };
    }
  }
}
