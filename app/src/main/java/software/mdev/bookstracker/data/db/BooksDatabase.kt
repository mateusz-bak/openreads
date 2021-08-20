package software.mdev.bookstracker.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.other.Constants.DATABASE_FILE_NAME

@Database(
        entities = [Book::class],
        version = 6
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
                Room.databaseBuilder(
                    context.applicationContext,
                    BooksDatabase::class.java,
                    DATABASE_FILE_NAME
                ).addMigrations(
                    MIGRATION_1_2,
                    MIGRATION_2_3,
                    MIGRATION_3_4,
                    MIGRATION_4_5,
                    MIGRATION_5_6
                )
                .build()

        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookNumberOfPages INTEGER NOT NULL DEFAULT 0")
            }
        }

        val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookTitle_ASCII TEXT NOT NULL DEFAULT 'not_converted'")
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookAuthor_ASCII TEXT NOT NULL DEFAULT 'not_converted'")
            }
        }

        private val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookIsDeleted INTEGER NOT NULL DEFAULT 0")
            }
        }

        private val MIGRATION_4_5 = object : Migration(4, 5) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookCoverUrl TEXT NOT NULL DEFAULT 'none'")
            }
        }

        private val MIGRATION_5_6 = object : Migration(5, 6) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookOLID TEXT NOT NULL DEFAULT 'none'")
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookISBN10 TEXT NOT NULL DEFAULT 'none'")
                database.execSQL("ALTER TABLE Book ADD COLUMN item_bookISBN13 TEXT NOT NULL DEFAULT 'none'")
            }
        }
    }
}