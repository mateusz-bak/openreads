package software.mdev.tracker.ui.bookslist.dialogs

import software.mdev.tracker.data.db.entities.Book

interface AddBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}