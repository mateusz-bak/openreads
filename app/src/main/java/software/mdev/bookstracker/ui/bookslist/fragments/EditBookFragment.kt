package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.DatePicker
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
import java.text.Normalizer
import java.text.SimpleDateFormat
import java.util.*


class EditBookFragment : Fragment(R.layout.fragment_edit_book) {

    lateinit var viewModel: BooksViewModel
    private val args: EditBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity
    private var bookFinishDateMs: Long? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        var whatIsClicked = Constants.BOOK_STATUS_NOTHING

        val database = BooksDatabase(view.context)
        val repository = BooksRepository(database)
        val factory = BooksViewModelProviderFactory(repository)
        val book = args.book
        var accentColor = getAccentColor(view.context)

        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        etEditedBookTitle.setText(book.bookTitle)
        etEditedBookAuthor.setText(book.bookAuthor)
        rbEditedRating.rating = book.bookRating
        etEditedPagesNumber.setText(book.bookNumberOfPages.toString())
        dpEditBookFinishDate.visibility = View.GONE
        btnEditorSaveFinishDate.visibility = View.GONE

        if(book.bookFinishDate == "none" || book.bookFinishDate == "null") {
            btnEditFinishDate.text = getString(R.string.hint_date_finished)
        } else {
            var bookFinishTimeStampLong = book.bookFinishDate.toLong()
            btnEditFinishDate.text = convertLongToTime(bookFinishTimeStampLong)
        }

        etEditedBookTitle.requestFocus()
        view.showKeyboard()

        when (book.bookStatus) {
            Constants.BOOK_STATUS_READ -> {
                ivEditorBookStatusRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                whatIsClicked = Constants.BOOK_STATUS_READ
                rbEditedRating.visibility = View.VISIBLE
                etEditedPagesNumber.visibility = View.VISIBLE
            }
            Constants.BOOK_STATUS_IN_PROGRESS -> {
                ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusInProgress.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                whatIsClicked = Constants.BOOK_STATUS_IN_PROGRESS
                rbEditedRating.visibility = View.GONE
                etEditedPagesNumber.visibility = View.GONE
            }
            Constants.BOOK_STATUS_TO_READ -> {
                ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
                ivEditorBookStatusToRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
                whatIsClicked = Constants.BOOK_STATUS_TO_READ
                rbEditedRating.visibility = View.GONE
                etEditedPagesNumber.visibility = View.GONE
            }
        }

