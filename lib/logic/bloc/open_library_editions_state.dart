part of 'open_library_editions_bloc.dart';

abstract class OpenLibraryEditionsState extends Equatable {
  const OpenLibraryEditionsState();
}

class OpenLibraryEditionsReadyState extends OpenLibraryEditionsState {
  @override
  List<Object> get props => [];
}

class OpenLibraryEditionsLoadingState extends OpenLibraryEditionsState {
  @override
  List<Object> get props => [];
}

class OpenLibraryEditionsLoadedState extends OpenLibraryEditionsState {
  const OpenLibraryEditionsLoadedState();
  @override
  List<Object?> get props => [];
}

class OpenLibraryEditionsNoInternetState extends OpenLibraryEditionsState {
  @override
  List<Object?> get props => [];
}
