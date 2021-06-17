package software.mdev.bookstracker.data.db

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import software.mdev.bookstracker.data.db.entities.Challenge
import software.mdev.bookstracker.other.Constants

@Database(
        entities = [Challenge::class],
        version = 1
)
abstract class ChallengeDatabase: RoomDatabase() {

    abstract fun getChallengeDao(): ChallengeDao

    companion object {
        @Volatile
        private var instance: ChallengeDatabase? = null
        private val LOCK = Any()

        operator fun invoke(context: Context) = instance ?: synchronized(LOCK) {
            instance ?: createDatabase(context).also { instance = it }
        }

        private fun createDatabase(context: Context) =
                Room.databaseBuilder(
                    context.applicationContext,
                    ChallengeDatabase::class.java,
                    Constants.DATABASE_CHALLENGE_FILE_NAME
                ).build()
    }
}