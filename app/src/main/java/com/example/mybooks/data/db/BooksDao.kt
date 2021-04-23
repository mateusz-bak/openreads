package com.example.mybooks.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.example.mybooks.data.db.entities.ListElement

@Dao
interface BooksDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ListElement)

    @Delete
    suspend fun delete(item: ListElement)

    @Query("SELECT * FROM read_books")
    fun getAllListElements(): LiveData<List<ListElement>>
}