import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/model/open_library_search_result.dart';

part 'open_library_event.dart';
part 'open_library_state.dart';

class OpenLibraryBloc extends Bloc<OpenLibraryEvent, OpenLibraryState> {
  final OpenLibraryService _openLibraryService;
  final ConnectivityService _connectivityService;

  OpenLibraryBloc(
    this._openLibraryService,
    this._connectivityService,
  ) : super(OpenLibraryLoadingState()) {
    _connectivityService.connectivityStream.stream.listen((event) {
      if (event == ConnectivityResult.none) {
        add(NoInternetEvent());
      } else {
        add(ReadyEvent());
      }
    });

    on<LoadApiEvent>((event, emit) async {
      emit(OpenLibraryLoadingState());

      final result = await _openLibraryService.getResults(
        event.query,
        event.offset,
      );

      emit(OpenLibraryLoadedState(
        result.docs,
        result.numFound,
        result.numFoundExact,
      ));
    });

    on<ReadyEvent>((event, emit) {
      emit(OpenLibraryReadyState());
    });

    on<NoInternetEvent>((event, emit) {
      emit(OpenLibraryNoInternetState());
    });
  }
}
