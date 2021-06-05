package software.mdev.tracker.data.repositories

import software.mdev.tracker.data.db.BooksDatabase
import software.mdev.tracker.data.db.entities.Book

class BooksRepository (
        private val db: BooksDatabase
) {
    suspend fun upsert(item: Book) = db.getBooksDao().upsert(item)

    suspend fun delete(item: Book) = db.getBooksDao().delete(item)

    fun getReadBooks() = db.getBooksDao().getReadBooks()

    fun getInProgressBooks() = db.getBooksDao().getInProgressBooks()

    fun getToReadBooks() = db.getBooksDao().getToReadBooks()

    suspend fun updateBook(id: Int?, bookTitle: String, bookAuthor: String, bookRating: Float, bookStatus: String) = db.getBooksDao().updateBook(id, bookTitle, bookAuthor, bookRating, bookStatus)

    fun searchBooks(searchQuery: String) = db.getBooksDao().searchBooks(searchQuery)

    fun getSortedBooksByTitleDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByTitleDesc(bookStatus)
    fun getSortedBooksByTitleAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByTitleAsc(bookStatus)
    fun getSortedBooksByAuthorDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByAuthorDesc(bookStatus)
    fun getSortedBooksByAuthorAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByAuthorAsc(bookStatus)
    fun getSortedBooksByRatingDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByRatingDesc(bookStatus)
    fun getSortedBooksByRatingAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByRatingAsc(bookStatus)
}