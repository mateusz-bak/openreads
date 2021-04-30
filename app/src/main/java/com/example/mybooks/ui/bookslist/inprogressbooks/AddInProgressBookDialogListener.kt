package com.example.mybooks.ui.bookslist.inprogressbooks

import com.example.mybooks.data.db.entities.Book

interface AddInProgressBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}