package software.mdev.bookstracker.ui.bookslist.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import retrofit2.Response
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse
import software.mdev.bookstracker.api.models.OpenLibrarySearchTitleResponse
import software.mdev.bookstracker.other.Resource
import java.lang.Exception

class BooksViewModel(
        private val repository: BooksRepository,
        private val yearRepository: YearRepository,
        private val openLibraryRepository: OpenLibraryRepository
): ViewModel() {

    val booksFromOpenLibrary: MutableLiveData<Resource<OpenLibrarySearchTitleResponse>> = MutableLiveData()
    val booksByOLID: MutableLiveData<Resource<OpenLibraryOLIDResponse>> = MutableLiveData()
    var selectedAuthorsName: String = ""

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
        bookAuthor_ASCII: String,
        bookIsDeleted: Boolean
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
            bookAuthor_ASCII,
            bookIsDeleted
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

    fun upsertYear(item: Year) = CoroutineScope(Dispatchers.Main).launch {
        yearRepository.upsertYear(item)
    }

    fun deleteYear(item: Year) = CoroutineScope(Dispatchers.Main).launch {
        yearRepository.deleteYear(item)
    }

    fun getYear(year: Int) = yearRepository.getYear(year)

    fun getYears() = yearRepository.getYears()

    fun updateYear(
        item_year: String,
        item_books: Int,
        item_pages: Int,
        item_rating: Float,
        item_challenge_books: Int,
        item_challenge_pages: Int
    ) = CoroutineScope(Dispatchers.Main).launch {
        yearRepository.updateYear(
            item_year,
            item_books,
            item_pages,
            item_rating,
            item_challenge_books,
            item_challenge_pages
        )
    }

    fun updateYearsNumberOfBooks(
        item_year: String,
        item_books: Int
    ) = CoroutineScope(Dispatchers.Main).launch {
        yearRepository.updateYearsNumberOfBooks(
            item_year,
            item_books
        )
    }

    fun getDeletedBooks() = repository.getDeletedBooks()

    // OPEN LIBRARY API
    private fun handleSearchBooksInOpenLibraryResponse(response: Response<OpenLibrarySearchTitleResponse>): Resource<OpenLibrarySearchTitleResponse> {
        if (response.isSuccessful) {
            response.body()?.let { resultResponse ->
                return Resource.Success(resultResponse)
            }
        }
        return Resource.Error(response.message())
    }

    fun searchBooksInOpenLibrary(searchQuery: String) = viewModelScope.launch {
        booksFromOpenLibrary.postValue(Resource.Loading())
        val response = openLibraryRepository.searchBooksInOpenLibrary(searchQuery)
        booksFromOpenLibrary.postValue(handleSearchBooksInOpenLibraryResponse(response))
    }

    private fun handleGetBooksByOLIDResponse(response: Response<OpenLibraryOLIDResponse>): Resource<OpenLibraryOLIDResponse> {
        if (response.isSuccessful) {
            response.body()?.let { resultResponse ->
                Log.d("eloo3", response.toString())
                return Resource.Success(resultResponse)
            }
        }
        Log.d("eloo33", response.toString())
        return Resource.Error(response.message())
    }

    fun getBooksByOLID(isbn: String) = viewModelScope.launch {
        Log.d("eloo1", isbn)
        Log.d("eloo1", "$isbn.json")

        booksByOLID.postValue(Resource.Loading())

        try {
            val response = openLibraryRepository.getBookFromOLID("$isbn.json")
            Log.d("eloo4", handleGetBooksByOLIDResponse(response).toString())
            booksByOLID.postValue(handleGetBooksByOLIDResponse(response))
        } catch (e: Exception) {
            Log.d("eloo53", "catched $e")
        }
    }
}