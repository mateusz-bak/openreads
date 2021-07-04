package software.mdev.bookstracker.ui.bookslist.dialogs

import software.mdev.bookstracker.data.db.entities.Year

interface ChallengeDialogListener {
    fun onSaveButtonClicked(item: Year)
}