package com.example.mybooks.data.repositories

import com.example.mybooks.data.db.BooksDatabase
import com.example.mybooks.data.db.entities.ListElement

class BooksRepository (
        private val db: BooksDatabase
) {
    suspend fun upsert(item: ListElement) = db.getBooksDao().upsert(item)

    suspend fun delete(item: ListElement) = db.getBooksDao().delete(item)

    fun getAllListElements() = db.getBooksDao().getAllListElements()
}