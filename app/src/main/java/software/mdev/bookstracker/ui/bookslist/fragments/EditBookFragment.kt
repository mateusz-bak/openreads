package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import software.mdev.bookstracker.ui.bookslist.ListActivity
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.fragment_edit_book.*
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_IN_PROGRESS
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_NOTHING
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_READ
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_TO_READ
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_NAME
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_AMBER_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_BLUE_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_CYAN_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_GREEN_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_INDIGO_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_LIME_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_PINK_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_PURPLE_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_TEAL_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_YELLOW_500


class EditBookFragment : Fragment(R.layout.fragment_edit_book) {

    lateinit var viewModel: BooksViewModel
    private val args: EditBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        var whatIsClicked = BOOK_STATUS_NOTHING

        val database = BooksDatabase(view.context)
        val repository = BooksRepository(database)
        val factory = BooksViewModelProviderFactory(repository)
        val book = args.book
        var accentColor = getAccentColor(view.context)

        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        etEditedBookTitle.setText(book.bookTitle)
        etEditedBookAuthor.setText(book.bookAuthor)
        rbEditedRating.rating = book.bookRating

        when (book.bookStatus) {
            BOOK_STATUS_READ -> {
                ivEditorBookStatusRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                whatIsClicked = BOOK_STATUS_READ
                rbEditedRating.visibility = View.VISIBLE
            }
            BOOK_STATUS_IN_PROGRESS -> {
                ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusInProgress.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                whatIsClicked = BOOK_STATUS_IN_PROGRESS
                rbEditedRating.visibility = View.GONE
            }
            BOOK_STATUS_TO_READ -> {
                ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusToRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
                whatIsClicked = BOOK_STATUS_TO_READ
                rbEditedRating.visibility = View.GONE
            }
        }

        ivEditorBookStatusRead.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = BOOK_STATUS_READ
            rbEditedRating.visibility = View.VISIBLE
        }

        ivEditorBookStatusInProgress.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = BOOK_STATUS_IN_PROGRESS
            rbEditedRating.visibility = View.GONE
        }

        ivEditorBookStatusToRead.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = BOOK_STATUS_TO_READ
            rbEditedRating.visibility = View.GONE
        }

        fabSaveEditedBook.setOnClickListener {
            val bookTitle = etEditedBookTitle.text.toString()
            val bookAuthor = etEditedBookAuthor.text.toString()
            var bookRating = 0.0F

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    if (whatIsClicked != BOOK_STATUS_NOTHING) {
                        when(whatIsClicked){
                            BOOK_STATUS_READ -> bookRating = rbEditedRating.rating
                            BOOK_STATUS_IN_PROGRESS -> bookRating = 0.0F
                            BOOK_STATUS_TO_READ -> bookRating = 0.0F
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

    fun getAccentColor(context: Context): Int {
        var accentColor = ContextCompat.getColor(context, R.color.amber_500)

        val sharedPref = (activity as ListActivity).getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_ACCENT, THEME_ACCENT_AMBER_500).toString()

        when(accent){
            THEME_ACCENT_AMBER_500 -> accentColor = ContextCompat.getColor(context, R.color.amber_500)
            THEME_ACCENT_BLUE_500 -> accentColor = ContextCompat.getColor(context, R.color.blue_500)
            THEME_ACCENT_CYAN_500 -> accentColor = ContextCompat.getColor(context, R.color.cyan_500)
            THEME_ACCENT_GREEN_500 -> accentColor = ContextCompat.getColor(context, R.color.green_500)
            THEME_ACCENT_INDIGO_500 -> accentColor = ContextCompat.getColor(context, R.color.indigo_500)
            THEME_ACCENT_LIME_500 -> accentColor = ContextCompat.getColor(context, R.color.lime_500)
            THEME_ACCENT_PINK_500 -> accentColor = ContextCompat.getColor(context, R.color.pink_500)
            THEME_ACCENT_PURPLE_500 -> accentColor = ContextCompat.getColor(context, R.color.purple_500)
            THEME_ACCENT_TEAL_500 -> accentColor = ContextCompat.getColor(context, R.color.teal_500)
            THEME_ACCENT_YELLOW_500 -> accentColor = ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}