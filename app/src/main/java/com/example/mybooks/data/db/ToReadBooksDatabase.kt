package com.example.mybooks.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.mybooks.data.db.entities.ToReadBook

@Database(
        entities = [ToReadBook::class],
        version = 1
)
abstract class ToReadBooksDatabase: RoomDatabase() {

    abstract fun getToReadBooksDao(): ToReadBooksDao

    companion object {
        @Volatile
        private var instance: ToReadBooksDatabase? = null
        private val LOCK = Any()

        operator fun invoke(context: Context) = instance ?: synchronized(LOCK) {
            instance ?: createDatabase(context).also { instance = it }
        }

        private fun createDatabase(context: Context) =
                Room.databaseBuilder(context.applicationContext,
                        ToReadBooksDatabase::class.java, "ToReadBooksDB.db").build()
    }
}