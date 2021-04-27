package com.example.mybooks.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.example.mybooks.data.db.entities.ToReadBook

@Dao
interface ToReadBooksDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: ToReadBook)

    @Delete
    suspend fun delete(item: ToReadBook)

    @Query("SELECT * FROM to_read_books")
    fun getAllToReadBooks(): LiveData<List<ToReadBook>>
}