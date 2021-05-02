package com.example.mybooks.ui.bookslist.readbooks//package com.example.mybooks.ui.bookslist.readbooks

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import com.example.mybooks.R
import androidx.appcompat.app.AppCompatDialog
import androidx.core.content.ContextCompat
import com.example.mybooks.data.db.entities.Book
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.dialog_add_read_book.*
import kotlinx.android.synthetic.main.dialog_edit_read_book.btnEditorSaveBook
import kotlinx.android.synthetic.main.dialog_edit_read_book.etEditorAuthor
import kotlinx.android.synthetic.main.dialog_edit_read_book.etEditorBookTitle
import kotlinx.android.synthetic.main.dialog_edit_read_book.rbEditorRating

class AddReadBookDialog(context: Context, var addReadBookDialogListener: AddReadBookDialogListener) : AppCompatDialog(context) {

    var whatIsClicked: String = "nothing"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_add_read_book)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        rbEditorRating.visibility = View.GONE

        ivBookStatusRead.setOnClickListener {
            ivBookStatusRead.setColorFilter(ContextCompat.getColor(context, R.color.teal_200), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusInProgress.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusToRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "read"
            rbEditorRating.visibility = View.VISIBLE
        }

        ivBookStatusInProgress.setOnClickListener {
            ivBookStatusRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusInProgress.setColorFilter(ContextCompat.getColor(context, R.color.teal_200), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusToRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "in_progress"
            rbEditorRating.visibility = View.GONE
        }

        ivBookStatusToRead.setOnClickListener {
            ivBookStatusRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusInProgress.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusToRead.setColorFilter(ContextCompat.getColor(context, R.color.teal_200), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "to_read"
            rbEditorRating.visibility = View.GONE
        }

        btnEditorSaveBook.setOnClickListener {
            var bookTitle = etEditorBookTitle.text.toString()
            var bookAuthor = etEditorAuthor.text.toString()
            var bookRating = 0.0F

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    if (whatIsClicked != "nothing") {
                        when(whatIsClicked){
                            "read" -> bookRating = rbEditorRating.rating
                            "in_progress" -> bookRating = 0.0F
                            "to_read" -> bookRating = 0.0F
                        }
                        val editedBook = Book(bookTitle, bookAuthor, bookRating, bookStatus = whatIsClicked, bookPriority = "none", bookStartDate = "none", bookFinishDate = "none")
                        addReadBookDialogListener.onSaveButtonClicked(editedBook)
                        dismiss()
                    } else {
                        Snackbar.make(it, "Select book's state", Snackbar.LENGTH_SHORT).show()
                    }
                } else {
                    Snackbar.make(it, "Fill in the author", Snackbar.LENGTH_SHORT).show()
                }
            } else {
                Snackbar.make(it, "Fill in the title", Snackbar.LENGTH_SHORT).show()
            }
        }
    }
}