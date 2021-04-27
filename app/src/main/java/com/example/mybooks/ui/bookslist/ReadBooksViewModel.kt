package com.example.mybooks.ui.bookslist

import androidx.lifecycle.ViewModel
import com.example.mybooks.data.db.entities.ReadBook
import com.example.mybooks.data.repositories.ReadBooksRepository
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class ReadBooksViewModel(
        private val repository: ReadBooksRepository
): ViewModel() {

    fun upsert(item: ReadBook) = CoroutineScope(Dispatchers.Main).launch {
        repository.upsert(item)
    }

    fun delete(item: ReadBook) = CoroutineScope(Dispatchers.Main).launch {
        repository.delete(item)
    }

    fun getAllListElements() = repository.getAllListElements()
}