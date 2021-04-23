package com.example.mybooks

import androidx.lifecycle.LiveData
import androidx.room.*

@Dao
interface BooksDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ListElement)

    @Delete
    suspend fun delete(item: ListElement)

    @Query("SELECT * FROM read_books")
    fun getAllListElements(): LiveData<List<ListElement>>
}