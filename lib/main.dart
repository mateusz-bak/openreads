import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/open_lib_bloc/open_lib_bloc.dart';
import 'package:openreads/logic/bloc/outlines_bloc/outlines_bloc.dart';
import 'package:openreads/logic/bloc/sort_bloc/sort_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/bloc/welcome_bloc/welcome_bloc.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/welcome_screen/welcome_screen.dart';
import 'package:path_provider/path_provider.dart';

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
          BlocProvider<OutlinesBloc>(create: (context) => OutlinesBloc()),
          BlocProvider<SortBloc>(create: (context) => SortBloc()),
          BlocProvider<WelcomeBloc>(create: (context) => WelcomeBloc()),
          BlocProvider<OpenLibBloc>(
            create: (context) => OpenLibBloc(
              RepositoryProvider.of<OpenLibraryService>(context),
              RepositoryProvider.of<ConnectivityService>(context),
            ),
          ),
        ],
        child: const OpenreadsApp(),
      ),
    );
  }
}

class OpenreadsApp extends StatefulWidget {
  const OpenreadsApp({Key? key}) : super(key: key);

  @override
  State<OpenreadsApp> createState() => _OpenreadsAppState();
}

class _OpenreadsAppState extends State<OpenreadsApp>
    with WidgetsBindingObserver {
  late ThemeMode themeMode;
  late bool outlinesMode;
  late bool welcomeMode;
  late Image welcomeImage1;
  late Image welcomeImage2;
  late Image welcomeImage3;

  _decideThemeMode(ThemeState themeState) {
    if (themeState is ThemeLightState) {
      themeMode = ThemeMode.light;
    } else if (themeState is ThemeDarkState) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
  }

  _decideOutlinesMode(OutlinesState outlinesState) {
    if (outlinesState is ShowOutlinesState) {
      outlinesMode = true;
    } else {
      outlinesMode = false;
    }
  }

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
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, themeState) {
        _decideThemeMode(themeState);

        return BlocBuilder<OutlinesBloc, OutlinesState>(
          builder: (_, outlinesState) {
            _decideOutlinesMode(outlinesState);

            return BlocBuilder<WelcomeBloc, WelcomeState>(
              builder: (_, welcomeState) {
                _decideWelcomeMode(welcomeState);

                return MaterialApp(
                  title: 'Openreads Flutter',
                  theme: outlinesMode
                      ? AppTheme.lightTheme
                      : AppTheme.lightTheme.copyWith(
                          dividerColor: Colors.transparent,
                        ),
                  darkTheme: outlinesMode
                      ? AppTheme.darkTheme
                      : AppTheme.darkTheme.copyWith(
                          dividerColor: Colors.transparent,
                        ),
                  themeMode: themeMode,
                  home: welcomeMode
                      ? WelcomeScreen(themeData: Theme.of(context))
                      : const BooksScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}
