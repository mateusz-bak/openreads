package com.example.mybooks.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.mybooks.data.db.entities.ReadBook

@Database(
        entities = [ReadBook::class],
        version = 1
)
abstract class ReadBooksDatabase: RoomDatabase() {

    abstract fun getReadBooksDao(): ReadBooksDao

    companion object {
        @Volatile
        private var instance: ReadBooksDatabase? = null
        private val LOCK = Any()

        operator fun invoke(context: Context) = instance ?: synchronized(LOCK) {
            instance ?: createDatabase(context).also { instance = it }
        }

        private fun createDatabase(context: Context) =
                Room.databaseBuilder(context.applicationContext,
                        ReadBooksDatabase::class.java, "ReadBooksDB.db").build()
    }
}