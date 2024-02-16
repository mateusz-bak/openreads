import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';

part 'rating_type_event.dart';
part 'rating_type_state.dart';

class RatingTypeBloc extends HydratedBloc<RatingTypeEvent, RatingTypeState> {
  RatingTypeBloc() : super(RatingTypeBar()) {
    on<RatingTypeChange>((event, emit) {
      if (event.ratingType == RatingType.number) {
        emit(RatingTypeNumber());
      } else {
        emit(RatingTypeBar());
      }
    });
  }

  @override
  RatingTypeState? fromJson(Map<String, dynamic> json) {
    final ratingType = json['rating_type'] as String?;

    if (ratingType == 'number') {
      return RatingTypeNumber();
    } else {
      return RatingTypeBar();
    }
  }

  @override
  Map<String, dynamic>? toJson(RatingTypeState state) {
    if (state is RatingTypeNumber) {
      return {
        'rating_type': 'number',
      };
    } else {
      return {
        'rating_type': 'bar',
      };
    }
  }
}
