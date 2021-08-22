package software.mdev.bookstracker.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import software.mdev.bookstracker.data.db.entities.Language

@Dao
interface LanguageDao {
    @Query("SELECT * FROM Language ORDER BY item_selectCounter DESC")
    fun getLanguages(): LiveData<List<Language>>

    @Query("UPDATE Language SET item_isSelected=:isSelected WHERE id=:id")
    suspend fun selectLanguage(id: Int?, isSelected: Int)

    @Query("UPDATE Language SET item_isSelected=:isSelected WHERE id=:id")
    suspend fun unselectLanguage(id: Int?, isSelected: Int)

    @Query("UPDATE Language SET item_selectCounter=:selectCounter WHERE id=:id")
    suspend fun updateCounter(id: Int?, selectCounter: Int)

    @Query("SELECT * FROM Language WHERE item_isSelected=:isSelected ORDER BY item_selectCounter DESC")
    fun getSelectedLanguages(isSelected: Int): List<Language>
}