package com.example.mybooks.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "to_read_books")
data class ToReadBook (
        @ColumnInfo(name = "item_bookTitle")
        var bookTitle: String,
        @ColumnInfo(name = "item_bookAuthor")
        var bookAuthor: String,
        @ColumnInfo(name = "item_bookRating")
        var  bookRating: Float
){
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}