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
    const val DATABASE_ITEM_BOOK_NUMBER_OF_PAGES = "item_bookNumberOfPages"
    const val DATABASE_ITEM_BOOK_TITLE_ASCII = "item_bookTitle_ASCII"
    const val DATABASE_ITEM_BOOK_AUTHOR_ASCII = "item_bookAuthor_ASCII"
    const val DATABASE_ITEM_BOOK_COVER_URL = "item_bookCoverUrl"
    const val DATABASE_ITEM_BOOK_OLID = "item_bookOLID"
    const val DATABASE_ITEM_BOOK_ISBN10 = "item_bookISBN10"
    const val DATABASE_ITEM_BOOK_ISBN13 = "item_bookISBN13"
    const val DATABASE_ITEM_BOOK_PUBLISH_YEAR = "item_bookPublishYear"
    const val DATABASE_ITEM_BOOK_IS_DELETED = "item_bookIsDeleted"
    const val DATABASE_EMPTY_VALUE = "none"

    const val DATABASE_NAME_YEAR = "Year"
    const val DATABASE_YEAR_FILE_NAME = "YearDB.db"
    const val DATABASE_YEAR_ITEM_YEAR = "item_year"
    const val DATABASE_YEAR_ITEM_BOOKS = "item_books"
    const val DATABASE_YEAR_ITEM_PAGES = "item_pages"
    const val DATABASE_YEAR_ITEM_RATING = "item_rating"
    const val DATABASE_YEAR_CHALLENGE_BOOKS = "item_challenge_books"
    const val DATABASE_YEAR_CHALLENGE_PAGES = "item_challenge_pages"

    const val DATABASE_NAME_LANGUAGE = "Language"
    const val DATABASE_LANGUAGE_FILE_NAME = "LanguageDB.db"
    const val DATABASE_LANGUAGE_ITEM_language6392B = "item_language6392B"
    const val DATABASE_LANGUAGE_ITEM_isoLanguageName = "item_isoLanguageName"
    const val DATABASE_LANGUAGE_ITEM_isSelected = "item_isSelected"
    const val DATABASE_LANGUAGE_ITEM_selectCounter = "item_selectCounter"
    const val DATABASE_LANGUAGE_ITEM_isoLanguageName_pol = "item_isoLanguageName_pol"

    const val CHALLENGE_BEGINNER = 3
    const val CHALLENGE_EASY = 6
    const val CHALLENGE_NORMAL = 12
    const val CHALLENGE_HARD = 18
    const val CHALLENGE_INSANE = 24


    const val SORT_ORDER_TITLE_DESC = "ivSortTitleDesc"
    const val SORT_ORDER_TITLE_ASC = "ivSortTitleAsc"
    const val SORT_ORDER_AUTHOR_DESC = "ivSortAuthorDesc"
    const val SORT_ORDER_AUTHOR_ASC = "ivSortAuthorAsc"
    const val SORT_ORDER_RATING_DESC = "ivSortRatingDesc"
    const val SORT_ORDER_RATING_ASC = "ivSortRatingAsc"
    const val SORT_ORDER_PAGES_DESC = "ivSortPagesDesc"
    const val SORT_ORDER_PAGES_ASC = "ivSortPagesAsc"
    const val SORT_ORDER_START_DATE_DESC = "ivSortStartDateDesc"
    const val SORT_ORDER_START_DATE_ASC = "ivSortStartDateAsc"
    const val SORT_ORDER_FINISH_DATE_DESC = "ivSortFinishDateDesc"
    const val SORT_ORDER_FINISH_DATE_ASC = "ivSortFinishDateAsc"

    const val SERIALIZABLE_BUNDLE_BOOK = "book"
    const val SERIALIZABLE_BUNDLE_ISBN = "isbn"

    const val SHARED_PREFERENCES_KEY_FIRST_TIME_TOGGLE = "KEY_FIRST_TIME_TOGGLE"
    const val SHARED_PREFERENCES_KEY_APP_VERSION = "SHARED_PREFERENCES_KEY_APP_VERSION"
    const val SHARED_PREFERENCES_KEY_SORT_ORDER = "KEY_SORT_ORDER"
    const val SHARED_PREFERENCES_KEY_FILTER_YEARS = "KEY_FILTER_YEARS"
    const val SHARED_PREFERENCES_KEY_ACCENT = "KEY_ACCENT"
    const val SHARED_PREFERENCES_KEY_LANDING_PAGE = "KEY_LANDING_PAGE"
    const val SHARED_PREFERENCES_KEY_TIME_TO_ASK_FOR_RATING = "KEY_TIME_TO_ASK_FOR_RATING"
    const val SHARED_PREFERENCES_KEY_RECOMMENDATIONS = "KEY_RECOMMENDATIONS"
    const val SHARED_PREFERENCES_KEY_SHOW_OL_ALERT = "KEY_SHOW_OL_ALERT"
    const val SHARED_PREFERENCES_REFRESHED = "refreshed"
    const val KEY_CHECK_FOR_UPDATES = "KEY_CHECK_FOR_UPDATES"
    const val KEY_TRASH = "KEY_TRASH"
    const val KEY_BACKUP = "KEY_BACKUP"
    const val KEY_EXPORT = "KEY_EXPORT"
    const val KEY_IMPORT = "KEY_IMPORT"

    const val EMPTY_STRING = ""

    const val THEME_ACCENT_LIGHT_GREEN = "accent_light_green"
    const val THEME_ACCENT_ORANGE_500 = "accent_orange"
    const val THEME_ACCENT_CYAN_500 = "accent_cyan"
    const val THEME_ACCENT_GREEN_500 = "accent_green"
    const val THEME_ACCENT_BROWN_400 = "accent_brown"
    const val THEME_ACCENT_LIME_500 = "accent_lime"
    const val THEME_ACCENT_PINK_300 = "accent_pink"
    const val THEME_ACCENT_PURPLE_500 = "accent_purple"
    const val THEME_ACCENT_TEAL_500 = "accent_teal"
    const val THEME_ACCENT_YELLOW_500 = "accent_yellow"

    const val KEY_LANDING_PAGE_FINISHED = "book_list_finished"
    const val KEY_LANDING_PAGE_IN_PROGRESS = "book_list_inProgress"
    const val KEY_LANDING_PAGE_TO_READ = "book_list_toRead"

    const val THEME_ACCENT_DEFAULT = THEME_ACCENT_GREEN_500

    const val GITHUB_USER = "mateusz-bak"
    const val GITHUB_REPO = "books-tracker-android"

    const val BASE_URL = "https://openlibrary.org/"
    const val OPEN_LIBRARY_SEARCH_DELAY = 500L

    // permission request codes
    const val PERMISSION_CAMERA_FROM_LIST_1 = 1
    const val PERMISSION_CAMERA_FROM_LIST_2 = 2
    const val PERMISSION_CAMERA_FROM_LIST_3 = 3

    const val MS_ONE_WEEK = 604800000L
    const val MS_THREE_DAYS = 259200000L
}