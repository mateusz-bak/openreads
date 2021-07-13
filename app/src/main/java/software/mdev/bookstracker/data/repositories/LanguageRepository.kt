package software.mdev.bookstracker.data.repositories

import software.mdev.bookstracker.data.db.LanguageDatabase

class LanguageRepository(
    private val db: LanguageDatabase
) {
    fun getLanguages() = db.getLanguageDao().getLanguages()
}