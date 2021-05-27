package com.books.tracker.ui.bookslist.dialogs

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.inputmethod.InputMethodManager
import com.books.tracker.R
import androidx.appcompat.app.AppCompatDialog
import androidx.core.content.ContextCompat
import com.books.tracker.data.db.entities.Book
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.dialog_add_book.*


class AddBookDialog(context: Context, var addBookDialogListener: AddBookDialogListener) : AppCompatDialog(context) {

    var whatIsClicked: String = "nothing"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_add_book)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        rbAdderRating.visibility = View.GONE

        ivBookStatusSetRead.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(ContextCompat.getColor(context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetInProgress.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetToRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "read"
            rbAdderRating.visibility = View.VISIBLE
            it.hideKeyboard()
        }

        ivBookStatusSetInProgress.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetInProgress.setColorFilter(ContextCompat.getColor(context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetToRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "in_progress"
            rbAdderRating.visibility = View.GONE
            it.hideKeyboard()
        }

        ivBookStatusSetToRead.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetInProgress.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetToRead.setColorFilter(ContextCompat.getColor(context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "to_read"
            rbAdderRating.visibility = View.GONE
            it.hideKeyboard()
        }

        btnAdderSaveBook.setOnClickListener {
            val bookTitle = etAdderBookTitle.text.toString()
            val bookAuthor = etAdderAuthor.text.toString()
            var bookRating = 0.0F

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    if (whatIsClicked != "nothing") {
                        when(whatIsClicked){
                            "read" -> bookRating = rbAdderRating.rating
                            "in_progress" -> bookRating = 0.0F
                            "to_read" -> bookRating = 0.0F
                        }
                        val editedBook = Book(bookTitle, bookAuthor, bookRating, bookStatus = whatIsClicked, bookPriority = "none", bookStartDate = "none", bookFinishDate = "none")
                        addBookDialogListener.onSaveButtonClicked(editedBook)
                        dismiss()
                    } else {
                        Snackbar.make(it, R.string.sbWarningState, Snackbar.LENGTH_SHORT).show()
                    }
                } else {
                    Snackbar.make(it, R.string.sbWarningAuthor, Snackbar.LENGTH_SHORT).show()
                }
            } else {
                Snackbar.make(it, R.string.sbWarningTitle, Snackbar.LENGTH_SHORT).show()
            }
        }
    }

    fun View.hideKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }
}
