part of 'open_lib_editions_bloc.dart';

abstract class OpenLibEditionsEvent extends Equatable {
  const OpenLibEditionsEvent();
}

class LoadApiEditionsEvent extends OpenLibEditionsEvent {
  final String query;

  const LoadApiEditionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ReadyEditionsEvent extends OpenLibEditionsEvent {
  @override
  List<Object?> get props => [];
}

class NoInternetEditionsEvent extends OpenLibEditionsEvent {
  @override
  List<Object?> get props => [];
}
