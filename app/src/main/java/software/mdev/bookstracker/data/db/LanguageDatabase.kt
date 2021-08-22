package software.mdev.bookstracker.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import software.mdev.bookstracker.data.db.entities.Language
import software.mdev.bookstracker.other.Constants

@Database(
    entities = [Language::class],
    version = 1
)
abstract class LanguageDatabase : RoomDatabase() {

    abstract fun getLanguageDao(): LanguageDao

    companion object {
        @Volatile
        private var instance: LanguageDatabase? = null
        private val LOCK = Any()

        operator fun invoke(context: Context) = instance ?: synchronized(LOCK) {
            instance ?: createDatabase(context).also { instance = it }
        }

        private fun createDatabase(context: Context) =
            Room.databaseBuilder(
                context.applicationContext,
                LanguageDatabase::class.java,
                Constants.DATABASE_LANGUAGE_FILE_NAME
            ).createFromAsset("database/Language.db")
                .build()


    }
}