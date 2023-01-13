part of 'rating_type_bloc.dart';

abstract class RatingTypeState extends Equatable {
  const RatingTypeState();

  @override
  List<Object> get props => [];
}

class RatingTypeBar extends RatingTypeState {}

class RatingTypeNumber extends RatingTypeState {}
