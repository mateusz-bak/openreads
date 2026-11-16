import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/rating_type_bloc/rating_type_bloc.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/ui/settings_screen/settings_apperance_screen.dart';

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
  setUp(() {
    HydratedBloc.storage = _InMemoryStorage();
  });

  testWidgets(
    'changing dark mode style preserves light and system themeMode',
    (WidgetTester tester) async {
      final themeBloc = ThemeBloc();
      final ratingTypeBloc = RatingTypeBloc();
      addTearDown(() async {
        await themeBloc.close();
        await ratingTypeBloc.close();
      });

      themeBloc.add(const ChangeThemeEvent(
        themeMode: ThemeMode.light,
        primaryColor: Color(0xff3FA796),
        fontFamily: 'Nunito',
        useMaterialYou: false,
        amoledDark: false,
      ));

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<ThemeBloc>.value(value: themeBloc),
            BlocProvider<RatingTypeBloc>.value(value: ratingTypeBloc),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                AppTheme.init(themeBloc.state as SetThemeState, context);
                return const SettingsApperanceScreen();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text(LocaleKeys.dark_mode_style));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LocaleKeys.dark_mode_amoled));
      await tester.pumpAndSettle();

      final afterAmoled = themeBloc.state as SetThemeState;
      expect(afterAmoled.amoledDark, isTrue);
      expect(afterAmoled.themeMode, ThemeMode.light);

      themeBloc.add(const ChangeThemeEvent(
        themeMode: ThemeMode.system,
        primaryColor: Color(0xff3FA796),
        fontFamily: 'Nunito',
        useMaterialYou: false,
        amoledDark: true,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text(LocaleKeys.dark_mode_style));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LocaleKeys.dark_mode_natural));
      await tester.pumpAndSettle();

      final afterNatural = themeBloc.state as SetThemeState;
      expect(afterNatural.amoledDark, isFalse);
      expect(afterNatural.themeMode, ThemeMode.system);
    },
  );
}
