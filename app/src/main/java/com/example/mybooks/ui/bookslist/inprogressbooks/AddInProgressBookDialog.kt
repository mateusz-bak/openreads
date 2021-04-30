package com.example.mybooks.ui.bookslist.inprogressbooks//package com.example.mybooks.ui.bookslist.readbooks

import android.content.Context
import android.os.Bundle
import android.view.Window
import com.example.mybooks.R
import androidx.appcompat.app.AppCompatDialog
import com.example.mybooks.data.db.entities.Book
import kotlinx.android.synthetic.main.dialog_edit_read_book.*

class AddInProgressBookDialog(context: Context, var addInProgressBookDialogListener: AddInProgressBookDialogListener) : AppCompatDialog(context) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_add_in_progress_book)

        btnEditorSaveBook.setOnClickListener {
            val editedTitle = etEditorBookTitle.text.toString()
            val editedAuthor = etEditorAuthor.text.toString()

            val editedBook = Book(editedTitle, editedAuthor, bookRating = 0.0F, bookStatus = "in_progress", bookPriority = "none", bookStartDate = "none", bookFinishDate = "none")
            addInProgressBookDialogListener.onSaveButtonClicked(editedBook)
            dismiss()
        }
    }
}