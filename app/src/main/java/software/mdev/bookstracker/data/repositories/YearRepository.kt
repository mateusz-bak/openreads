package software.mdev.bookstracker.data.repositories

import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Year

class YearRepository(
    private val db: YearDatabase
) {
    suspend fun upsertYear(item: Year) = db.getYearDao().upsert(item)

    suspend fun deleteYear(item: Year) = db.getYearDao().delete(item)

    fun getYear(year: Int) = db.getYearDao().getYear(year)

    fun getYears() = db.getYearDao().getYears()

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
    ) = db.getYearDao().updateYear(
        item_year,
        item_books,
        item_pages,
        item_rating,
        item_challenge_books,
        item_challenge_pages,
        item_quickest_book,
        item_quickest_book_val,
        item_longest_book,
        item_longest_book_val,
        item_avg_reading_time,
        item_avg_pages
    )

    suspend fun updateYearsNumberOfBooks(
        item_year: String,
        item_books: Int
    ) = db.getYearDao().updateYearsNumberOfBooks(
        item_year,
        item_books
    )
}