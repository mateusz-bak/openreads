package com.example.mybooks.ui.bookslist.toreadbooks

import com.example.mybooks.data.db.entities.Book

interface EditToReadBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}