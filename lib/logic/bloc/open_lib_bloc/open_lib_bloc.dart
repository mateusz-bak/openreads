import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/model/ol_search_result.dart';

part 'open_lib_event.dart';
part 'open_lib_state.dart';

class OpenLibBloc extends Bloc<OpenLibEvent, OpenLibState> {
  final OpenLibraryService _openLibraryService;
  final ConnectivityService _connectivityService;

  OpenLibBloc(
    this._openLibraryService,
    this._connectivityService,
  ) : super(OpenLibLoadingState()) {
    _connectivityService.connectivityStream.stream.listen((event) {
      if (event == ConnectivityResult.none) {
        add(NoInternetEvent());
      } else {
        add(ReadyEvent());
      }
    });

    on<LoadApiEvent>((event, emit) async {
      emit(OpenLibLoadingState());

      // final result = await _openLibraryService.getResults(
      //   event.query,
      //   event.offset,
      // );

      // emit(OpenLibLoadedState(
      //   result.docs,
      //   result.numFound,
      //   result.numFoundExact,
      // ));
    });

    on<ReadyEvent>((event, emit) {
      emit(OpenLibReadyState());
    });

    on<NoInternetEvent>((event, emit) {
      emit(OpenLibNoInternetState());
    });
  }
}
