package software.books.tracker.ui.bookslist.dialogs

import software.books.tracker.data.db.entities.Book

interface AddBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}