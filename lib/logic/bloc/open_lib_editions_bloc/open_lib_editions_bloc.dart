import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:openreads/model/ol_edition_result.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:rxdart/rxdart.dart';

part 'open_lib_editions_event.dart';
part 'open_lib_editions_state.dart';

class OpenLibEditionsBloc
    extends Bloc<OpenLibEditionsEvent, OpenLibEditionsState> {
  final OpenLibraryService _openLibraryService;
  final ConnectivityService _connectivityService;

  final BehaviorSubject<List<OLEditionResult>> _editionsListFetcher =
      BehaviorSubject<List<OLEditionResult>>();
  Stream<List<OLEditionResult>> get editionsList => _editionsListFetcher;

  OpenLibEditionsBloc(
    this._openLibraryService,
    this._connectivityService,
  ) : super(OpenLibEditionsLoadingState()) {
    _connectivityService.connectivityStream.stream.listen((event) {
      if (event == ConnectivityResult.none) {
        add(NoInternetEditionsEvent());
      } else {
        add(ReadyEditionsEvent());
      }
    });

    on<LoadApiEditionsEvent>((event, emit) async {
      final result = await _openLibraryService.getEdition(
        event.query,
      );

      if (_editionsListFetcher.hasValue) {
        List<OLEditionResult> list = _editionsListFetcher.value;
        list.add(result);
        _editionsListFetcher.sink.add(list);
      } else {
        final list = List<OLEditionResult>.empty(growable: true);
        list.add(result);
        _editionsListFetcher.sink.add(list);
      }

      emit(const OpenLibEditionsLoadedState());
    });

    on<ReadyEditionsEvent>((event, emit) {
      if (_editionsListFetcher.hasValue) {
        List<OLEditionResult> list = _editionsListFetcher.value;
        list.clear();
        _editionsListFetcher.sink.add(list);
      }
      emit(OpenLibEditionsReadyState());
    });

    on<NoInternetEditionsEvent>((event, emit) {
      emit(OpenLibEditionsNoInternetState());
    });
  }
}
