package software.mdev.bookstracker.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import software.mdev.bookstracker.other.Constants
import java.io.Serializable

@Entity(tableName = Constants.DATABASE_NAME_YEAR)
data class Year(
        @ColumnInfo(name = Constants.DATABASE_YEAR_ITEM_YEAR)
        var year: String,

        @ColumnInfo(name = Constants.DATABASE_YEAR_ITEM_BOOKS)
        var yearBooks: Int,

        @ColumnInfo(name = Constants.DATABASE_YEAR_ITEM_PAGES)
        var yearPages: Int,

        @ColumnInfo(name = Constants.DATABASE_YEAR_ITEM_RATING)
        var avgRating: Float,

        @ColumnInfo(name = Constants.DATABASE_YEAR_CHALLENGE_BOOKS)
        var yearChallengeBooks: Int?,

        @ColumnInfo(name = Constants.DATABASE_YEAR_CHALLENGE_PAGES)
        var yearChallengePages: Int
): Serializable{
        @PrimaryKey(autoGenerate = false)
        var id: Int? = null
}