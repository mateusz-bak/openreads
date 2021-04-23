package com.example.mybooks.ui.bookslist

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.example.mybooks.data.repositories.BooksRepository

@Suppress("UNCHECKED_CAST")
class BooksViewModelFactory(
        private val repository: BooksRepository
): ViewModelProvider.NewInstanceFactory() {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return BooksViewModel(repository) as T
    }
}