import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/open_library_search_bloc/open_library_search_bloc.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/default_book_tags_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/search_ol_screen/search_ol_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class _InMemoryStorage implements Storage {
  final Map<String, dynamic> _store = <String, dynamic>{};

  @override
  dynamic read(String key) => _store[key];

  @override
  Future<void> write(String key, dynamic value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Future<void> clear() async {
    _store.clear();
  }

  @override
  Future<void> close() async {}
}

class _NotFoundHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _NotFoundHttpClient();
  }
}

class _NotFoundHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _NotFoundRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _NotFoundRequest(url);

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NotFoundRequest implements HttpClientRequest {
  _NotFoundRequest(this.uri);

  @override
  final Uri uri;

  @override
  final HttpHeaders headers = _EmptyHeaders();

  @override
  bool followRedirects = true;

  @override
  int maxRedirects = 5;

  @override
  int contentLength = -1;

  @override
  Future<void> addStream(Stream<List<int>> stream) async {
    await stream.drain<void>();
  }

  @override
  Future<HttpClientResponse> close() async => _NotFoundResponse();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _EmptyHeaders implements HttpHeaders {
  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _NotFoundResponse extends Stream<List<int>>
    implements HttpClientResponse {
  @override
  int get statusCode => 404;

  @override
  int get contentLength => 0;

  @override
  HttpHeaders get headers => _EmptyHeaders();

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  String get reasonPhrase => 'Not Found';

  @override
  List<RedirectInfo> get redirects => const [];

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) =>
      const Stream<List<int>>.empty().listen(
        onData,
        onError: onError,
        onDone: onDone,
        cancelOnError: cancelOnError,
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactoryOrNull = databaseFactoryFfi;
    await initializeDateFormatting();
    dateFormat = DateFormat.yMMMMd('en_US');
    HttpOverrides.global = _NotFoundHttpOverrides();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    HydratedBloc.storage = _InMemoryStorage();
    tempDir = await Directory.systemTemp.createTemp('openreads_test_');
    appDocumentsDirectory = tempDir;
    appTempDirectory = tempDir;
    bookCubit = BookCubit();
  });

  tearDown(() async {
    await bookCubit.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  Future<void> pumpSearchAndTapManualAdd(
    WidgetTester tester, {
    required List<String> defaultTags,
    required BookStatus status,
    required BookFormat defaultFormat,
    required EditBookCubit editBookCubit,
  }) async {
    final searchBloc = OpenLibrarySearchBloc()
      ..add(const OpenLibrarySearchSetISBN());
    final defaultTagsCubit = DefaultBookTagsCubit();
    for (final tag in defaultTags) {
      defaultTagsCubit.updateTag(tag);
    }
    final defaultFormatCubit = DefaultBooksFormatCubit()
      ..setBookFormat(defaultFormat);
    final editBookCoverCubit = EditBookCoverCubit();
    final themeBloc = ThemeBloc();
    final ratingTypeBloc = RatingTypeBloc();

    addTearDown(() async {
      await searchBloc.close();
      await defaultTagsCubit.close();
      await defaultFormatCubit.close();
      await editBookCoverCubit.close();
      await themeBloc.close();
      await ratingTypeBloc.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<OpenLibrarySearchBloc>.value(value: searchBloc),
          BlocProvider<DefaultBookTagsCubit>.value(value: defaultTagsCubit),
          BlocProvider<DefaultBooksFormatCubit>.value(
              value: defaultFormatCubit),
          BlocProvider<EditBookCubit>.value(value: editBookCubit),
          BlocProvider<EditBookCoverCubit>.value(value: editBookCoverCubit),
          BlocProvider<ThemeBloc>.value(value: themeBloc),
          BlocProvider<RatingTypeBloc>.value(value: ratingTypeBloc),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              AppTheme.init(themeBloc.state as SetThemeState, context);
              return SearchOLScreen(status: status);
            },
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.enterText(find.byType(TextField), '9780000000000');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    await tester.tap(find.text(LocaleKeys.click_to_add_book_manually));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'adding manually from failed ISBN search respects empty default tags and widget status',
    (WidgetTester tester) async {
      final editBookCubit = EditBookCubit();
      addTearDown(editBookCubit.close);

      await pumpSearchAndTapManualAdd(
        tester,
        defaultTags: const [],
        status: BookStatus.forLater,
        defaultFormat: BookFormat.ebook,
        editBookCubit: editBookCubit,
      );

      expect(editBookCubit.state.tags, isNull);
      expect(editBookCubit.state.status, BookStatus.forLater);
      expect(editBookCubit.state.bookFormat, BookFormat.ebook);
      expect(editBookCubit.state.isbn, '9780000000000');
    },
  );

  testWidgets(
    'adding manually from failed ISBN search applies configured default tags',
    (WidgetTester tester) async {
      final editBookCubit = EditBookCubit();
      addTearDown(editBookCubit.close);

      await pumpSearchAndTapManualAdd(
        tester,
        defaultTags: const ['wishlist', 'sci-fi'],
        status: BookStatus.inProgress,
        defaultFormat: BookFormat.hardcover,
        editBookCubit: editBookCubit,
      );

      expect(editBookCubit.state.tags, 'wishlist|||||sci-fi');
      expect(editBookCubit.state.status, BookStatus.inProgress);
      expect(editBookCubit.state.bookFormat, BookFormat.hardcover);
    },
  );
}
