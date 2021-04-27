package com.example.mybooks.ui.bookslist

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.example.mybooks.data.repositories.ReadBooksRepository

@Suppress("UNCHECKED_CAST")
class ReadBooksViewModelFactory(
        private val repository: ReadBooksRepository
): ViewModelProvider.NewInstanceFactory() {

    override fun <T : ViewModel?> create(modelClass: Class<T>): T {
        return ReadBooksViewModel(repository) as T
    }
}