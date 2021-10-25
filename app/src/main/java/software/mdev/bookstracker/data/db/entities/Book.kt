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

        @ColumnInfo(typeAffinity = ColumnInfo.BLOB, name = Constants.DATABASE_ITEM_BOOK_COVER_IMG)
        var  bookCoverImg: ByteArray? = null
): Serializable{
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
        override fun equals(other: Any?): Boolean {
                if (this === other) return true
                if (javaClass != other?.javaClass) return false

                other as Book

                if (bookCoverImg != null) {
                        if (other.bookCoverImg == null) return false
                        if (!bookCoverImg.contentEquals(other.bookCoverImg)) return false
                } else if (other.bookCoverImg != null) return false
                if (id != other.id) return false

                return true
        }

        override fun hashCode(): Int {
                var result = bookCoverImg?.contentHashCode() ?: 0
                result = 31 * result + (id ?: 0)
                return result
        }
}