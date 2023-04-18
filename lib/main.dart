import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/migration_v1_to_v2_bloc/migration_v1_to_v2_bloc.dart';
import 'package:openreads/logic/bloc/open_lib_bloc/open_lib_bloc.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/welcome_screen/welcome_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

late BookCubit bookCubit;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );

  bookCubit = BookCubit();

  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (context) => OpenLibraryService()),
        RepositoryProvider(create: (context) => ConnectivityService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeBloc>(create: (context) => ThemeBloc()),
          BlocProvider<SortBloc>(create: (context) => SortBloc()),
          BlocProvider<WelcomeBloc>(create: (context) => WelcomeBloc()),
          BlocProvider<ChallengeBloc>(create: (context) => ChallengeBloc()),
          BlocProvider<RatingTypeBloc>(create: (context) => RatingTypeBloc()),
          BlocProvider<MigrationV1ToV2Bloc>(
              create: (context) => MigrationV1ToV2Bloc()),
          BlocProvider<OpenLibBloc>(
            create: (context) => OpenLibBloc(
              RepositoryProvider.of<OpenLibraryService>(context),
              RepositoryProvider.of<ConnectivityService>(context),
            ),
          ),
        ],
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
    Key? key,
    required this.themeState,
    required this.welcomeState,
  }) : super(key: key);

  final SetThemeState themeState;
  final WelcomeState welcomeState;

  @override
  State<OpenreadsApp> createState() => _OpenreadsAppState();
}

class _OpenreadsAppState extends State<OpenreadsApp>
    with WidgetsBindingObserver {
  late bool welcomeMode;
  late Image welcomeImage1;
  late Image welcomeImage2;
  late Image welcomeImage3;

  _decideWelcomeMode(WelcomeState welcomeState) {
    if (welcomeState is ShowWelcomeState) {
      welcomeMode = true;
    } else {
      welcomeMode = false;
    }
  }

  @override
  void didChangeDependencies() {
    precacheImage(welcomeImage1.image, context);
    precacheImage(welcomeImage2.image, context);
    precacheImage(welcomeImage3.image, context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    welcomeImage1 = Image.asset('assets/images/welcome_1.jpg');
    welcomeImage2 = Image.asset('assets/images/welcome_2.jpg');
    welcomeImage3 = Image.asset('assets/images/welcome_3.jpg');

    _decideWelcomeMode(widget.welcomeState);
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
        builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      return MaterialApp(
        title: 'Openreads',
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
        ),
        themeMode: widget.themeState.themeMode,
        home: welcomeMode
            ? WelcomeScreen(themeData: Theme.of(context))
            : const BooksScreen(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: widget.themeState.locale != null
            ? Locale(widget.themeState.locale!)
            : null,
      );
    });
  }
}
