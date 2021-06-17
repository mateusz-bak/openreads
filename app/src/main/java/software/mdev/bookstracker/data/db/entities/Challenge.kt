package software.mdev.bookstracker.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import software.mdev.bookstracker.other.Constants
import java.io.Serializable

@Entity(tableName = Constants.DATABASE_NAME_CHALLENGE)
data class Challenge (

        @ColumnInfo(name = Constants.DATABASE_CHALLENGE_ITEM_CHALLENGE_YEAR)
        var challengeYear: Int,

        @ColumnInfo(name = Constants.DATABASE_CHALLENGE_ITEM_CHALLENGE_BOOKS)
        var challengeBooks: Int,

        @ColumnInfo(name = Constants.DATABASE_CHALLENGE_ITEM_CHALLENGE_PAGES)
        var  challengePages: Int
): Serializable{
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}