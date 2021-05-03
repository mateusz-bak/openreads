package com.example.mybooks.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import java.io.Serializable

@Entity(tableName = "Book")
data class Book (

        @ColumnInfo(name = "item_bookTitle")
        var bookTitle: String,

        @ColumnInfo(name = "item_bookAuthor")
        var bookAuthor: String,

        @ColumnInfo(name = "item_bookRating")
        var  bookRating: Float,

        @ColumnInfo(name = "item_bookStatus")
        var  bookStatus: String,

        @ColumnInfo(name = "item_bookPriority")
        var  bookPriority: String,

        @ColumnInfo(name = "item_bookStartDate")
        var  bookStartDate: String,

        @ColumnInfo(name = "item_bookFinishDate")
        var  bookFinishDate: String
): Serializable{
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}