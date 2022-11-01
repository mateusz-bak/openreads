import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
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

  final appVersion = '2.0.0-alpha1';

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
        child: OpenreadsApp(appVersion: appVersion),
      ),
    );
  }
}

class OpenreadsApp extends StatefulWidget {
  const OpenreadsApp({
    Key? key,
    required this.appVersion,
  }) : super(key: key);

  final String appVersion;

  @override
  State<OpenreadsApp> createState() => _OpenreadsAppState();
}

class _OpenreadsAppState extends State<OpenreadsApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    context.read<ThemeCubit>().updateAppTheme();
    super.didChangePlatformBrightness();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Openreads Flutter',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: BooksScreen(appVersion: widget.appVersion),
    );
  }
}
