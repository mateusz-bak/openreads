package software.mdev.bookstracker.ui.bookslist.viewmodel

import android.content.Context
import android.util.Log
import android.widget.Toast
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
import software.mdev.bookstracker.R
import software.mdev.bookstracker.api.models.OpenLibraryBook
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse
import software.mdev.bookstracker.api.models.OpenLibrarySearchTitleResponse
import software.mdev.bookstracker.data.db.entities.Language
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.other.Resource
import java.lang.Exception
import java.net.UnknownHostException

class BooksViewModel(
        private val repository: BooksRepository,
        private val yearRepository: YearRepository,
        private val openLibraryRepository: OpenLibraryRepository,
        private val languageRepository: LanguageRepository
): ViewModel() {

    val openLibrarySearchResult: MutableLiveData<Resource<OpenLibrarySearchTitleResponse>> = MutableLiveData()
    var openLibraryBooksByOLID: MutableLiveData<List<Resource<OpenLibraryOLIDResponse>>> = MutableLiveData()
    var showLoadingCircle: MutableLiveData<Boolean> = MutableLiveData()
    var selectedLanguages: MutableLiveData<List<Language>> = MutableLiveData()
    var getBooksTrigger: MutableLiveData<Long> = MutableLiveData()

    fun upsert(item: Book) = CoroutineScope(Dispatchers.Main).launch {
        repository.upsert(item)
    }

    fun delete(item: Book) = CoroutineScope(Dispatchers.Main).launch {
        repository.delete(item)
    }

    fun getBook(id: Int?) = repository.getBook(id)

    fun getNotDeletedBooks() = repository.getNotDeletedBooks()

    fun updateBook(
        id: Int?,
        bookTitle: String,
        bookAuthor: String,
        bookRating: Float,
        bookStatus: String,
        bookPriority: String,
        bookStartDateMs: String,
        bookFinishDateMs: String,
        bookNumberOfPagesInt: Int,
        bookTitle_ASCII: String,
        bookAuthor_ASCII: String,
        bookIsDeleted: Boolean,
        bookCoverUrl: String,
        bookOLID: String,
        bookISBN10: String,
        bookISBN13: String,
        bookPublishYear: Int,
        bookIsFav: Boolean,
        bookCoverImg: ByteArray?,
        bookNotes: String
    ) = CoroutineScope(Dispatchers.Main).launch {
        repository.updateBook(
            id,
            bookTitle,
            bookAuthor,
            bookRating,
            bookStatus,
            bookPriority,
            bookStartDateMs,
            bookFinishDateMs,
            bookNumberOfPagesInt,
            bookTitle_ASCII,
            bookAuthor_ASCII,
            bookIsDeleted,
            bookCoverUrl,
            bookOLID,
            bookISBN10,
            bookISBN13,
            bookPublishYear,
            bookIsFav,
            bookCoverImg,
            bookNotes
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
    fun getSortedBooksByStartDateDesc(bookStatus: String) = repository.getSortedBooksByStartDateDesc(bookStatus)
    fun getSortedBooksByStartDateAsc(bookStatus: String) = repository.getSortedBooksByStartDateAsc(bookStatus)
    fun getSortedBooksByFinishDateDesc(bookStatus: String) = repository.getSortedBooksByFinishDateDesc(bookStatus)
    fun getSortedBooksByFinishDateAsc(bookStatus: String) = repository.getSortedBooksByFinishDateAsc(bookStatus)

    fun getBookCount(bookStatus: String) = repository.getBookCount(bookStatus)

    fun upsertYear(item: Year) = CoroutineScope(Dispatchers.Main).launch {
        yearRepository.upsertYear(item)
    }

    fun deleteYear(item: Year) = CoroutineScope(Dispatchers.Main).launch {
        yearRepository.deleteYear(item)
    }

    fun getYear(year: Int) = yearRepository.getYear(year)

    fun getYears() = yearRepository.getYears()

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

    suspend fun searchBooksInOpenLibrary(searchQuery: String, context: Context?) {
        showLoadingCircle.postValue(true)

        try {
            val response = openLibraryRepository.searchBooksInOpenLibrary(searchQuery)
            showLoadingCircle.postValue(true)
            openLibrarySearchResult.postValue(handleSearchBooksInOpenLibraryResponse(response))
            showLoadingCircle.postValue(false)
        } catch (e: Exception) {
            Log.e("OpenLibrary connection error", "in searchBooksInOpenLibrary: $e")
            showLoadingCircle.postValue(false)

            when(e) {
                is UnknownHostException -> Toast.makeText(context?.applicationContext, R.string.toast_no_connection_to_OL, Toast.LENGTH_SHORT).show()
            }
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

    fun getBooksByOLID(list: MutableList<OpenLibraryBook>?, context: Context?) = viewModelScope.launch {
        showLoadingCircle.postValue(true)

        if (list != null) {
            for (item in list) {

                item.isbn?.let {
                    for (isbn in it) {

                        try {
                            showLoadingCircle.postValue(true)
                            val response = openLibraryRepository.getBookFromOLID("$isbn.json")
                            showLoadingCircle.postValue(true)
                            val handledResponse = handleGetBooksByOLIDResponse(response)

                                var authorsList = emptyList<OpenLibraryOLIDResponse.Author>()

                                for ((j, i) in item.author_name.withIndex()) {
                                    authorsList += OpenLibraryOLIDResponse.Author(item.author_name[j])
                                }
                                handledResponse.data?.authors = authorsList

                            if (openLibraryBooksByOLID.value == null) {
                                var emptyList = emptyList<Resource<OpenLibraryOLIDResponse>>()
                                var listToPost: List<Resource<OpenLibraryOLIDResponse>> =
                                    emptyList + handledResponse

                                showLoadingCircle.postValue(false)
                                if (isActive) {
                                    showLoadingCircle.postValue(true)
                                    openLibraryBooksByOLID.postValue(listToPost)
                                }
                            } else {
                                showLoadingCircle.postValue(false)
                                if (isActive) {
                                    showLoadingCircle.postValue(true)
                                    openLibraryBooksByOLID.postValue(
                                        openLibraryBooksByOLID.value?.plus(
                                            handleGetBooksByOLIDResponse(response)
                                        )
                                    )
                                }
                            }
                            showLoadingCircle.postValue(false)
                        } catch (e: Exception) {
                            Log.e("OpenLibrary connection error", "in getBooksByOLID: $e")
                            showLoadingCircle.postValue(false)

                            when(e) {
                                is UnknownHostException -> Toast.makeText(context?.applicationContext, R.string.toast_no_connection_to_OL, Toast.LENGTH_SHORT).show()
                            }
                        }
                    }
                }
            }
        }
    }

//    fun handleGetAuthorFromOLID(response: Response<OpenLibraryAuthor>): Resource<OpenLibraryAuthor> {
//        if (response.isSuccessful) {
//            response.body()?.let { resultResponse ->
//                return Resource.Success(resultResponse)
//            }
//        }
//        return Resource.Error(response.message())
//    }
//
//    suspend fun getAuthorFromOLID(author: String) =  openLibraryRepository.getAuthorFromOLID(author)

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