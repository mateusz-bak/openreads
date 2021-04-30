package com.example.mybooks.ui.bookslist.readbooks

import com.example.mybooks.data.db.entities.Book

interface AddReadBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}