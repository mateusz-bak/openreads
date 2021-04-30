package com.example.mybooks.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.example.mybooks.data.db.entities.Book

@Dao
interface BooksDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: Book)

    @Delete
    suspend fun delete(item: Book)

    @Query("SELECT * FROM Book WHERE item_bookStatus LIKE 'read'")
    fun getReadBooks(): LiveData<List<Book>>

    @Query("SELECT * FROM Book WHERE item_bookStatus LIKE 'in_progress'")
    fun getInProgressBooks(): LiveData<List<Book>>

    @Query("SELECT * FROM Book WHERE item_bookStatus LIKE 'to_read'")
    fun getToReadBooks(): LiveData<List<Book>>
}