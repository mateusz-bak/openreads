import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/l10n.dart';
import 'package:openreads/logic/bloc/challenge_bloc/challenge_bloc.dart';
import 'package:openreads/logic/bloc/open_lib_bloc/open_lib_bloc.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/welcome_screen/welcome_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );

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
    return MaterialApp(
      title: 'Openreads Flutter',
      theme: AppTheme.lightTheme.copyWith(
        primaryColor: widget.themeState.primaryColor,
        colorScheme: const ColorScheme.light().copyWith(
          primary: widget.themeState.primaryColor,
          secondary: widget.themeState.primaryColor,
        ),
        dividerColor:
            widget.themeState.showOutlines ? null : Colors.transparent,
        extensions: <ThemeExtension<dynamic>>[
          CustomBorder(
            radius: BorderRadius.circular(
              widget.themeState.cornerRadius,
            ),
          ),
        ],
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        primaryColor: widget.themeState.primaryColor,
        colorScheme: const ColorScheme.dark().copyWith(
          primary: widget.themeState.primaryColor,
          secondary: widget.themeState.primaryColor,
        ),
        dividerColor:
            widget.themeState.showOutlines ? null : Colors.transparent,
        extensions: <ThemeExtension<dynamic>>[
          CustomBorder(
            radius: BorderRadius.circular(
              widget.themeState.cornerRadius,
            ),
          ),
        ],
      ),
      themeMode: widget.themeState.themeMode,
      home: welcomeMode
          ? WelcomeScreen(themeData: Theme.of(context))
          : const BooksScreen(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
