package com.example.mybooks.ui.bookslist

import android.content.Context
import android.os.Bundle
import android.view.Window
import com.example.mybooks.R
import androidx.appcompat.app.AppCompatDialog
import com.example.mybooks.data.db.entities.ListElement
import kotlinx.android.synthetic.main.dialog_edit_list_element.*

class EditListElementDialog(context: Context, val curBook: ListElement, var editDialogListener: EditDialogListener) : AppCompatDialog(context) {

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

            val editedBook = ListElement(editedTitle, editedAuthor, editedRating)
            editDialogListener.onSaveButtonClicked(editedBook)
            dismiss()
        }
    }
}