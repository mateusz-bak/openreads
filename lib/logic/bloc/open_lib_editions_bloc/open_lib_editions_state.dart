part of 'open_lib_editions_bloc.dart';

abstract class OpenLibEditionsState extends Equatable {
  const OpenLibEditionsState();
}

class OpenLibEditionsReadyState extends OpenLibEditionsState {
  @override
  List<Object> get props => [];
}

class OpenLibEditionsLoadingState extends OpenLibEditionsState {
  @override
  List<Object> get props => [];
}

class OpenLibEditionsLoadedState extends OpenLibEditionsState {
  const OpenLibEditionsLoadedState();
  @override
  List<Object?> get props => [];
}

class OpenLibEditionsNoInternetState extends OpenLibEditionsState {
  @override
  List<Object?> get props => [];
}
