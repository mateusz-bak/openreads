package com.example.mybooks.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.example.mybooks.data.db.entities.ReadBook

@Dao
interface ReadBooksDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ReadBook)

    @Delete
    suspend fun delete(item: ReadBook)

    @Query("SELECT * FROM read_books")
    fun getAllReadBooks(): LiveData<List<ReadBook>>
}