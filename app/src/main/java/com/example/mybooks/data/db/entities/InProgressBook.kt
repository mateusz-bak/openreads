package com.example.mybooks.data.db.entities

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "in_progress_books")
data class InProgressBook (
        @ColumnInfo(name = "item_bookTitle")
        var bookTitle: String,
        @ColumnInfo(name = "item_bookAuthor")
        var bookAuthor: String
){
    @PrimaryKey(autoGenerate = true)
    var id: Int? = null
}