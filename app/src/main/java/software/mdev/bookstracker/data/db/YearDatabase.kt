package software.mdev.bookstracker.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.TypeConverters
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Converters

@Database(
        entities = [Year::class],
        version = 7
)

@TypeConverters(Converters::class)
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
                    MIGRATION_3_4,
                    MIGRATION_5_6,
                    MIGRATION_6_7
                )
                    .fallbackToDestructiveMigration()
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

        private val MIGRATION_5_6 = object : Migration(5, 6) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Year ADD COLUMN item_read_books INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_in_progress_books INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_to_read_books INTEGER NOT NULL DEFAULT 0")
            }
        }

        private val MIGRATION_6_7 = object : Migration(6, 7) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE Year ADD COLUMN item_longest_read_book TEXT NOT NULL DEFAULT 'null'")
                database.execSQL("ALTER TABLE Year ADD COLUMN item_longest_read_val TEXT NOT NULL DEFAULT 'null'")
            }
        }
    }
}