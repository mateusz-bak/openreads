package com.example.mybooks.ui.bookslist.viewmodel

import androidx.lifecycle.ViewModel
import com.example.mybooks.data.db.entities.Book
import com.example.mybooks.data.repositories.BooksRepository
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

    fun updateBook(id: Int?, bookTitle: String, bookAuthor: String, bookRating: Float, bookStatus: String) = CoroutineScope(Dispatchers.Main).launch {
        repository.updateBook(id, bookTitle, bookAuthor, bookRating, bookStatus)
    }

    fun searchBooks(searchQuery: String) = repository.searchBooks(searchQuery)
}