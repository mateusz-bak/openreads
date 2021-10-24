package software.mdev.bookstracker.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import software.mdev.bookstracker.other.Constants
import java.io.Serializable

@Entity(tableName = Constants.DATABASE_NAME)
data class Book (

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_TITLE)
        var bookTitle: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_AUTHOR)
        var bookAuthor: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_RATING)
        var  bookRating: Float = 0F,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_STATUS)
        var  bookStatus: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_PRIORITY)
        var  bookPriority: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_START_DATE)
        var  bookStartDate: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_FINISH_DATE)
        var  bookFinishDate: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_NUMBER_OF_PAGES)
        var  bookNumberOfPages: Int = 0,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_TITLE_ASCII)
        var  bookTitle_ASCII: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_AUTHOR_ASCII)
        var  bookAuthor_ASCII: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_IS_DELETED)
        var  bookIsDeleted: Boolean = false,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_COVER_URL)
        var  bookCoverUrl: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_OLID)
        var  bookOLID: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_ISBN10)
        var  bookISBN10: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_ISBN13)
        var  bookISBN13: String = Constants.DATABASE_EMPTY_VALUE,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_PUBLISH_YEAR)
        var  bookPublishYear: Int = 0,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_IS_FAV)
        var  bookIsFav: Boolean = false,
): Serializable{
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}