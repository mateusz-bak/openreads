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

    @Query("UPDATE Book SET item_bookTitle =:bookTitle ,item_bookAuthor=:bookAuthor ,item_bookRating=:bookRating ,item_bookStatus=:bookStatus WHERE id=:id")
    suspend fun updateBook(id: Int?, bookTitle: String, bookAuthor: String, bookRating: Float, bookStatus: String)

    @Query("SELECT * FROM Book WHERE (item_bookTitle LIKE '%' || :searchQuery || '%' OR item_bookAuthor LIKE '%' || :searchQuery || '%')")
    fun searchBooks(searchQuery: String): LiveData<List<Book>>
}