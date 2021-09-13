package software.mdev.bookstracker.ui.bookslist.dialogs

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.inputmethod.InputMethodManager
import software.mdev.bookstracker.R
import android.widget.DatePicker
import android.widget.EditText
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatDialog
import androidx.core.content.ContextCompat
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import software.mdev.bookstracker.data.db.entities.Book
import com.google.android.material.snackbar.Snackbar
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.dialog_add_book.*
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_IN_PROGRESS
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_NOTHING
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_READ
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_TO_READ
import software.mdev.bookstracker.other.Constants.DATABASE_EMPTY_VALUE
import software.mdev.bookstracker.other.Resource
import java.text.Normalizer
import java.text.SimpleDateFormat
import java.util.*


class AddFoundBookDialog(
    var resource: Resource<OpenLibraryOLIDResponse>,
    context: Context,
    var addFoundBookDialogListener: AddFoundBookDialogListener
) : AppCompatDialog(context) {

    var whatIsClicked: String = BOOK_STATUS_NOTHING
    private var bookFinishDateMs: Long? = null
    private var bookStartDateMs: Long? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_add_book)
        var accentColor = getAccentColor(context.applicationContext)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))
        rbAdderRating.visibility = View.GONE
        tvRateThisBook.visibility = View.GONE
        etPagesNumber.visibility = View.GONE

        btnSetFinishDate.visibility  = View.GONE
        btnSetStartDate.visibility  = View.GONE
        btnSetFinishDate.isClickable = false
        btnSetStartDate.isClickable = false

        ivClearStartDate.visibility  = View.GONE
        ivClearFinishDate.visibility  = View.GONE

        tvSetFinishDate.visibility  = View.GONE
        tvSetStartDate.visibility  = View.GONE

        dpBookFinishDate.visibility = View.GONE
        dpBookStartDate.visibility = View.GONE

        btnAdderSaveFinishDate.visibility = View.GONE
        btnAdderCancelFinishDate.visibility = View.GONE
        btnAdderSaveStartDate.visibility = View.GONE
        btnAdderCancelStartDate.visibility = View.GONE

        dpBookFinishDate.maxDate = System.currentTimeMillis()
        dpBookStartDate.maxDate = System.currentTimeMillis()

        etAdderBookTitle.requestFocus()
        showKeyboard(etAdderBookTitle, 350)

        if (resource.data != null) {
            if (resource.data!!.title != null)
                etAdderBookTitle.setText(resource.data!!.title)

            if (resource.data!!.authors != null)
                etAdderAuthor.setText(resource.data!!.authors[0].key)

            if (resource.data!!.number_of_pages != null)
                etPagesNumber.setText(resource.data!!.number_of_pages.toString())

            if (resource.data!!.covers != null) {
                val circularProgressDrawable = CircularProgressDrawable(this.context)
                circularProgressDrawable.strokeWidth = 5f
                circularProgressDrawable.centerRadius = 30f
                circularProgressDrawable.setColorSchemeColors(
                    ContextCompat.getColor(
                        context,
                        R.color.grey
                    )
                )
                circularProgressDrawable.start()

                var coverID = resource.data!!.covers[0]
                var coverUrl = "https://covers.openlibrary.org/b/id/$coverID-M.jpg"

                Picasso
                    .get()
                    .load(coverUrl)
                    .placeholder(circularProgressDrawable)
                    .error(R.drawable.ic_baseline_error_outline_24)
                    .into(ivBookCover)
            } else {
                ivBookCover.visibility = View.GONE
            }
        }



        ivBookStatusSetRead.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetInProgress.setColorFilter(
                ContextCompat.getColor(context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusSetToRead.setColorFilter(
                ContextCompat.getColor(context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            whatIsClicked = BOOK_STATUS_READ
            rbAdderRating.visibility = View.VISIBLE
            tvRateThisBook.visibility = View.VISIBLE
            etPagesNumber.visibility = View.VISIBLE
            btnSetFinishDate.visibility  = View.VISIBLE
            btnSetStartDate.visibility  = View.VISIBLE
            btnSetFinishDate.isClickable = true
            btnSetStartDate.isClickable = true

            tvSetFinishDate.visibility  = View.VISIBLE
            tvSetStartDate.visibility  = View.VISIBLE

            if (bookStartDateMs == null)
                ivClearStartDate.visibility  = View.GONE
            else
                ivClearStartDate.visibility  = View.VISIBLE

            if (bookFinishDateMs == null)
                ivClearFinishDate.visibility  = View.GONE
            else
                ivClearFinishDate.visibility  = View.VISIBLE

            it.hideKeyboard()
        }

        ivBookStatusSetInProgress.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(
                ContextCompat.getColor(context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusSetInProgress.setColorFilter(
                accentColor,
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusSetToRead.setColorFilter(
                ContextCompat.getColor(context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            whatIsClicked = BOOK_STATUS_IN_PROGRESS
            rbAdderRating.visibility = View.GONE
            tvRateThisBook.visibility = View.GONE
            etPagesNumber.visibility = View.GONE
            btnSetFinishDate.visibility  = View.GONE
            btnSetStartDate.visibility  = View.GONE
            btnSetFinishDate.isClickable = false
            btnSetStartDate.isClickable = false

            tvSetFinishDate.visibility  = View.GONE
            tvSetStartDate.visibility  = View.GONE

            etPagesNumber.visibility = View.VISIBLE
            btnSetStartDate.visibility  = View.VISIBLE
            btnSetStartDate.isClickable = true

            tvSetStartDate.visibility  = View.VISIBLE

            if (bookStartDateMs == null)
                ivClearStartDate.visibility  = View.GONE
            else
                ivClearStartDate.visibility  = View.VISIBLE

            ivClearFinishDate.visibility  = View.GONE

            it.hideKeyboard()
        }

        ivBookStatusSetToRead.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(
                ContextCompat.getColor(context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusSetInProgress.setColorFilter(
                ContextCompat.getColor(context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusSetToRead.setColorFilter(
                accentColor,
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            whatIsClicked = BOOK_STATUS_TO_READ
            rbAdderRating.visibility = View.GONE
            tvRateThisBook.visibility = View.GONE
            etPagesNumber.visibility = View.GONE

            btnSetFinishDate.visibility = View.GONE
            btnSetStartDate.visibility = View.GONE

            btnSetFinishDate.isClickable = false
            btnSetStartDate.isClickable = false

            tvSetFinishDate.visibility = View.GONE
            tvSetStartDate.visibility = View.GONE

            ivClearStartDate.visibility  = View.GONE
            ivClearFinishDate.visibility  = View.GONE

            it.hideKeyboard()
        }

        btnSetFinishDate.setOnClickListener {
            it.hideKeyboard()

            dpBookFinishDate.visibility = View.VISIBLE
            btnAdderSaveFinishDate.visibility = View.VISIBLE
            btnAdderCancelFinishDate.visibility = View.VISIBLE
            btnSetFinishDate.isClickable = false
            btnSetStartDate.isClickable = false

            etAdderBookTitle.visibility = View.GONE
            etAdderAuthor.visibility = View.GONE

            ivBookStatusSetRead.visibility = View.GONE
            ivBookStatusSetInProgress.visibility = View.GONE
            ivBookStatusSetToRead.visibility = View.GONE
            tvFinished.visibility = View.GONE
            tvInProgress.visibility = View.GONE
            tvToRead.visibility = View.GONE

            ivBookCover.visibility = View.GONE
            etPagesNumber.visibility = View.GONE
            tvRateThisBook.visibility = View.GONE
            rbAdderRating.visibility = View.GONE
            btnAdderSaveBook.visibility = View.GONE
            btnSetFinishDate.visibility = View.GONE
            btnSetStartDate.visibility = View.GONE

            tvSetFinishDate.visibility = View.GONE
            tvSetStartDate.visibility = View.GONE

            ivClearStartDate.visibility = View.GONE
            ivClearFinishDate.visibility = View.GONE
        }

        btnSetStartDate.setOnClickListener {
            it.hideKeyboard()

            dpBookStartDate.visibility = View.VISIBLE
            btnAdderSaveStartDate.visibility = View.VISIBLE
            btnAdderCancelStartDate.visibility = View.VISIBLE
            btnSetFinishDate.isClickable = false
            btnSetStartDate.isClickable = false

            etAdderBookTitle.visibility = View.GONE
            etAdderAuthor.visibility = View.GONE

            ivBookStatusSetRead.visibility = View.GONE
            ivBookStatusSetInProgress.visibility = View.GONE
            ivBookStatusSetToRead.visibility = View.GONE
            tvFinished.visibility = View.GONE
            tvInProgress.visibility = View.GONE
            tvToRead.visibility = View.GONE

            etPagesNumber.visibility = View.GONE
            tvRateThisBook.visibility = View.GONE
            rbAdderRating.visibility = View.GONE
            btnAdderSaveBook.visibility = View.GONE
            btnSetFinishDate.visibility = View.GONE
            btnSetStartDate.visibility = View.GONE

            tvSetFinishDate.visibility = View.GONE
            tvSetStartDate.visibility = View.GONE

            ivBookCover.visibility = View.GONE

            ivClearStartDate.visibility = View.GONE
            ivClearFinishDate.visibility = View.GONE
        }

        btnAdderSaveFinishDate.setOnClickListener {
            bookFinishDateMs = getDateFromDatePickerInMillis(dpBookFinishDate)

            dpBookFinishDate.visibility = View.GONE
            btnAdderSaveFinishDate.visibility = View.GONE
            btnAdderCancelFinishDate.visibility = View.GONE

            etAdderBookTitle.visibility = View.VISIBLE
            etAdderAuthor.visibility = View.VISIBLE

            ivBookStatusSetRead.visibility = View.VISIBLE
            ivBookStatusSetInProgress.visibility = View.VISIBLE
            ivBookStatusSetToRead.visibility = View.VISIBLE
            tvFinished.visibility = View.VISIBLE
            tvInProgress.visibility = View.VISIBLE
            tvToRead.visibility = View.VISIBLE

            if (resource.data!!.covers != null)
                ivBookCover.visibility = View.VISIBLE
            etPagesNumber.visibility = View.VISIBLE
            tvRateThisBook.visibility = View.VISIBLE
            rbAdderRating.visibility = View.VISIBLE
            btnAdderSaveBook.visibility = View.VISIBLE
            btnSetFinishDate.visibility = View.VISIBLE
            btnSetStartDate.visibility = View.VISIBLE

            btnSetFinishDate.isClickable = true
            btnSetStartDate.isClickable = true

            tvSetFinishDate.visibility = View.VISIBLE
            tvSetStartDate.visibility = View.VISIBLE

            btnSetFinishDate.text = bookFinishDateMs?.let { it1 -> convertLongToTime(it1) }

            if (bookStartDateMs!= null)
                ivClearStartDate.visibility = View.VISIBLE
            if (bookFinishDateMs!= null)
                ivClearFinishDate.visibility = View.VISIBLE
        }

        btnAdderCancelFinishDate.setOnClickListener {
            dpBookFinishDate.visibility = View.GONE
            btnAdderSaveFinishDate.visibility = View.GONE
            btnAdderCancelFinishDate.visibility = View.GONE

            etAdderBookTitle.visibility = View.VISIBLE
            etAdderAuthor.visibility = View.VISIBLE

            ivBookStatusSetRead.visibility = View.VISIBLE
            ivBookStatusSetInProgress.visibility = View.VISIBLE
            ivBookStatusSetToRead.visibility = View.VISIBLE
            tvFinished.visibility = View.VISIBLE
            tvInProgress.visibility = View.VISIBLE
            tvToRead.visibility = View.VISIBLE

            if (resource.data!!.covers != null)
                ivBookCover.visibility = View.VISIBLE
            etPagesNumber.visibility = View.VISIBLE
            tvRateThisBook.visibility = View.VISIBLE
            rbAdderRating.visibility = View.VISIBLE
            btnAdderSaveBook.visibility = View.VISIBLE
            btnSetFinishDate.visibility = View.VISIBLE
            btnSetStartDate.visibility = View.VISIBLE

            btnSetFinishDate.isClickable = true
            btnSetStartDate.isClickable = true

            tvSetFinishDate.visibility = View.VISIBLE
            tvSetStartDate.visibility = View.VISIBLE

            if (bookStartDateMs!= null)
                ivClearStartDate.visibility = View.VISIBLE
            if (bookFinishDateMs!= null)
                ivClearFinishDate.visibility = View.VISIBLE
        }
        btnAdderSaveStartDate.setOnClickListener {
            bookStartDateMs = getDateFromDatePickerInMillis(dpBookStartDate)

            dpBookStartDate.visibility = View.GONE
            btnAdderSaveStartDate.visibility = View.GONE
            btnAdderCancelStartDate.visibility = View.GONE

            etAdderBookTitle.visibility = View.VISIBLE
            etAdderAuthor.visibility = View.VISIBLE

            ivBookStatusSetRead.visibility = View.VISIBLE
            ivBookStatusSetInProgress.visibility = View.VISIBLE
            ivBookStatusSetToRead.visibility = View.VISIBLE
            tvFinished.visibility = View.VISIBLE
            tvInProgress.visibility = View.VISIBLE
            tvToRead.visibility = View.VISIBLE

            etPagesNumber.visibility = View.VISIBLE
            tvRateThisBook.visibility = View.VISIBLE
            rbAdderRating.visibility = View.VISIBLE
            btnAdderSaveBook.visibility = View.VISIBLE
            btnSetStartDate.visibility = View.VISIBLE

            btnSetStartDate.isClickable = true

            if (resource.data!!.covers != null)
                ivBookCover.visibility = View.VISIBLE

            tvSetFinishDate.visibility = View.VISIBLE
            tvSetStartDate.visibility = View.VISIBLE

            btnSetStartDate.text = bookStartDateMs?.let { it1 -> convertLongToTime(it1) }

            ivClearStartDate.visibility  = View.VISIBLE

            if (whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS) {
                btnSetFinishDate.visibility = View.GONE
                btnSetFinishDate.isClickable = false
                tvSetFinishDate.visibility = View.GONE
                ivClearFinishDate.visibility = View.GONE
            } else {
                btnSetFinishDate.visibility = View.VISIBLE
                btnSetFinishDate.isClickable = true
                tvSetFinishDate.visibility = View.VISIBLE
                if (bookFinishDateMs != null)
                    ivClearFinishDate.visibility = View.VISIBLE
            }

            if (bookStartDateMs!= null)
                ivClearStartDate.visibility = View.VISIBLE
        }

        btnAdderCancelStartDate.setOnClickListener {
            dpBookStartDate.visibility = View.GONE
            btnAdderSaveStartDate.visibility = View.GONE
            btnAdderCancelStartDate.visibility = View.GONE

            etAdderBookTitle.visibility = View.VISIBLE
            etAdderAuthor.visibility = View.VISIBLE

            ivBookStatusSetRead.visibility = View.VISIBLE
            ivBookStatusSetInProgress.visibility = View.VISIBLE
            ivBookStatusSetToRead.visibility = View.VISIBLE
            tvFinished.visibility = View.VISIBLE
            tvInProgress.visibility = View.VISIBLE
            tvToRead.visibility = View.VISIBLE

            etPagesNumber.visibility = View.VISIBLE
            tvRateThisBook.visibility = View.VISIBLE
            rbAdderRating.visibility = View.VISIBLE
            btnAdderSaveBook.visibility = View.VISIBLE
            btnSetStartDate.visibility = View.VISIBLE

            btnSetStartDate.isClickable = true

            if (resource.data!!.covers != null)
                ivBookCover.visibility = View.VISIBLE

            tvSetFinishDate.visibility = View.VISIBLE
            tvSetStartDate.visibility = View.VISIBLE

            if (whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS) {
                btnSetFinishDate.visibility = View.GONE
                btnSetFinishDate.isClickable = false
                tvSetFinishDate.visibility = View.GONE
                ivClearFinishDate.visibility = View.GONE
            } else {
                btnSetFinishDate.visibility = View.VISIBLE
                btnSetFinishDate.isClickable = true
                tvSetFinishDate.visibility = View.VISIBLE
                if (bookFinishDateMs != null)
                    ivClearFinishDate.visibility = View.VISIBLE
            }

            if (bookStartDateMs!= null)
                ivClearStartDate.visibility = View.VISIBLE
        }

        ivClearStartDate.setOnClickListener {
            ivClearStartDate.visibility = View.GONE

            btnSetStartDate.text =  context.getString(R.string.set)

            bookStartDateMs = null
        }

        ivClearFinishDate.setOnClickListener {
            ivClearFinishDate.visibility = View.GONE

            btnSetFinishDate.text =  context.getString(R.string.set)

            bookFinishDateMs = null
        }

        btnAdderSaveBook.setOnClickListener {
            val bookTitle = etAdderBookTitle.text.toString()
            val bookAuthor = etAdderAuthor.text.toString()
            val bookNumberOfPagesIntOrNull = etPagesNumber.text.toString().toIntOrNull()
            var bookNumberOfPagesInt: Int

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()) {
                    if (whatIsClicked != BOOK_STATUS_NOTHING) {
                            bookNumberOfPagesInt = when (bookNumberOfPagesIntOrNull) {
                                null -> 0
                                else -> bookNumberOfPagesIntOrNull
                            }

                        if ((bookFinishDateMs != null && bookStartDateMs != null && bookStartDateMs!! < bookFinishDateMs!!)
                            || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS
                            || whatIsClicked == Constants.BOOK_STATUS_TO_READ
                            || (bookFinishDateMs == null && bookStartDateMs == null)
                            || bookFinishDateMs == null
                            || bookStartDateMs == null ) {

                            if (bookFinishDateMs == null) {
                                val noChallengeWarningDialog = AlertDialog.Builder(context)
                                    .setTitle(R.string.warning_no_finish_date_title)
                                    .setMessage(R.string.warning_no_finish_date_message)
                                    .setIcon(R.drawable.ic_baseline_warning_amber_24)
                                    .setPositiveButton(R.string.warning_no_finish_date_add_anyway) { _, _ ->
                                        var editedBook = prepareBook(
                                            whatIsClicked,
                                            bookRating = rbAdderRating.rating,
                                            bookNumberOfPagesInt = bookNumberOfPagesInt,
                                            bookStartDateMs = bookStartDateMs,
                                            bookFinishDateMs = bookFinishDateMs,
                                            bookTitle = bookTitle,
                                            bookAuthor = bookAuthor,
                                            covers = resource.data!!.covers,
                                            key = resource.data!!.key,
                                            isbn10 = resource.data!!.isbn_10,
                                            isbn13 = resource.data!!.isbn_13
                                        )

                                        addFoundBookDialogListener.onSaveButtonClicked(editedBook)
                                        dismiss()
                                    }
                                    .setNegativeButton(R.string.warning_no_finish_date_cancel) { _, _ ->
                                    }
                                    .create()

                                noChallengeWarningDialog.show()
                            } else {
                                var editedBook = prepareBook(
                                    whatIsClicked,
                                    bookRating = rbAdderRating.rating,
                                    bookNumberOfPagesInt = bookNumberOfPagesInt,
                                    bookStartDateMs = bookStartDateMs,
                                    bookFinishDateMs = bookFinishDateMs,
                                    bookTitle = bookTitle,
                                    bookAuthor = bookAuthor,
                                    covers = resource.data!!.covers,
                                    resource.data!!.key,
                                    resource.data!!.isbn_10,
                                    resource.data!!.isbn_13
                                )

                                addFoundBookDialogListener.onSaveButtonClicked(editedBook)
                                dismiss()
                            }
                        } else {
                            Snackbar.make(it, R.string.sbWarningStartDateMustBeBeforeFinishDate, Snackbar.LENGTH_SHORT).show()
                        }
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

    private fun prepareBook(
        whatIsClicked: String,
        bookRating: Float,
        bookNumberOfPagesInt: Int,
        bookStartDateMs: Long?,
        bookFinishDateMs: Long?,
        bookTitle: String,
        bookAuthor: String,
        covers: List<Int>,
        key: String,
        isbn10: List<String>,
        isbn13: List<String>
    ): Book {
        var newBookRating = 0.0F
        var newBookNumberOfPagesInt = bookNumberOfPagesInt
        var newBookStartDateMs: Long? = bookStartDateMs
        var newBookFinishDateMs: Long? = bookFinishDateMs

        when (whatIsClicked) {
            BOOK_STATUS_READ -> {
                newBookRating = bookRating
            }
            BOOK_STATUS_IN_PROGRESS -> {
                newBookRating = 0.0F
                newBookFinishDateMs = null
            }
            BOOK_STATUS_TO_READ -> {
                newBookRating = 0.0F
                newBookNumberOfPagesInt = 0
                newBookStartDateMs = null
                newBookFinishDateMs = null
            }
        }

        val REGEX_UNACCENT =
            "\\p{InCombiningDiacriticalMarks}+".toRegex()

        fun CharSequence.unaccent(): String {
            val temp =
                Normalizer.normalize(
                    this,
                    Normalizer.Form.NFD
                )
            return REGEX_UNACCENT.replace(temp, "")
        }



        var coverID = Constants.DATABASE_EMPTY_VALUE
        if (covers != null)
            coverID = covers[0].toString()

        var olid = key

        var newIsbn10 = Constants.DATABASE_EMPTY_VALUE
        var newIsbn13 = Constants.DATABASE_EMPTY_VALUE

        if (isbn10 != null) {
            newIsbn10 = isbn10[0]
        }

        if (isbn13 != null) {
            newIsbn13 = isbn13[0]
        }



        return Book(
            bookTitle,
            bookAuthor,
            newBookRating,
            bookStatus = whatIsClicked,
            bookPriority = DATABASE_EMPTY_VALUE,
            bookStartDate = newBookStartDateMs.toString(),
            bookFinishDate = newBookFinishDateMs.toString(),
            bookNumberOfPages = newBookNumberOfPagesInt,
            bookTitle_ASCII = bookTitle.unaccent()
                .replace("ł", "l", false),
            bookAuthor_ASCII = bookAuthor.unaccent()
                .replace("ł", "l", false),
            false,
            coverID.toString(),
            olid.replace("/books/", ""),
            newIsbn10,
            newIsbn13
        )
    }

    fun View.hideKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun showKeyboard(et: EditText, delay: Long) {
        val timer = Timer()
        timer.schedule(object : TimerTask() {
            override fun run() {
                val inputManager =
                    context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                inputManager.showSoftInput(et, 0)
            }
        }, delay)
    }

    fun getDateFromDatePickerInMillis(datePicker: DatePicker): Long? {
        val day = datePicker.dayOfMonth
        val month = datePicker.month
        val year = datePicker.year
        val calendar = Calendar.getInstance()
        calendar[year, month] = day
        return calendar.timeInMillis
    }

    fun convertLongToTime(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("dd MMM yyyy")
        return format.format(date)
    }

    fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref =
            context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when (accent) {
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor =
                ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.orange_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor =
                ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor =
                ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor =
                ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor =
                ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor =
                ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}
