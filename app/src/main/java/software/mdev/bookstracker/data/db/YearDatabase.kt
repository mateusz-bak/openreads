package software.mdev.bookstracker.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.other.Constants

@Database(
        entities = [Year::class],
        version = 4
)
abstract class YearDatabase: RoomDatabase() {

    abstract fun getYearDao(): YearDao

    companion object {
        @Volatile
        private var instance: YearDatabase? = null
        private val LOCK = Any()

        operator fun invoke(context: Context) = instance ?: synchronized(LOCK) {
            instance ?: createDatabase(context).also { instance = it }
        }

        private fun createDatabase(context: Context) =
                Room.databaseBuilder(
                    context.applicationContext,
                    YearDatabase::class.java,
                    Constants.DATABASE_YEAR_FILE_NAME
                ).addMigrations(
                    MIGRATION_1_2,
                    MIGRATION_2_3,
                    MIGRATION_3_4
                )
                    .build()

        private val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Year ADD COLUMN year_challenge_books INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE Year ADD COLUMN year_challenge_pages INTEGER NOT NULL DEFAULT 0")
            }
        }

        private val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {

            }
        }

        private val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Year ADD COLUMN item_quickest_book TEXT NOT NULL DEFAULT 'null'")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_quickest_book_val TEXT NOT NULL DEFAULT 'null'")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_longest_book TEXT NOT NULL DEFAULT 'null'")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_longest_book_val INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_avg_reading_time TEXT NOT NULL DEFAULT 'null'")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_avg_pages INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_shortest_book TEXT NOT NULL DEFAULT 'null'")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_shortest_book_val INTEGER NOT NULL DEFAULT 0")
            }
        }
    }
}