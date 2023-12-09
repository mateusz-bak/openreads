import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'open_library_search_event.dart';
part 'open_library_search_state.dart';

class OpenLibrarySearchBloc
    extends Bloc<OpenLibrarySearchEvent, OpenLibrarySearchState> {
  OpenLibrarySearchBloc() : super(const OpenLibrarySearchGeneral()) {
    on<OpenLibrarySearchSetGeneral>((event, emit) {
      emit(const OpenLibrarySearchGeneral());
    });
    on<OpenLibrarySearchSetAuthor>((event, emit) {
      emit(const OpenLibrarySearchAuthor());
    });
    on<OpenLibrarySearchSetTitle>((event, emit) {
      emit(const OpenLibrarySearchTitle());
    });
    on<OpenLibrarySearchSetISBN>((event, emit) {
      emit(const OpenLibrarySearchISBN());
    });
  }
}
