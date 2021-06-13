package software.mdev.bookstracker.data.repositories

import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.entities.Book

class BooksRepository (
        private val db: BooksDatabase
) {
    suspend fun upsert(item: Book) = db.getBooksDao().upsert(item)

    suspend fun delete(item: Book) = db.getBooksDao().delete(item)

    fun getReadBooks() = db.getBooksDao().getReadBooks()

    fun getInProgressBooks() = db.getBooksDao().getInProgressBooks()

    fun getToReadBooks() = db.getBooksDao().getToReadBooks()

    suspend fun updateBook(
        id: Int?,
        bookTitle: String,
        bookAuthor: String,
        bookRating: Float,
        bookStatus: String,
        bookFinishDateMs: String,
        bookNumberOfPagesInt: Int,
        bookTitle_ASCII: String,
        bookAuthor_ASCII: String
    ) = db.getBooksDao().updateBook(
        id,
        bookTitle,
        bookAuthor,
        bookRating,
        bookStatus,
        bookFinishDateMs,
        bookNumberOfPagesInt,
        bookTitle_ASCII,
        bookAuthor_ASCII
    )

    fun searchBooks(searchQuery: String) = db.getBooksDao().searchBooks(searchQuery)

    fun getSortedBooksByTitleDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByTitleDesc(bookStatus)
    fun getSortedBooksByTitleAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByTitleAsc(bookStatus)
    fun getSortedBooksByAuthorDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByAuthorDesc(bookStatus)
    fun getSortedBooksByAuthorAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByAuthorAsc(bookStatus)
    fun getSortedBooksByRatingDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByRatingDesc(bookStatus)
    fun getSortedBooksByRatingAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByRatingAsc(bookStatus)
    fun getSortedBooksByPagesDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByPagesDesc(bookStatus)
    fun getSortedBooksByPagesAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByPagesAsc(bookStatus)
    fun getSortedBooksByDateDesc(bookStatus: String) = db.getBooksDao().getSortedBooksByDateDesc(bookStatus)
    fun getSortedBooksByDateAsc(bookStatus: String) = db.getBooksDao().getSortedBooksByDateAsc(bookStatus)

    fun getBookCount(bookStatus: String) = db.getBooksDao().getBookCount(bookStatus)
}