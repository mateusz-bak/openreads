import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/open_lib_bloc/open_lib_bloc.dart';
import 'package:openreads/logic/cubit/sort_cubit.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

  final storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );

  HydratedBlocOverrides.runZoned(
    () => runApp(const App()),
    storage: storage,
  );
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
          BlocProvider<SortCubit>(create: (context) => SortCubit()),
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

  _decideThemeMode(ThemeState themeState) {
    if (themeState is ThemeLightState) {
      themeMode = ThemeMode.light;
    } else if (themeState is ThemeDarkState) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (_, themeState) {
        _decideThemeMode(themeState);

        return MaterialApp(
          title: 'Openreads Flutter',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          home: const BooksScreen(),
        );
      },
    );
  }
}
