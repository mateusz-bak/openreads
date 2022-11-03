import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'outlines_state.dart';
part 'outlines_event.dart';

class OutlinesBloc extends HydratedBloc<OutlinesEvent, OutlinesState> {
  OutlinesBloc() : super(ShowOutlinesState()) {
    on<ChangeOutlinesEvent>((event, emit) {
      if (event.showOutlines) {
        emit(ShowOutlinesState());
      } else {
        emit(HideOutlinesState());
      }
    });
  }

  @override
  OutlinesState? fromJson(Map<String, dynamic> json) {
    final storedValue = json['OutlinesState'] as int;

    switch (storedValue) {
      case 0:
        return HideOutlinesState();
      default:
        return ShowOutlinesState();
    }
  }

  @override
  Map<String, dynamic>? toJson(OutlinesState state) {
    if (state is ShowOutlinesState) {
      return {'OutlinesState': 1};
    } else {
      return {'OutlinesState': 0};
    }
  }
}
