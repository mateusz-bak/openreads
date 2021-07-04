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
        item_challenge_pages: Int
    ) = db.getYearDao().updateYear(
        item_year,
        item_books,
        item_pages,
        item_rating,
        item_challenge_books,
        item_challenge_pages
    )

    suspend fun updateYearsNumberOfBooks(
        item_year: String,
        item_books: Int
    ) = db.getYearDao().updateYearsNumberOfBooks(
        item_year,
        item_books
    )
}