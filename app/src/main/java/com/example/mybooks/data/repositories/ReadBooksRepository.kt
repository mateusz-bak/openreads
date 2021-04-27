package com.example.mybooks.data.repositories

import com.example.mybooks.data.db.ReadBooksDatabase
import com.example.mybooks.data.db.entities.ReadBook

class ReadBooksRepository (
        private val db: ReadBooksDatabase
) {
    suspend fun upsert(item: ReadBook) = db.getReadBooksDao().upsert(item)

    suspend fun delete(item: ReadBook) = db.getReadBooksDao().delete(item)

    fun getAllListElements() = db.getReadBooksDao().getAllReadBooks()
}