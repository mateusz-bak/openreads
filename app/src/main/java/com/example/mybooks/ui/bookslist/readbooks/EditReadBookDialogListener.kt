package com.example.mybooks.ui.bookslist.readbooks

import com.example.mybooks.data.db.entities.Book

interface EditReadBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}