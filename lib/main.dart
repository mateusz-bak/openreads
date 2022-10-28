import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:openreads/logic/cubit/book_cubit.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/logic/cubit/theme_cubit.dart';
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
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (context) => ThemeCubit(),
        ),
      ],
      child: const OpenreadsApp(),
    );
  }
}

class OpenreadsApp extends StatefulWidget {
  const OpenreadsApp({
    Key? key,
  }) : super(key: key);

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
      home: const BooksScreen(),
    );
  }
}
