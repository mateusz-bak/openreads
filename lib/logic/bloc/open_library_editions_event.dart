part of 'open_library_editions_bloc.dart';

abstract class OpenLibraryEditionsEvent extends Equatable {
  const OpenLibraryEditionsEvent();
}

class LoadApiEditionsEvent extends OpenLibraryEditionsEvent {
  final String query;

  const LoadApiEditionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ReadyEditionsEvent extends OpenLibraryEditionsEvent {
  @override
  List<Object?> get props => [];
}

class NoInternetEditionsEvent extends OpenLibraryEditionsEvent {
  @override
  List<Object?> get props => [];
}
