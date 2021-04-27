package com.example.mybooks.ui.bookslist

import android.content.Context
import android.os.Bundle
import android.view.Window
import com.example.mybooks.R
import androidx.appcompat.app.AppCompatDialog
import com.example.mybooks.data.db.entities.ReadBook
import kotlinx.android.synthetic.main.dialog_edit_list_element.*

class EditReadBookDialog(context: Context, val curBook: ReadBook, var editReadBookDialogListener: EditReadBookDialogListener) : AppCompatDialog(context) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_edit_list_element)

        etEditorBookTitle.setText(curBook.bookTitle)
        etEditorAuthor.setText(curBook.bookAuthor)
        rbEditorRating.rating = curBook.bookRating

        btnEditorSaveBook.setOnClickListener {
            val editedTitle = etEditorBookTitle.text.toString()
            val editedAuthor = etEditorAuthor.text.toString()
            val editedRating = rbEditorRating.rating

            val editedBook = ReadBook(editedTitle, editedAuthor, editedRating)
            editReadBookDialogListener.onSaveButtonClicked(editedBook)
            dismiss()
        }
    }
}