        ivEditorBookStatusRead.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = Constants.BOOK_STATUS_READ
            rbEditedRating.visibility = View.VISIBLE
            etEditedPagesNumber.visibility = View.VISIBLE
        }

        ivEditorBookStatusInProgress.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = Constants.BOOK_STATUS_IN_PROGRESS
            rbEditedRating.visibility = View.GONE
            etEditedPagesNumber.visibility = View.GONE
        }

        ivEditorBookStatusToRead.setOnClickListener {
            ivEditorBookStatusRead.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusInProgress.setColorFilter(ContextCompat.getColor(view.context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivEditorBookStatusToRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = Constants.BOOK_STATUS_TO_READ
            rbEditedRating.visibility = View.GONE
            etEditedPagesNumber.visibility = View.GONE
        }

        btnEditFinishDate.setOnClickListener {
            it.hideKeyboard()

            dpEditBookFinishDate.visibility = View.VISIBLE
            btnEditorSaveFinishDate.visibility = View.VISIBLE
            btnEditorSaveFinishDate.isClickable = true

            etEditedBookTitle.visibility = View.GONE
            etEditedBookAuthor.visibility = View.GONE

            ivEditorBookStatusRead.visibility = View.GONE
            ivEditorBookStatusInProgress.visibility = View.GONE
            ivEditorBookStatusToRead.visibility = View.GONE
            tvFinished.visibility = View.GONE
            tvInProgress.visibility = View.GONE
            tvToRead.visibility = View.GONE

            etEditedPagesNumber.visibility = View.GONE
            rbEditedRating.visibility = View.GONE
            btnEditFinishDate.visibility = View.GONE
            fabSaveEditedBook.visibility = View.GONE
            fabDeleteBook.visibility = View.GONE
        }

        btnEditorSaveFinishDate.setOnClickListener {
            bookFinishDateMs = getDateFromDatePickerInMillis(dpEditBookFinishDate)

            dpEditBookFinishDate.visibility = View.GONE
            btnEditorSaveFinishDate.visibility = View.GONE
            btnEditorSaveFinishDate.isClickable = false

            etEditedBookTitle.visibility = View.VISIBLE
            etEditedBookAuthor.visibility = View.VISIBLE

            ivEditorBookStatusRead.visibility = View.VISIBLE
            ivEditorBookStatusInProgress.visibility = View.VISIBLE
            ivEditorBookStatusToRead.visibility = View.VISIBLE
            tvFinished.visibility = View.VISIBLE
            tvInProgress.visibility = View.VISIBLE
            tvToRead.visibility = View.VISIBLE

            etEditedPagesNumber.visibility = View.VISIBLE
            rbEditedRating.visibility = View.VISIBLE
            btnEditFinishDate.visibility = View.VISIBLE
            fabSaveEditedBook.visibility = View.VISIBLE
            fabDeleteBook.visibility = View.VISIBLE

            btnEditFinishDate.text = bookFinishDateMs?.let { it1 -> convertLongToTime(it1) }
        }

        fabSaveEditedBook.setOnClickListener {
            val bookTitle = etEditedBookTitle.text.toString()
            val bookAuthor = etEditedBookAuthor.text.toString()
            var bookRating = 0.0F
            val bookNumberOfPagesIntOrNull = etEditedPagesNumber.text.toString().toIntOrNull()
            var bookNumberOfPagesInt: Int

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()) {
                    if (whatIsClicked != Constants.BOOK_STATUS_NOTHING) {
                        if (bookNumberOfPagesIntOrNull != null || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS || whatIsClicked == Constants.BOOK_STATUS_TO_READ) {
                            bookNumberOfPagesInt = when (bookNumberOfPagesIntOrNull) {
                                null -> 0
                                else -> bookNumberOfPagesIntOrNull
                            }
                            if (bookNumberOfPagesInt > 0 || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS || whatIsClicked == Constants.BOOK_STATUS_TO_READ) {
                                if (bookFinishDateMs!=null || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS || whatIsClicked == Constants.BOOK_STATUS_TO_READ) {
                                    when (whatIsClicked) {
                                        Constants.BOOK_STATUS_READ -> bookRating = rbEditedRating.rating
                                        Constants.BOOK_STATUS_IN_PROGRESS -> bookRating = 0.0F
                                        Constants.BOOK_STATUS_TO_READ -> bookRating = 0.0F
                                    }

                                    val REGEX_UNACCENT = "\\p{InCombiningDiacriticalMarks}+".toRegex()
                                    fun CharSequence.unaccent(): String {
                                        val temp = Normalizer.normalize(this, Normalizer.Form.NFD)
                                        return REGEX_UNACCENT.replace(temp, "")
                                    }

                                    val bookStatus = whatIsClicked
                                    viewModel.updateBook(
                                        book.id,
                                        bookTitle,
                                        bookAuthor,
                                        bookRating,
                                        bookStatus,
                                        bookFinishDateMs.toString(),
                                        bookNumberOfPagesInt,
                                        bookTitle_ASCII = bookTitle.unaccent().replace("ł", "l", false),
                                        bookAuthor_ASCII = bookAuthor.unaccent().replace("ł", "l", false)
                                    )

                                    it.hideKeyboard()
                                    findNavController().popBackStack()
                                    findNavController().popBackStack()
                                    } else {
                                    Snackbar.make(it, R.string.sbWarningMissingFinishDate, Snackbar.LENGTH_SHORT).show()
                                }
                            } else {
                                Snackbar.make(it, R.string.sbWarningPages0, Snackbar.LENGTH_SHORT)
                                    .show()
                            }
                        } else {
                            Snackbar.make(it, R.string.sbWarningPagesMissing, Snackbar.LENGTH_SHORT)
                                .show()
                        }
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

    fun View.showKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.toggleSoftInputFromWindow(windowToken, 0, 0)
    }

    fun convertLongToTime(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("dd MMM yyyy")
        return format.format(date)
    }

    fun getDateFromDatePickerInMillis(datePicker: DatePicker): Long? {
        val day = datePicker.dayOfMonth
        val month = datePicker.month
        val year = datePicker.year
        val calendar = Calendar.getInstance()
        calendar[year, month] = day
        return calendar.timeInMillis
    }

    fun getAccentColor(context: Context): Int {
        var accentColor = ContextCompat.getColor(context, R.color.green_500)

        val sharedPref = (activity as ListActivity).getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_ACCENT, Constants.THEME_ACCENT_DEFAULT).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor = ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_RED_800 -> accentColor = ContextCompat.getColor(context, R.color.red_800)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor = ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor = ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor = ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor = ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor = ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor = ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor = ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor = ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}