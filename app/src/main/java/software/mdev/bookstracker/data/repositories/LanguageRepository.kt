package software.mdev.bookstracker.data.repositories

import software.mdev.bookstracker.data.db.LanguageDatabase

class LanguageRepository(
    private val db: LanguageDatabase
) {
    fun getLanguages() = db.getLanguageDao().getLanguages()

    suspend fun selectLanguage(id: Int?, isSelected: Int) = db.getLanguageDao().selectLanguage(id, isSelected)

    suspend fun unselectLanguage(id: Int?, isSelected: Int) = db.getLanguageDao().unselectLanguage(id, isSelected)

    suspend fun updateCounter(id: Int?, selectCounter: Int) = db.getLanguageDao().updateCounter(id, selectCounter)

    fun getSelectedLanguages(isSelected: Int) = db.getLanguageDao().getSelectedLanguages(isSelected)
}