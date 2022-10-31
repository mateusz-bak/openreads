part of 'open_library_bloc.dart';

abstract class OpenLibraryState extends Equatable {
  const OpenLibraryState();
}

class OpenLibraryReadyState extends OpenLibraryState {
  @override
  List<Object> get props => [];
}

class OpenLibraryLoadingState extends OpenLibraryState {
  @override
  List<Object> get props => [];
}

class OpenLibraryLoadedState extends OpenLibraryState {
  final List<Doc>? docs;
  final int? numFound;
  final bool? numFoundExact;

  const OpenLibraryLoadedState(this.docs, this.numFound, this.numFoundExact);
  @override
  List<Object?> get props => [docs, numFound, numFoundExact];
}

class OpenLibraryNoInternetState extends OpenLibraryState {
  @override
  List<Object?> get props => [];
}
