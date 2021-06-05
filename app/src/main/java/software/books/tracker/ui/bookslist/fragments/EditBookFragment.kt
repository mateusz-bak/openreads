package software.books.tracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import software.books.tracker.R
import software.books.tracker.data.db.BooksDatabase
import software.books.tracker.data.db.entities.Book
import software.books.tracker.data.repositories.BooksRepository
import software.books.tracker.ui.bookslist.viewmodel.BooksViewModel
import software.books.tracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import software.books.tracker.ui.bookslist.ListActivity
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.fragment_edit_book.*


class EditBookFragment : Fragment(R.layout.fragment_edit_book) {

    lateinit var viewModel: BooksViewModel
    private val args: EditBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        var whatIsClicked = "nothing"

        val database = BooksDatabase(view.context)
        val repository = BooksRepository(database)
        val factory = BooksViewModelProviderFactory(repository)
        val book = args.book

        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

            etEditedBookTitle.setText(book.bookTitle)
            etEditedBookAuthor.setText(book.bookAuthor)
            rbEditedRating.rating = book.bookRating

            when (book.bookStatus) {
                "read" -> {
                    ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
                    ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                    ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                    whatIsClicked = "read"
                    rbEditedRating.visibility = View.VISIBLE
                }
                "in_progress" -> {
                    ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                    ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
                    ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                    whatIsClicked = "in_progress"
                    rbEditedRating.visibility = View.GONE
                }
                "to_read" -> {
                    ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                    ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                    ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
                    whatIsClicked = "to_read"
                    rbEditedRating.visibility = View.GONE
                }
            }

        ivEditorBookStatusRead.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "read"
            rbEditedRating.visibility = View.VISIBLE
        }

        ivEditorBookStatusInProgress.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "in_progress"
            rbEditedRating.visibility = View.GONE
        }

        ivEditorBookStatusToRead.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.orange_300), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = "to_read"
            rbEditedRating.visibility = View.GONE
        }

        fabSaveEditedBook.setOnClickListener {
            val bookTitle = etEditedBookTitle.text.toString()
            val bookAuthor = etEditedBookAuthor.text.toString()
            var bookRating = 0.0F

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    if (whatIsClicked != "nothing") {
                        when(whatIsClicked){
                            "read" -> bookRating = rbEditedRating.rating
                            "in_progress" -> bookRating = 0.0F
                            "to_read" -> bookRating = 0.0F
                        }

                        val bookStatus = whatIsClicked
                        viewModel.updateBook(book.id, bookTitle, bookAuthor, bookRating, bookStatus)

                        it.hideKeyboard()
                        findNavController().popBackStack()
                        findNavController().popBackStack()
                    } else {
                        Snackbar.make(it, getString(R.string.sbWarningState), Snackbar.LENGTH_SHORT).show()
                    }
                } else {
                    Snackbar.make(it, getString(R.string.sbWarningAuthor), Snackbar.LENGTH_SHORT).show()
                }
            } else {
                Snackbar.make(it, getString(R.string.sbWarningTitle), Snackbar.LENGTH_SHORT).show()
            }
        }

        class UndoBookDeletion : View.OnClickListener {
            override fun onClick(view: View) {
                viewModel.upsert(book)
            }
        }

        fabDeleteBook.setOnClickListener{
            viewModel.delete(book)
            it.hideKeyboard()
            findNavController().popBackStack()
            findNavController().popBackStack()

            Snackbar.make(it, getString(R.string.bookDeleted), Snackbar.LENGTH_LONG)
                .setAction(getString(R.string.undo), UndoBookDeletion())
                .show()
        }
    }

    fun View.hideKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }
}