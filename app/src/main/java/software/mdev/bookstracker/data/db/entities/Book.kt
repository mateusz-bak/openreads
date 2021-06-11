package software.mdev.bookstracker.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_AUTHOR
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_FINISH_DATE
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_NUMBER_OF_PAGES
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_PRIORITY
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_RATING
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_START_DATE
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_STATUS
import software.mdev.bookstracker.other.Constants.DATABASE_ITEM_BOOK_TITLE
import software.mdev.bookstracker.other.Constants.DATABASE_NAME
import java.io.Serializable

@Entity(tableName = DATABASE_NAME)
data class Book (

        @ColumnInfo(name = DATABASE_ITEM_BOOK_TITLE)
        var bookTitle: String,

        @ColumnInfo(name = DATABASE_ITEM_BOOK_AUTHOR)
        var bookAuthor: String,

        @ColumnInfo(name = DATABASE_ITEM_BOOK_RATING)
        var  bookRating: Float,

        @ColumnInfo(name = DATABASE_ITEM_BOOK_STATUS)
        var  bookStatus: String,

        @ColumnInfo(name = DATABASE_ITEM_BOOK_PRIORITY)
        var  bookPriority: String,

        @ColumnInfo(name = DATABASE_ITEM_BOOK_START_DATE)
        var  bookStartDate: String,

        @ColumnInfo(name = DATABASE_ITEM_BOOK_FINISH_DATE)
        var  bookFinishDate: String,

        @ColumnInfo(name = DATABASE_ITEM_BOOK_NUMBER_OF_PAGES)
        var  bookNumberOfPages: Int
): Serializable{
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}