package com.example.mybooks.ui.bookslist

import com.example.mybooks.data.db.entities.ListElement

interface EditDialogListener {
    fun onSaveButtonClicked(item: ListElement)
}