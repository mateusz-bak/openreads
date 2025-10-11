import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';

class DisplayCubit extends HydratedCubit<DisplayState> {
  DisplayCubit() : super(DisplayState.initial());

  void setDisplayType(DisplayType type) {
    emit(state.copyWith(type: type));
  }

  void setShowBookFormatOnList(bool value) {
    emit(state.copyWith(bookFormatOnList: value));
  }

  void setShowSortAttributesOnList(bool value) {
    emit(state.copyWith(sortAttributesOnList: value));
  }

  void setShowTagsOnList(bool value) {
    emit(state.copyWith(tagsOnList: value));
  }

  void setShowTitleOverCover(bool value) {
    emit(state.copyWith(showTitleOverCover: value));
  }

  void setShowNumberOfBooks(bool value) {
    emit(state.copyWith(showNumberOfBooks: value));
  }

  void setGridSize(int value) {
    emit(state.copyWith(gridSize: value));
  }

  @override
  DisplayState? fromJson(Map<String, dynamic> json) =>
      DisplayState.fromJson(json);

  @override
  Map<String, dynamic>? toJson(DisplayState state) => state.toJson();
}

class DisplayState extends Equatable {
  final DisplayType type;
  final bool bookFormatOnList;
  final bool showNumberOfBooks;
  final bool sortAttributesOnList;
  final bool showTitleOverCover;
  final bool tagsOnList;
  final int gridSize;

  const DisplayState({
    required this.type,
    required this.bookFormatOnList,
    required this.showNumberOfBooks,
    required this.sortAttributesOnList,
    required this.showTitleOverCover,
    required this.tagsOnList,
    required this.gridSize,
  });

  factory DisplayState.initial() {
    return const DisplayState(
      type: DisplayType.list,
      bookFormatOnList: true,
      showNumberOfBooks: true,
      sortAttributesOnList: true,
      showTitleOverCover: true,
      tagsOnList: false,
      gridSize: 3,
    );
  }

  DisplayState copyWith({
    DisplayType? type,
    bool? bookFormatOnList,
    bool? showNumberOfBooks,
    bool? sortAttributesOnList,
    bool? showTitleOverCover,
    bool? tagsOnList,
    int? gridSize,
  }) {
    return DisplayState(
      type: type ?? this.type,
      bookFormatOnList: bookFormatOnList ?? this.bookFormatOnList,
      showNumberOfBooks: showNumberOfBooks ?? this.showNumberOfBooks,
      sortAttributesOnList: sortAttributesOnList ?? this.sortAttributesOnList,
      showTitleOverCover: showTitleOverCover ?? this.showTitleOverCover,
      tagsOnList: tagsOnList ?? this.tagsOnList,
      gridSize: gridSize ?? this.gridSize,
    );
  }

  Map<String, dynamic> toJson() => {
        'display_state': _displayTypeToString(type),
        'book_format_on_list': bookFormatOnList,
        'show_number_of_books': showNumberOfBooks,
        'sort_attributes_on_list': sortAttributesOnList,
        'show_title_over_cover': showTitleOverCover,
        'tags_on_list': tagsOnList,
        'grid_size': gridSize,
      };

  static DisplayState? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;

    final displayStateStr = json['display_state'] as String?;
    final bookFormatOnList = json['book_format_on_list'] as bool? ?? true;
    final showNumberOfBooks = json['show_number_of_books'] as bool? ?? true;
    final sortAttributesOnList =
        json['sort_attributes_on_list'] as bool? ?? true;
    final showTitleOverCover = json['show_title_over_cover'] as bool? ?? true;
    final tagsOnList = json['tags_on_list'] as bool? ?? false;
    final gridSize = json['grid_size'] as int? ?? 3;

    final type = _displayTypeFromString(displayStateStr);
    if (type == null) return null;

    return DisplayState(
      type: type,
      bookFormatOnList: bookFormatOnList,
      showNumberOfBooks: showNumberOfBooks,
      sortAttributesOnList: sortAttributesOnList,
      showTitleOverCover: showTitleOverCover,
      tagsOnList: tagsOnList,
      gridSize: gridSize,
    );
  }

  static String _displayTypeToString(DisplayType type) {
    switch (type) {
      case DisplayType.list:
        return 'list';
      case DisplayType.compactList:
        return 'list_compact';
      case DisplayType.grid:
        return 'grid';
      case DisplayType.detailedGrid:
        return 'grid_detailed';
    }
  }

  static DisplayType? _displayTypeFromString(String? string) {
    switch (string) {
      case 'list':
        return DisplayType.list;
      case 'list_compact':
        return DisplayType.compactList;
      case 'grid':
        return DisplayType.grid;
      case 'grid_detailed':
        return DisplayType.detailedGrid;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
        type,
        bookFormatOnList,
        showNumberOfBooks,
        sortAttributesOnList,
        showTitleOverCover,
        tagsOnList,
        gridSize,
      ];
}
