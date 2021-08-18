package software.mdev.bookstracker.ui.bookslist.viewmodel

import android.util.Log
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import kotlinx.coroutines.*
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import retrofit2.Response
import software.mdev.bookstracker.api.models.OpenLibraryAuthor
import software.mdev.bookstracker.api.models.OpenLibraryBook
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse
import software.mdev.bookstracker.api.models.OpenLibrarySearchTitleResponse
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.other.Resource
import java.lang.Exception
import java.text.Normalizer

class BooksViewModel(
        private val repository: BooksRepository,
        private val yearRepository: YearRepository,
        private val openLibraryRepository: OpenLibraryRepository,
        private val languageRepository: LanguageRepository
): ViewModel() {

    val openLibrarySearchResult: MutableLiveData<Resource<OpenLibrarySearchTitleResponse>> = MutableLiveData()
    var openLibraryBooksByOLID: MutableLiveData<List<Resource<OpenLibraryOLIDResponse>>> = MutableLiveData()
    var showLoadingCircle: MutableLiveData<Boolean> = MutableLiveData()

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

    suspend fun searchBooksInOpenLibrary(searchQuery: String) {
        showLoadingCircle.postValue(true)

        val REGEX_UNACCENT = "\\p{InCombiningDiacriticalMarks}+".toRegex()
        fun CharSequence.unaccent(): String {
            val temp = Normalizer.normalize(this, Normalizer.Form.NFD)
            return REGEX_UNACCENT.replace(temp, "")
        }

        val searchQueryASCII = searchQuery.unaccent().replace("ł", "l", false)

        try {
            val response = openLibraryRepository.searchBooksInOpenLibrary(searchQueryASCII)
            openLibrarySearchResult.postValue(handleSearchBooksInOpenLibraryResponse(response))
            showLoadingCircle.postValue(false)
        } catch (e: Exception) {
            // TODO - add a toast with error description
            Log.e("OpenLibrary connection error", "in searchBooksInOpenLibrary: $e")
            showLoadingCircle.postValue(false)
        }
    }

    private fun handleGetBooksByOLIDResponse(response: Response<OpenLibraryOLIDResponse>): Resource<OpenLibraryOLIDResponse> {
        if (response.isSuccessful) {
            response.body()?.let { resultResponse ->
                return Resource.Success(resultResponse)
            }
        }
        return Resource.Error(response.message())
    }

    fun getBooksByOLID(list: MutableList<OpenLibraryBook>?) = viewModelScope.launch {
        showLoadingCircle.postValue(true)

        if (list != null) {
            for (item in list) {

                item.isbn?.let {
                    for (isbn in it) {

                        try {
                            val response = openLibraryRepository.getBookFromOLID("$isbn.json")
                            val handledResponse = handleGetBooksByOLIDResponse(response)

                            if (openLibraryBooksByOLID.value == null) {
                                var emptyList = emptyList<Resource<OpenLibraryOLIDResponse>>()
                                var listToPost: List<Resource<OpenLibraryOLIDResponse>> =
                                    emptyList + handledResponse

                                if (isActive)
                                    openLibraryBooksByOLID.postValue(listToPost)
                            } else {
                                if (isActive) {
                                    openLibraryBooksByOLID.postValue(
                                        openLibraryBooksByOLID.value?.plus(
                                            handleGetBooksByOLIDResponse(response)
                                        )
                                    )
                                }
                            }
                            showLoadingCircle.postValue(false)
                        } catch (e: Exception) {
                            // TODO - add a toast with error description
                            Log.e("OpenLibrary connection error", "in getBooksByOLID: $e")
                            showLoadingCircle.postValue(false)
                        }
                    }
                }
            }
        }
    }

    fun handleGetAuthorFromOLID(response: Response<OpenLibraryAuthor>): Resource<OpenLibraryAuthor> {
        if (response.isSuccessful) {
            response.body()?.let { resultResponse ->
                return Resource.Success(resultResponse)
            }
        }
        return Resource.Error(response.message())
    }

    suspend fun getAuthorFromOLID(author: String) =  openLibraryRepository.getAuthorFromOLID(author)

    fun getLanguages() = languageRepository.getLanguages()

    fun selectLanguage(id: Int?) = CoroutineScope(Dispatchers.Main).launch {
        languageRepository.selectLanguage(id, 1)
    }

    fun unselectLanguage(id: Int?) = CoroutineScope(Dispatchers.Main).launch {
        languageRepository.unselectLanguage(id, 0)
    }

    fun updateCounter(id: Int?, selectCounter: Int) = CoroutineScope(Dispatchers.Main).launch {
        languageRepository.updateCounter(id, selectCounter)
    }

    fun getSelectedLanguages() = languageRepository.getSelectedLanguages(1)
}