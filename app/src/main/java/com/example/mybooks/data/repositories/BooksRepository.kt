package com.example.mybooks.data.repositories

import com.example.mybooks.data.db.BooksDatabase
import com.example.mybooks.data.db.entities.Book

class BooksRepository (
        private val db: BooksDatabase
) {
    suspend fun upsert(item: Book) = db.getBooksDao().upsert(item)

    suspend fun delete(item: Book) = db.getBooksDao().delete(item)

    fun getReadBooks() = db.getBooksDao().getReadBooks()

    fun getInProgressBooks() = db.getBooksDao().getInProgressBooks()

    fun getToReadBooks() = db.getBooksDao().getToReadBooks()

    suspend fun updateBook(id: Int?, bookTitle: String, bookAuthor: String, bookRating: Float, bookStatus: String) = db.getBooksDao().updateBook(id, bookTitle, bookAuthor, bookRating, bookStatus)

    fun searchBooks(searchQuery: String) = db.getBooksDao().searchBooks(searchQuery)

    fun getSortedBooksByTitleDesc() = db.getBooksDao().getSortedBooksByTitleDesc()

    fun getSortedBooksByTitleAsc() = db.getBooksDao().getSortedBooksByTitleAsc()
}