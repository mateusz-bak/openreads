package com.example.mybooks.ui.bookslist

import androidx.lifecycle.ViewModel
import com.example.mybooks.data.db.entities.ListElement
import com.example.mybooks.data.repositories.BooksRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class BooksViewModel(
        private val repository: BooksRepository
): ViewModel() {

    fun upsert(item: ListElement) = CoroutineScope(Dispatchers.Main).launch {
        repository.upsert(item)
    }

    fun delete(item: ListElement) = CoroutineScope(Dispatchers.Main).launch {
        repository.delete(item)
    }

    fun getAllListElements() = repository.getAllListElements()
}