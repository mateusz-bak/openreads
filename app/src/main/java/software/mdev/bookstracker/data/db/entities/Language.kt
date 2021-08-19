package software.mdev.bookstracker.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import software.mdev.bookstracker.other.Constants
import java.io.Serializable

@Entity(tableName = Constants.DATABASE_NAME_LANGUAGE)
data class Language(
    @ColumnInfo(name = Constants.DATABASE_LANGUAGE_ITEM_language6392B)
    var language6392B: String?,

    @ColumnInfo(name = Constants.DATABASE_LANGUAGE_ITEM_isoLanguageName)
    var isoLanguageName: String?,

    @ColumnInfo(name = Constants.DATABASE_LANGUAGE_ITEM_isSelected)
    var isSelected: Int?,

    @ColumnInfo(name = Constants.DATABASE_LANGUAGE_ITEM_selectCounter)
    var selectCounter: Int?,

    @ColumnInfo(name = Constants.DATABASE_LANGUAGE_ITEM_isoLanguageName_pol)
    var isoLanguageName_pol: String?
) : Serializable {
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}