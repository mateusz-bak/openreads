package com.example.mybooks.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import com.example.mybooks.data.db.entities.InProgressBook

@Dao
interface InProgressBooksDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: InProgressBook)

    @Delete
    suspend fun delete(item: InProgressBook)

    @Query("SELECT * FROM in_progress_books")
    fun getAllListElements(): LiveData<List<InProgressBook>>
}