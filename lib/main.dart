import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
// import 'package:openreads/ui/home_screen/home_screen.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/constants/locale.dart';
import 'package:openreads/core/helpers/locale_delegates/locale_delegates.dart';
import 'package:openreads/core/helpers/old_android_http_overrides.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/display_bloc/display_bloc.dart';
import 'package:openreads/logic/bloc/migration_v1_to_v2_bloc/migration_v1_to_v2_bloc.dart';
import 'package:openreads/logic/bloc/open_lib_bloc/open_lib_bloc.dart';
import 'package:openreads/logic/bloc/open_library_search_bloc/open_library_search_bloc.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/logic/cubit/current_book_cubit.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/welcome_screen/welcome_screen.dart';
import 'package:path_provider/path_provider.dart';

late BookCubit bookCubit;
late Directory appDocumentsDirectory;
late Directory appTempDirectory;
late GlobalKey<ScaffoldMessengerState> snackbarKey;
late DateFormat dateFormat;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  _setAndroidConfig();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );

  appDocumentsDirectory = await getApplicationDocumentsDirectory();
  appTempDirectory = await getTemporaryDirectory();
  snackbarKey = GlobalKey<ScaffoldMessengerState>();

  bookCubit = BookCubit(); // TODO: move to app's context

  final localeCodes = supportedLocales.map((e) => e.locale).toList();

  runApp(
    EasyLocalization(
      supportedLocales: localeCodes,
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      useFallbackTranslations: true,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  _listOfBlocProviders(BuildContext context) {
    final bookProviders = [
      BlocProvider(create: (_) => EditBookCubit()),
      BlocProvider(create: (_) => EditBookCoverCubit()),
      BlocProvider(create: (_) => CurrentBookCubit()),
      BlocProvider(create: (_) => ChallengeBloc()),
    ];

    final settingsProviders = [
      BlocProvider(create: (_) => DefaultBooksFormatCubit()),
      BlocProvider(create: (_) => ThemeBloc()),
      BlocProvider(create: (_) => DisplayBloc()),
      BlocProvider(create: (_) => SortBloc()),
      BlocProvider(create: (_) => WelcomeBloc()),
      BlocProvider(create: (_) => RatingTypeBloc()),
      BlocProvider(create: (_) => MigrationV1ToV2Bloc()),
    ];

    final openLibraryProviders = [
      BlocProvider(create: (_) => OpenLibrarySearchBloc()),
      BlocProvider(
        create: (context) => OpenLibBloc(
          RepositoryProvider.of<OpenLibraryService>(context),
          RepositoryProvider.of<ConnectivityService>(context),
        ),
      ),
    ];


    return [
      ...bookProviders,
      ...settingsProviders,
      ...openLibraryProviders,
    ];
  }

  _listOfRepositoryProviders(BuildContext context) {
    return [
      RepositoryProvider(create: (_) => OpenLibraryService()),
      RepositoryProvider(create: (_) => ConnectivityService()),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: _listOfRepositoryProviders(context),
      child: MultiBlocProvider(
        providers: _listOfBlocProviders(context),
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (_, themeState) {
            if (themeState is SetThemeState) {
              return BlocBuilder<WelcomeBloc, WelcomeState>(
                builder: (_, welcomeState) {
                  return OpenreadsApp(
                    themeState: themeState,
                    welcomeState: welcomeState,
                  );
                },
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}

class OpenreadsApp extends StatefulWidget {
  const OpenreadsApp({
    super.key,
    required this.themeState,
    required this.welcomeState,
  });

  final SetThemeState themeState;
  final WelcomeState welcomeState;

  @override
  State<OpenreadsApp> createState() => _OpenreadsAppState();
}

class _OpenreadsAppState extends State<OpenreadsApp>
    with WidgetsBindingObserver {
  late bool showWelcomeScreen;

  _decideWelcomeMode(WelcomeState welcomeState) {
    if (welcomeState is ShowWelcomeState) {
      showWelcomeScreen = true;
    } else if (welcomeState is HideWelcomeState) {
      showWelcomeScreen = false;
    } else {
      showWelcomeScreen = true;
    }
  }

  @override
  void initState() {
    super.initState();

    _decideWelcomeMode(widget.welcomeState);
  }

  @override
  Widget build(BuildContext context) {
    _initDateFormat(context);

    final localizationsDelegates = [
      ...context.localizationDelegates,
      const NynorskMaterialLocalizationsDelegate(),
      const NynorskCupertinoLocalizationsDelegate(),
    ];

    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      if (widget.themeState.amoledDark) {
        darkDynamic = darkDynamic?.copyWith(
          background: Colors.black,
        );
      }
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      final themeMode = widget.themeState.themeMode;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          statusBarBrightness: themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark
              : themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
          statusBarIconBrightness: themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark
              : themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
          systemNavigationBarIconBrightness: themeMode == ThemeMode.system
              ? MediaQuery.platformBrightnessOf(context) == Brightness.dark
                  ? Brightness.light
                  : Brightness.dark
              : themeMode == ThemeMode.dark
                  ? Brightness.light
                  : Brightness.dark,
        ),
        child: MaterialApp(
          title: Constants.appName,
          scaffoldMessengerKey: snackbarKey,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: widget.themeState.useMaterialYou
                ? null
                : widget.themeState.primaryColor,
            colorScheme: widget.themeState.useMaterialYou ? lightDynamic : null,
            brightness: Brightness.light,
            fontFamily: widget.themeState.fontFamily,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: widget.themeState.useMaterialYou
                ? null
                : widget.themeState.primaryColor,
            colorScheme: widget.themeState.useMaterialYou ? darkDynamic : null,
            brightness: Brightness.dark,
            fontFamily: widget.themeState.fontFamily,
            scaffoldBackgroundColor:
                widget.themeState.amoledDark ? Colors.black : null,
            appBarTheme: widget.themeState.amoledDark
                ? const AppBarTheme(backgroundColor: Colors.black)
                : null,
          ),
          themeMode: themeMode,
          home: showWelcomeScreen
              ? WelcomeScreen(themeData: Theme.of(context))
              : const BooksScreen(),
          localizationsDelegates: localizationsDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        ),
      );
    });
  }
}

Future<void> _setAndroidConfig() async {
  if (Platform.isAndroid) {
    var androidInfo = await DeviceInfoPlugin().androidInfo;
    var sdkInt = androidInfo.version.sdkInt;

    if (sdkInt >= 23) {
      await FlutterDisplayMode.setHighRefreshRate();
    }

    // https://github.com/dart-lang/http/issues/627
    if (sdkInt <= 25) {
      HttpOverrides.global = OldAndroidHttpOverrides();
    }
  }
}

Future _initDateFormat(BuildContext context) async {
  await initializeDateFormatting();

  // ignore: use_build_context_synchronously
  String locale = context.locale.toString();

  // Fallback to another locale as nn-NO is not supported by Flutter
  if (locale == const Locale('nn').toString()) {
    locale = const Locale('no', 'NO').toString();
  }

  // ignore: use_build_context_synchronously
  dateFormat = DateFormat.yMMMMd(locale);
}
