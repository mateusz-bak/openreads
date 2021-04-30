package com.example.mybooks.ui.bookslist.inprogressbooks

import android.content.Context
import android.os.Bundle
import android.view.Window
import com.example.mybooks.R
import androidx.appcompat.app.AppCompatDialog
import com.example.mybooks.data.db.entities.Book
import kotlinx.android.synthetic.main.dialog_edit_in_progress_book.*

class EditInProgressBookDialog(context: Context, val curBook: Book, var editInProgressBookDialogListener: EditInProgressBookDialogListener) : AppCompatDialog(context) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_edit_in_progress_book)

        etEditorBookTitle.setText(curBook.bookTitle)
        etEditorAuthor.setText(curBook.bookAuthor)

        btnEditorSaveBook.setOnClickListener {
            val editedTitle = etEditorBookTitle.text.toString()
            val editedAuthor = etEditorAuthor.text.toString()

            val editedBook = Book(editedTitle, editedAuthor, bookRating = 0.0F, bookStatus = "in_progress", bookPriority = "none", bookStartDate = "none", bookFinishDate = "none")
            editInProgressBookDialogListener.onSaveButtonClicked(editedBook)
            dismiss()
        }
    }
}