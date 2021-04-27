package com.example.mybooks.ui.bookslist

import com.example.mybooks.data.db.entities.ReadBook

interface EditReadBookDialogListener {
    fun onSaveButtonClicked(item: ReadBook)
}