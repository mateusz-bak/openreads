package com.books.tracker.ui.bookslist.dialogs

import com.books.tracker.data.db.entities.Book

interface AddBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}