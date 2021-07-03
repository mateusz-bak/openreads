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
        var  bookRating: Float,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_STATUS)
        var  bookStatus: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_PRIORITY)
        var  bookPriority: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_START_DATE)
        var  bookStartDate: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_FINISH_DATE)
        var  bookFinishDate: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_NUMBER_OF_PAGES)
        var  bookNumberOfPages: Int,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_TITLE_ASCII)
        var  bookTitle_ASCII: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_AUTHOR_ASCII)
        var  bookAuthor_ASCII: String,

        @ColumnInfo(name = Constants.DATABASE_ITEM_BOOK_IS_DELETED)
        var  bookIsDeleted: Boolean
): Serializable{
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}