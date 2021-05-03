package com.example.mybooks.ui.bookslist.adder

import com.example.mybooks.data.db.entities.Book

interface AddBookDialogListener {
    fun onSaveButtonClicked(item: Book)
}