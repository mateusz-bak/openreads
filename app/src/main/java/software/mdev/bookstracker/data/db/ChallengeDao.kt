package software.mdev.bookstracker.data.db

import androidx.lifecycle.LiveData
import androidx.room.*
import software.mdev.bookstracker.data.db.entities.Challenge

@Dao
interface ChallengeDao {

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(item: Challenge)

    @Delete
    suspend fun delete(item: Challenge)

    @Query("SELECT * FROM Challenge")
    fun getChallenges(): LiveData<List<Challenge>>

    @Query("SELECT * FROM Challenge WHERE item_challengeYear LIKE :challengeYear")
    fun getChallenge(challengeYear: Int): LiveData<List<Challenge>>

    @Query("UPDATE Challenge SET item_challengeYear =:challengeYear ,item_challengeBooks=:challengeBooks ,item_challengePages=:challengePages WHERE id=:id")
    suspend fun updateChallenge(id: Int?, challengeYear: Int, challengeBooks: Int, challengePages: Int)
}