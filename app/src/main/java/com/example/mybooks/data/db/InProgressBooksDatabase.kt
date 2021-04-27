package com.example.mybooks.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import com.example.mybooks.data.db.entities.InProgressBook

@Database(
        entities = [InProgressBook::class],
        version = 1
)
abstract class InProgressBooksDatabase: RoomDatabase() {

    abstract fun getInProgressBooksDao(): InProgressBooksDao

    companion object {
        @Volatile
        private var instance: InProgressBooksDatabase? = null
        private val LOCK = Any()

        operator fun invoke(context: Context) = instance ?: synchronized(LOCK) {
            instance ?: createDatabase(context).also { instance = it }
        }

        private fun createDatabase(context: Context) =
                Room.databaseBuilder(context.applicationContext,
                        InProgressBooksDatabase::class.java, "InProgressBooksDB.db").build()
    }
}