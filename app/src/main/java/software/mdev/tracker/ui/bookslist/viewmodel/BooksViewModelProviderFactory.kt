package software.mdev.tracker.ui.bookslist.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import software.mdev.tracker.data.repositories.BooksRepository

@Suppress("UNCHECKED_CAST")
class BooksViewModelProviderFactory(
        private val repository: BooksRepository
): ViewModelProvider.Factory {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return BooksViewModel(repository) as T
    }
}