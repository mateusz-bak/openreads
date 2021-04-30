package com.example.mybooks.ui.bookslist.toreadbooks

import com.example.mybooks.data.db.entities.Book

interface AddToReadBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}