package com.example.mybooks.data.repositories

import com.example.mybooks.data.db.ToReadBooksDatabase
import com.example.mybooks.data.db.entities.ToReadBook

class ToReadBooksRepository (
        private val db: ToReadBooksDatabase
) {
    suspend fun upsert(item: ToReadBook) = db.getToReadBooksDao().upsert(item)

    suspend fun delete(item: ToReadBook) = db.getToReadBooksDao().delete(item)

    fun getAllListElements() = db.getToReadBooksDao().getAllListElements()
}