part of 'outlines_bloc.dart';

abstract class OutlinesEvent extends Equatable {
  const OutlinesEvent();
}

class ChangeOutlinesEvent extends OutlinesEvent {
  const ChangeOutlinesEvent(this.showOutlines);

  final bool showOutlines;

  @override
  List<Object?> get props => [showOutlines];
}
