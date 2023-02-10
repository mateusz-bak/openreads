part of 'open_lib_bloc.dart';

abstract class OpenLibState extends Equatable {
  const OpenLibState();
}

class OpenLibReadyState extends OpenLibState {
  @override
  List<Object> get props => [];
}

class OpenLibLoadingState extends OpenLibState {
  @override
  List<Object> get props => [];
}

class OpenLibLoadedState extends OpenLibState {
  final List<OLSearchResultDoc>? docs;
  final int? numFound;
  final bool? numFoundExact;

  const OpenLibLoadedState(this.docs, this.numFound, this.numFoundExact);
  @override
  List<Object?> get props => [docs, numFound, numFoundExact];
}

class OpenLibNoInternetState extends OpenLibState {
  @override
  List<Object?> get props => [];
}
