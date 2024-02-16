import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:openreads/core/constants/enums/enums.dart';

part 'sort_state.dart';
part 'sort_event.dart';

class SortBloc extends HydratedBloc<SortEvent, SortState> {
  SortBloc()
      : super(const SetSortState(
          sortType: SortType.byTitle,
          isAsc: true,
          onlyFavourite: false,
          years: null,
          tags: null,
          displayTags: false,
          filterTagsAsAnd: false,
          bookType: null,
        )) {
    on<ChangeSortEvent>((event, emit) {
      emit(SetSortState(
        sortType: event.sortType,
        isAsc: event.isAsc,
        onlyFavourite: event.onlyFavourite,
        years: event.years,
        tags: event.tags,
        displayTags: event.displayTags,
        filterTagsAsAnd: event.filterTagsAsAnd,
        bookType: event.bookType,
        filterOutTags: event.filterOutTags,
      ));
    });
  }

  @override
  SortState? fromJson(Map<String, dynamic> json) {
    final sortTypeInt = json['sort_type'] as int;
    final isAsc = json['sort_order'] as bool;
    final onlyFavourite = json['only_favourite'] as bool;
    final years = json['years'] as String?;
    final tags = json['tags'] as String?;
    final displayTags = json['display_tags'] as bool;
    final filterTagsAsAnd = json['filter_tags_as_and'] as bool;
    final filterOutTags = json['filter_out_tags'] as bool;
    final bookType = json['filter_book_type'] as String?;

    late SortType sortType;

    switch (sortTypeInt) {
      case 0:
        sortType = SortType.byTitle;
        break;
      case 1:
        sortType = SortType.byAuthor;
        break;
      case 2:
        sortType = SortType.byRating;
        break;
      case 3:
        sortType = SortType.byPages;
        break;
      case 4:
        sortType = SortType.byStartDate;
        break;
      case 5:
        sortType = SortType.byFinishDate;
        break;
      case 6:
        sortType = SortType.byPublicationYear;
        break;
      default:
        sortType = SortType.byTitle;
    }

    return SetSortState(
      sortType: sortType,
      isAsc: isAsc,
      onlyFavourite: onlyFavourite,
      years: years,
      tags: tags,
      displayTags: displayTags,
      filterTagsAsAnd: filterTagsAsAnd,
      bookType: bookType == 'audiobook'
          ? BookFormat.audiobook
          : bookType == 'ebook'
              ? BookFormat.ebook
              : bookType == 'paper' || bookType == 'paperback'
                  ? BookFormat.paperback
                  : bookType == 'hardcover'
                      ? BookFormat.hardcover
                      : null,
      filterOutTags: filterOutTags,
    );
  }

  @override
  Map<String, dynamic>? toJson(SortState state) {
    if (state is SetSortState) {
      late int sortTypeInt;
      switch (state.sortType) {
        case SortType.byTitle:
          sortTypeInt = 0;
          break;
        case SortType.byAuthor:
          sortTypeInt = 1;
          break;
        case SortType.byRating:
          sortTypeInt = 2;
          break;
        case SortType.byPages:
          sortTypeInt = 3;
          break;
        case SortType.byStartDate:
          sortTypeInt = 4;
          break;
        case SortType.byFinishDate:
          sortTypeInt = 5;
          break;
        case SortType.byPublicationYear:
          sortTypeInt = 6;
          break;
        default:
          sortTypeInt = 0;
      }

      return {
        'sort_type': sortTypeInt,
        'sort_order': state.isAsc,
        'only_favourite': state.onlyFavourite,
        'years': state.years,
        'tags': state.tags,
        'display_tags': state.displayTags,
        'filter_tags_as_and': state.filterTagsAsAnd,
        'filter_book_type': state.bookType == BookFormat.audiobook
            ? 'audiobook'
            : state.bookType == BookFormat.ebook
                ? 'ebook'
                : state.bookType == BookFormat.paperback
                    ? 'paperback'
                    : state.bookType == BookFormat.hardcover
                        ? 'hardcover'
                        : null,
        'filter_out_tags': state.filterOutTags,
      };
    } else {
      return {
        'sort_type': 0,
        'sort_order': true,
        'only_favourite': false,
        'years': null,
        'tags': null,
        'display_tags': false,
        'filter_tags_as_and': false,
        'filter_book_type': null,
        'filter_out_tags': false,
      };
    }
  }
}
