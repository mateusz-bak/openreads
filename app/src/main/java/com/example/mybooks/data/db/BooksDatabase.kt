package com.example.mybooks.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.mybooks.data.db.entities.ListElement

@Database(
        entities = [ListElement::class],
        version = 1
)
abstract class BooksDatabase: RoomDatabase() {

    abstract fun getBooksDao(): BooksDao

    companion object {
        @Volatile
        private var instance: BooksDatabase? = null
        private val LOCK = Any()

        operator fun invoke(context: Context) = instance ?: synchronized(LOCK) {
            instance ?: createDatabase(context).also { instance = it }
        }

        private fun createDatabase(context: Context) =
                Room.databaseBuilder(context.applicationContext,
                        BooksDatabase::class.java, "BooksDB.db").build()
    }
}