package com.example.mybooks.data.repositories

import com.example.mybooks.data.db.InProgressBooksDatabase
import com.example.mybooks.data.db.entities.InProgressBook

class InProgressBooksRepository (
        private val db: InProgressBooksDatabase
) {
    suspend fun upsert(item: InProgressBook) = db.getInProgressBooksDao().upsert(item)

    suspend fun delete(item: InProgressBook) = db.getInProgressBooksDao().delete(item)

    fun getAllListElements() = db.getInProgressBooksDao().getAllInProgressBooks()
}