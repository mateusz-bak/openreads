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

    @Query("UPDATE Year SET item_year =:item_year, " +
            "item_books=:item_books, " +
            "item_pages=:item_pages, " +
            "item_rating=:item_rating, " +
            "item_challenge_books=:item_challenge_books, " +
            "item_challenge_pages=:item_challenge_pages, " +
            "item_quickest_book=:item_quickest_book, " +
            "item_quickest_book_val=:item_quickest_book_val, " +
            "item_longest_book=:item_longest_book, " +
            "item_longest_book_val=:item_longest_book_val, " +
            "item_avg_reading_time=:item_avg_reading_time, " +
            "item_avg_pages=:item_avg_pages " +
            "WHERE item_year=:item_year")
    suspend fun updateYear(
        item_year: String,
        item_books: Int,
        item_pages: Int,
        item_rating: Float,
        item_challenge_books: Int,
        item_challenge_pages: Int,
        item_quickest_book: String,
        item_quickest_book_val: String,
        item_longest_book: String,
        item_longest_book_val: Int,
        item_avg_reading_time: String,
        item_avg_pages: Int
    )

    @Query("UPDATE Year SET item_books=:item_books WHERE item_year=:item_year")
    suspend fun updateYearsNumberOfBooks(item_year: String, item_books: Int)
}