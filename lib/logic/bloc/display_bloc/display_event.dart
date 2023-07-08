part of 'display_bloc.dart';

abstract class DisplayEvent extends Equatable {
  const DisplayEvent();
}

class ChangeDisplayEvent extends DisplayEvent {
  final bool displayAsGrid;

  const ChangeDisplayEvent({
    required this.displayAsGrid,
  });

  @override
  List<Object?> get props => [
        displayAsGrid,
      ];
}
