package software.mdev.bookstracker.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import software.mdev.bookstracker.data.db.entities.Year

@Dao
interface YearDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: Year)

    @Delete
    suspend fun delete(item: Year)

    @Query("SELECT * FROM Year WHERE item_year LIKE :year LIMIT 1")
    fun getYear(year: Int): LiveData<List<Year>>

    @Query("SELECT * FROM Year ORDER BY item_year DESC")
    fun getYears(): LiveData<List<Year>>

    @Query("UPDATE Year SET item_books=:item_books WHERE item_year=:item_year")
    suspend fun updateYearsNumberOfBooks(item_year: String, item_books: Int)
}