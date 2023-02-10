part of 'open_lib_bloc.dart';

abstract class OpenLibEvent extends Equatable {
  const OpenLibEvent();
}

class LoadApiEvent extends OpenLibEvent {
  final String query;
  final int offset;
  const LoadApiEvent(this.query, this.offset);

  @override
  List<Object?> get props => [query];
}

class ReadyEvent extends OpenLibEvent {
  @override
  List<Object?> get props => [];
}

class NoInternetEvent extends OpenLibEvent {
  @override
  List<Object?> get props => [];
}
