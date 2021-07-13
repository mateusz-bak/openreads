package software.mdev.bookstracker.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import software.mdev.bookstracker.data.db.entities.Language

@Dao
interface LanguageDao {
    @Query("SELECT * FROM Language ORDER BY item_language6392B ASC")
    fun getLanguages(): LiveData<List<Language>>
}