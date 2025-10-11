import 'dart:io';
import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:openreads/core/constants/constants.dart';
import 'package:openreads/core/constants/enums/book_status.dart';
import 'package:openreads/core/themes/app_theme.dart';
import 'package:openreads/generated/locale_keys.g.dart';
import 'package:openreads/logic/bloc/theme_bloc/theme_bloc.dart';
import 'package:openreads/logic/cubit/default_book_status_cubit.dart';
import 'package:openreads/logic/cubit/edit_book_cubit.dart';
import 'package:openreads/logic/cubit/selected_books_cubit.dart';
import 'package:openreads/model/book.dart';
import 'package:openreads/ui/add_book_screen/add_book_screen.dart';
import 'package:openreads/ui/books_screen/books_screen.dart';
import 'package:openreads/ui/display_screen/display_screen.dart';
import 'package:openreads/ui/search_ol_screen/search_ol_screen.dart';
import 'package:openreads/ui/search_page/search_page.dart';
import 'package:openreads/ui/settings_screen/settings_screen.dart';
import 'package:openreads/ui/statistics_screen/statistics_screen.dart';

import 'widgets/widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;

  late List<String> menuOptions;
  late double appBarHeight;

  void openSortFilterSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: false,
        builder: (_) {
          return const SortBottomSheet();
        },
      );
    } else if (Platform.isAndroid) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return const SortBottomSheet();
        },
      );
    }
  }

  void goToDisplayScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DisplayScreen(),
      ),
    );
  }

  void goToSettingsScreen() {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }

  //TODO: fix this logic
  BookStatus _getStatusForNewBook() {
    // if (_tabController.index == inProgressIndex) {
    //   return BookStatus.inProgress;
    // } else if (_tabController.index == 2) {
    //   return BookStatus.forLater;
    // } else {
    return BookStatus.read;
    // }
  }

  void _setEmptyBookForEditScreen() {
    final status = _getStatusForNewBook();
    final defaultBookFormat = context.read<DefaultBooksFormatCubit>().state;

    context.read<EditBookCubit>().setBook(
          Book.empty(status: status, bookFormat: defaultBookFormat),
        );
  }

  void _goToSearchInUserBooksPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchPage()),
    );
  }

  Future<void> _invokeMenuOption(String choice) async {
    await Future.delayed(const Duration(milliseconds: 0));

    if (!mounted) return;

    if (currentPageIndex == 0) {
      if (choice == menuOptions[0]) {
        openSortFilterSheet();
      } else if (choice == menuOptions[1]) {
        goToDisplayScreen();
      } else if (choice == menuOptions[2]) {
        goToSettingsScreen();
      }
    } else if (currentPageIndex == 1) {
      if (choice == menuOptions[0]) {
        goToSettingsScreen();
      }
    }
  }

  void _onFabPressed() {
    if (Platform.isIOS) {
      showCupertinoModalBottomSheet(
        context: context,
        expand: false,
        builder: (_) {
          return AddBookSheet(
            addManually: _addBookManually,
            searchInOpenLibrary: _searchInOpenLibrary,
            scanBarcode: _scanBarcode,
          );
        },
      );
    } else if (Platform.isAndroid) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) {
          return AddBookSheet(
            addManually: _addBookManually,
            searchInOpenLibrary: _searchInOpenLibrary,
            scanBarcode: _scanBarcode,
          );
        },
      );
    }
  }

  Future<void> _addBookManually() async {
    _setEmptyBookForEditScreen();

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AddBookScreen(),
      ),
    );
  }

  Future<void> _searchInOpenLibrary() async {
    _setEmptyBookForEditScreen();

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchOLScreen(
          status: _getStatusForNewBook(),
        ),
      ),
    );
  }

  Future<void> _scanBarcode() async {
    _setEmptyBookForEditScreen();

    Navigator.pop(context);
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchOLScreen(
          scan: true,
          status: _getStatusForNewBook(),
        ),
      ),
    );
  }

  void _generateMenuOptions() {
    menuOptions = [];

    if (currentPageIndex == 0) {
      menuOptions.add(LocaleKeys.sort_filter.tr());
      menuOptions.add(LocaleKeys.display.tr());
    }
    menuOptions.add(LocaleKeys.settings.tr());
  }

  @override
  void initState() {
    appBarHeight = AppBar().preferredSize.height;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _generateMenuOptions();

    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        if (themeState is SetThemeState) {
          AppTheme.init(themeState, context);

          return BlocBuilder<SelectedBooksCubit, List<int>>(
              builder: (context, list) {
            return PopScope(
              canPop: list.isEmpty && currentPageIndex == 0,
              onPopInvokedWithResult: (didPop, result) {
                if (didPop) {
                  return;
                }

                if (currentPageIndex == 0) {
                  context.read<SelectedBooksCubit>().resetSelection();
                } else {
                  setState(() {
                    currentPageIndex = 0;
                  });
                }
              },
              child: Scaffold(
                extendBodyBehindAppBar: true,
                resizeToAvoidBottomInset: true,
                appBar: list.isNotEmpty
                    ? _buildMultiSelectAppBar(context, list)
                    : _buildAppBar(context),
                floatingActionButton: _buildFAB(context, themeState, list),
                body: _buildScaffoldBody(),
                bottomNavigationBar: HomeNavigationBar(
                  currentIndex: currentPageIndex,
                  onTap: (index) {
                    context.read<SelectedBooksCubit>().resetSelection();
                    setState(() {
                      currentPageIndex = index;
                    });
                  },
                ),
              ),
            );
          });
        } else {
          return const SizedBox();
        }
      },
    );
  }

  Widget _buildScaffoldBody() {
    return currentPageIndex == 0
        ? const BooksScreen()
        : currentPageIndex == 1
            ? const StatisticsScreen()
            : const SizedBox.shrink();
  }

  AppBar _buildMultiSelectAppBar(
    BuildContext context,
    List<int> multiSelectList,
  ) {
    return AppBar(
        title: Row(
      children: [
        IconButton(
          icon: const FaIcon(FontAwesomeIcons.xmark, size: 18),
          onPressed: () {
            context.read<SelectedBooksCubit>().resetSelection();
          },
        ),
        Text(
          '${LocaleKeys.selected.tr()} ${multiSelectList.length}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    ));
  }

  Widget _buildFAB(
    BuildContext context,
    SetThemeState state,
    List<int> multiSelectList,
  ) {
    return currentPageIndex != 0
        ? const SizedBox.shrink()
        : multiSelectList.isNotEmpty
            ? MultiSelectFAB()
            : FloatingActionButton(
                onPressed: _onFabPressed,
                child: const FaIcon(FontAwesomeIcons.plus),
              );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    AppBar appBar = AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      title: const Row(
        children: [
          Text(
            Constants.appName,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        currentPageIndex == 0
            ? IconButton(
                onPressed: _goToSearchInUserBooksPage,
                icon: const Icon(Icons.search),
              )
            : const SizedBox(),
        PopupMenuButton<String>(
          onSelected: (_) {},
          itemBuilder: (_) {
            return menuOptions.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(
                  choice,
                ),
                onTap: () => _invokeMenuOption(choice),
              );
            }).toList();
          },
        ),
      ],
    );

    return Platform.isAndroid
        ? appBar
        : PreferredSize(
            preferredSize: Size(double.infinity, appBarHeight),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: appBar,
              ),
            ),
          );
  }
}
