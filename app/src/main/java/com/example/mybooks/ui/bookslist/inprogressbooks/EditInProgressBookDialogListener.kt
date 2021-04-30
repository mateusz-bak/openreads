package com.example.mybooks.ui.bookslist.inprogressbooks

import com.example.mybooks.data.db.entities.Book

interface EditInProgressBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}