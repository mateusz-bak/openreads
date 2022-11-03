import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:openreads/core/constants.dart/enums.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/bloc/open_library_bloc.dart';
import 'package:openreads/logic/cubit/sort_cubit.dart';
import 'package:openreads/logic/cubit/theme_cubit.dart';
import 'package:openreads/resources/connectivity_service.dart';
import 'package:openreads/resources/open_library_service.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDisplayMode.setHighRefreshRate();

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
          BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),
          BlocProvider<SortCubit>(create: (context) => SortCubit()),
          BlocProvider<OpenLibraryBloc>(
            create: (context) => OpenLibraryBloc(
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

  _decideThemeMode(AsyncSnapshot<AppThemeMode> snapshot) {
    if (snapshot.hasData && snapshot.data == AppThemeMode.light) {
      themeMode = ThemeMode.light;
    } else if (snapshot.hasData && snapshot.data == AppThemeMode.dark) {
      themeMode = ThemeMode.dark;
    } else {
      themeMode = ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AppThemeMode>(
      stream: BlocProvider.of<ThemeCubit>(context).appThemeMode,
      builder: (context, AsyncSnapshot<AppThemeMode> snapshot) {
        _decideThemeMode(snapshot);

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
