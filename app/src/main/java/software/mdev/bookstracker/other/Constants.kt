package software.mdev.bookstracker.other

object Constants {

    const val BOOK_STATUS_READ = "read"
    const val BOOK_STATUS_IN_PROGRESS = "in_progress"
    const val BOOK_STATUS_TO_READ = "to_read"
    const val BOOK_STATUS_NOTHING = "nothing"

    const val DATABASE_NAME = "Book"
    const val DATABASE_FILE_NAME = "BooksDB.db"
    const val DATABASE_ITEM_BOOK_TITLE = "item_bookTitle"
    const val DATABASE_ITEM_BOOK_AUTHOR = "item_bookAuthor"
    const val DATABASE_ITEM_BOOK_RATING = "item_bookRating"
    const val DATABASE_ITEM_BOOK_STATUS = "item_bookStatus"
    const val DATABASE_ITEM_BOOK_PRIORITY = "item_bookPriority"
    const val DATABASE_ITEM_BOOK_START_DATE = "item_bookStartDate"
    const val DATABASE_ITEM_BOOK_FINISH_DATE = "item_bookFinishDate"
    const val DATABASE_EMPTY_VALUE = "none"

    const val SORT_ORDER_TITLE_DESC = "ivSortTitleDesc"
    const val SORT_ORDER_TITLE_ASC = "ivSortTitleAsc"
    const val SORT_ORDER_AUTHOR_DESC = "ivSortAuthorDesc"
    const val SORT_ORDER_AUTHOR_ASC = "ivSortAuthorAsc"
    const val SORT_ORDER_RATING_DESC = "ivSortRatingDesc"
    const val SORT_ORDER_RATING_ASC = "ivSortRatingAsc"

    const val SERIALIZABLE_BUNDLE_BOOK = "book"

    const val SHARED_PREFERENCES_NAME = "appPref"
    const val SHARED_PREFERENCES_KEY_FIRST_TIME_TOGGLE = "KEY_FIRST_TIME_TOGGLE"
    const val SHARED_PREFERENCES_KEY_SORT_ORDER = "KEY_SORT_ORDER"
    const val SHARED_PREFERENCES_KEY_ACCENT = "KEY_ACCENT"
    const val SHARED_PREFERENCES_KEY_RECOMMENDATIONS = "KEY_RECOMMENDATIONS"
    const val SHARED_PREFERENCES_REFRESHED = "refreshed"

    const val EMPTY_STRING = ""
}