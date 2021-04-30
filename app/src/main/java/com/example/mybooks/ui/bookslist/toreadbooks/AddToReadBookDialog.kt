package com.example.mybooks.ui.bookslist.toreadbooks//package com.example.mybooks.ui.bookslist.readbooks

import android.content.Context
import android.os.Bundle
import android.view.Window
import com.example.mybooks.R
import androidx.appcompat.app.AppCompatDialog
import com.example.mybooks.data.db.entities.Book
import kotlinx.android.synthetic.main.dialog_edit_read_book.*

class AddToReadBookDialog(context: Context, var addToReadBookDialogListener: AddToReadBookDialogListener) : AppCompatDialog(context) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_add_to_read_book)

        btnEditorSaveBook.setOnClickListener {
            val editedTitle = etEditorBookTitle.text.toString()
            val editedAuthor = etEditorAuthor.text.toString()

            val editedBook = Book(editedTitle, editedAuthor, bookRating = 0.0F, bookStatus = "to_read", bookPriority = "none", bookStartDate = "none", bookFinishDate = "none")
            addToReadBookDialogListener.onSaveButtonClicked(editedBook)
            dismiss()
        }
    }
}