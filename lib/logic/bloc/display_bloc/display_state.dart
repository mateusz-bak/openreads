part of 'display_bloc.dart';

abstract class DisplayState extends Equatable {
  const DisplayState();
}

class GridDisplayState extends DisplayState {
  const GridDisplayState();

  @override
  List<Object?> get props => [];
}

class ListDisplayState extends DisplayState {
  const ListDisplayState();

  @override
  List<Object?> get props => [];
}
