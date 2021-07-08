package software.mdev.bookstracker.ui.bookslist.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository

@Suppress("UNCHECKED_CAST")
class BooksViewModelProviderFactory(
        private val repository: BooksRepository,
        private val yearRepository: YearRepository,
        private val openLibraryRepository: OpenLibraryRepository
): ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return BooksViewModel(repository, yearRepository, openLibraryRepository) as T
    }
}