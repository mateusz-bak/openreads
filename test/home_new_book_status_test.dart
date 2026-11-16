import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:openreads/core/constants/enums/enums.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_finished_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_for_later_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_in_progress_books_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_unfinished_books_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/logic/cubit/book_lists_order_cubit.dart';
import 'package:openreads/logic/cubit/books_tab_index_cubit.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/default_book_tags_cubit.dart';
import 'package:openreads/logic/cubit/display_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/logic/cubit/selected_books_cubit.dart';
import 'package:openreads/main.dart';
import 'package:openreads/ui/home_screen/home_screen.dart';
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

void main() {
  late Directory tempDir;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactoryOrNull = databaseFactoryFfi;
    await initializeDateFormatting();
    dateFormat = DateFormat.yMMMMd('en_US');
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    HydratedBloc.storage = _InMemoryStorage();
    tempDir = await Directory.systemTemp.createTemp('openreads_home_test_');
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

  Future<void> pumpHomeAndOpenManualAdd(
    WidgetTester tester, {
    required BooksTabIndexCubit tabIndexCubit,
    required BookListsOrderCubit listsOrderCubit,
    required EditBookCubit editBookCubit,
  }) async {
    final themeBloc = ThemeBloc();
    final welcomeBloc = WelcomeBloc();
    final ratingTypeBloc = RatingTypeBloc();
    final selectedBooksCubit = SelectedBooksCubit();
    final defaultFormatCubit = DefaultBooksFormatCubit();
    final defaultTagsCubit = DefaultBookTagsCubit();
    final editBookCoverCubit = EditBookCoverCubit();
    final displayCubit = DisplayCubit();
    final sortFinished = SortFinishedBooksBloc();
    final sortInProgress = SortInProgressBooksBloc();
    final sortForLater = SortForLaterBooksBloc();
    final sortUnfinished = SortUnfinishedBooksBloc();

    addTearDown(() async {
      await themeBloc.close();
      await welcomeBloc.close();
      await ratingTypeBloc.close();
      await selectedBooksCubit.close();
      await defaultFormatCubit.close();
      await defaultTagsCubit.close();
      await editBookCoverCubit.close();
      await displayCubit.close();
      await sortFinished.close();
      await sortInProgress.close();
      await sortForLater.close();
      await sortUnfinished.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>.value(value: themeBloc),
          BlocProvider<WelcomeBloc>.value(value: welcomeBloc),
          BlocProvider<RatingTypeBloc>.value(value: ratingTypeBloc),
          BlocProvider<SelectedBooksCubit>.value(value: selectedBooksCubit),
          BlocProvider<DefaultBooksFormatCubit>.value(
              value: defaultFormatCubit),
          BlocProvider<DefaultBookTagsCubit>.value(value: defaultTagsCubit),
          BlocProvider<EditBookCubit>.value(value: editBookCubit),
          BlocProvider<EditBookCoverCubit>.value(value: editBookCoverCubit),
          BlocProvider<DisplayCubit>.value(value: displayCubit),
          BlocProvider<BooksTabIndexCubit>.value(value: tabIndexCubit),
          BlocProvider<BookListsOrderCubit>.value(value: listsOrderCubit),
          BlocProvider<SortFinishedBooksBloc>.value(value: sortFinished),
          BlocProvider<SortInProgressBooksBloc>.value(value: sortInProgress),
          BlocProvider<SortForLaterBooksBloc>.value(value: sortForLater),
          BlocProvider<SortUnfinishedBooksBloc>.value(value: sortUnfinished),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets(
    'adding a book manually pre-selects the status of the active list tab',
    (WidgetTester tester) async {
      final tabIndexCubit = BooksTabIndexCubit();
      final listsOrderCubit = BookListsOrderCubit();
      final editBookCubit = EditBookCubit();
      addTearDown(() async {
        await tabIndexCubit.close();
        await listsOrderCubit.close();
        await editBookCubit.close();
      });

      await pumpHomeAndOpenManualAdd(
        tester,
        tabIndexCubit: tabIndexCubit,
        listsOrderCubit: listsOrderCubit,
        editBookCubit: editBookCubit,
      );

      // Tap the "For later" chip (index 2 in default BookListsOrderCubit).
      await tester.tap(find.text(LocaleKeys.books_for_later));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(LocaleKeys.add_manually));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(editBookCubit.state.status, BookStatus.forLater);
    },
  );

  testWidgets(
    'adding a book manually respects custom BookListsOrderCubit ordering',
    (WidgetTester tester) async {
      final tabIndexCubit = BooksTabIndexCubit();
      // Move unfinished (index 3) to index 0.
      final listsOrderCubit = BookListsOrderCubit()..updateOrder(3, 0);
      final editBookCubit = EditBookCubit();
      addTearDown(() async {
        await tabIndexCubit.close();
        await listsOrderCubit.close();
        await editBookCubit.close();
      });

      await pumpHomeAndOpenManualAdd(
        tester,
        tabIndexCubit: tabIndexCubit,
        listsOrderCubit: listsOrderCubit,
        editBookCubit: editBookCubit,
      );

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text(LocaleKeys.add_manually));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(editBookCubit.state.status, BookStatus.unfinished);
    },
  );
}
