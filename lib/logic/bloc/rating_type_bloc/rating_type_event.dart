part of 'rating_type_bloc.dart';

abstract class RatingTypeEvent extends Equatable {
  const RatingTypeEvent();
}

class RatingTypeChange extends RatingTypeEvent {
  final RatingType ratingType;

  const RatingTypeChange({required this.ratingType});

  @override
  List<Object?> get props => [ratingType];
}
