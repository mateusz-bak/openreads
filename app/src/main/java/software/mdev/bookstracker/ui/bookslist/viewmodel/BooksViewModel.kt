package software.mdev.bookstracker.ui.bookslist.viewmodel

import androidx.lifecycle.ViewModel
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class BooksViewModel(
        private val repository: BooksRepository
): ViewModel() {

    fun upsert(item: Book) = CoroutineScope(Dispatchers.Main).launch {
        repository.upsert(item)
    }

    fun delete(item: Book) = CoroutineScope(Dispatchers.Main).launch {
        repository.delete(item)
    }

    fun getReadBooks() = repository.getReadBooks()

    fun getInProgressBooks() = repository.getInProgressBooks()

    fun getToReadBooks() = repository.getToReadBooks()

    fun updateBook(
        id: Int?,
        bookTitle: String,
        bookAuthor: String,
        bookRating: Float,
        bookStatus: String,
        bookFinishDateMs: String,
        bookNumberOfPagesInt: Int,
        bookTitle_ASCII: String,
        bookAuthor_ASCII: String
    ) = CoroutineScope(Dispatchers.Main).launch {
        repository.updateBook(
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
    }

    fun searchBooks(searchQuery: String) = repository.searchBooks(searchQuery)

    fun getSortedBooksByTitleDesc(bookStatus: String) = repository.getSortedBooksByTitleDesc(bookStatus)
    fun getSortedBooksByTitleAsc(bookStatus: String) = repository.getSortedBooksByTitleAsc(bookStatus)
    fun getSortedBooksByAuthorDesc(bookStatus: String) = repository.getSortedBooksByAuthorDesc(bookStatus)
    fun getSortedBooksByAuthorAsc(bookStatus: String) = repository.getSortedBooksByAuthorAsc(bookStatus)
    fun getSortedBooksByRatingDesc(bookStatus: String) = repository.getSortedBooksByRatingDesc(bookStatus)
    fun getSortedBooksByRatingAsc(bookStatus: String) = repository.getSortedBooksByRatingAsc(bookStatus)
    fun getSortedBooksByPagesDesc(bookStatus: String) = repository.getSortedBooksByPagesDesc(bookStatus)
    fun getSortedBooksByPagesAsc(bookStatus: String) = repository.getSortedBooksByPagesAsc(bookStatus)
    fun getSortedBooksByDateDesc(bookStatus: String) = repository.getSortedBooksByDateDesc(bookStatus)
    fun getSortedBooksByDateAsc(bookStatus: String) = repository.getSortedBooksByDateAsc(bookStatus)

    fun getBookCount(bookStatus: String) = repository.getBookCount(bookStatus)

}