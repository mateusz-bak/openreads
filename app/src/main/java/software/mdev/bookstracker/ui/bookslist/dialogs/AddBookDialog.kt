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
import androidx.appcompat.app.AppCompatDialog
import androidx.core.content.ContextCompat
import software.mdev.bookstracker.data.db.entities.Book
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.dialog_add_book.*
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_IN_PROGRESS
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_NOTHING
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_READ
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_TO_READ
import software.mdev.bookstracker.other.Constants.DATABASE_EMPTY_VALUE
import java.text.Normalizer
import java.text.SimpleDateFormat
import java.util.*


class AddBookDialog(context: Context, var addBookDialogListener: AddBookDialogListener) : AppCompatDialog(context) {

    var whatIsClicked: String = BOOK_STATUS_NOTHING
    private var bookFinishDateMs: Long? = null

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
        btnSetFinishDate.isClickable = false
        dpBookFinishDate.visibility = View.GONE
        btnAdderSaveFinishDate.visibility = View.GONE

        etAdderBookTitle.requestFocus()
        showKeyboard(etAdderBookTitle,350)

        ivBookStatusSetRead.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetInProgress.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetToRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = BOOK_STATUS_READ
            rbAdderRating.visibility = View.VISIBLE
            tvRateThisBook.visibility = View.VISIBLE
            etPagesNumber.visibility = View.VISIBLE
            btnSetFinishDate.visibility  = View.VISIBLE
            btnSetFinishDate.isClickable = true
            etPagesNumber.requestFocus()
            showKeyboard(etPagesNumber,350)
        }

        ivBookStatusSetInProgress.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetInProgress.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetToRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = BOOK_STATUS_IN_PROGRESS
            rbAdderRating.visibility = View.GONE
            tvRateThisBook.visibility = View.GONE
            etPagesNumber.visibility = View.GONE
            btnSetFinishDate.visibility  = View.GONE
            btnSetFinishDate.isClickable = false
            it.hideKeyboard()
        }

        ivBookStatusSetToRead.setOnClickListener {
            ivBookStatusSetRead.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetInProgress.setColorFilter(ContextCompat.getColor(context, R.color.grey), android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusSetToRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = BOOK_STATUS_TO_READ
            rbAdderRating.visibility = View.GONE
            tvRateThisBook.visibility = View.GONE
            etPagesNumber.visibility = View.GONE
            btnSetFinishDate.visibility  = View.GONE
            btnSetFinishDate.isClickable = false
            it.hideKeyboard()
        }

        btnSetFinishDate.setOnClickListener {
            it.hideKeyboard()

            dpBookFinishDate.visibility = View.VISIBLE
            btnAdderSaveFinishDate.visibility = View.VISIBLE
            btnSetFinishDate.isClickable = true
            tvAdderTitle.setText(R.string.set_finish_date_title)

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

        }

        btnAdderSaveFinishDate.setOnClickListener {
            bookFinishDateMs = getDateFromDatePickerInMillis(dpBookFinishDate)

            dpBookFinishDate.visibility = View.GONE
            btnAdderSaveFinishDate.visibility = View.GONE
            tvAdderTitle.setText(R.string.tvAdderTitle)

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
            btnSetFinishDate.visibility = View.VISIBLE

            btnSetFinishDate.text = bookFinishDateMs?.let { it1 -> convertLongToTime(it1) }
        }

        btnAdderSaveBook.setOnClickListener {
            val bookTitle = etAdderBookTitle.text.toString()
            val bookAuthor = etAdderAuthor.text.toString()
            var bookRating = 0.0F
            val bookNumberOfPagesIntOrNull = etPagesNumber.text.toString().toIntOrNull()
            var bookNumberOfPagesInt : Int

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    if (whatIsClicked != BOOK_STATUS_NOTHING) {
                        if (bookNumberOfPagesIntOrNull!=null || whatIsClicked == BOOK_STATUS_IN_PROGRESS || whatIsClicked == BOOK_STATUS_TO_READ) {
                            bookNumberOfPagesInt = when (bookNumberOfPagesIntOrNull) {
                            null -> 0
                            else -> bookNumberOfPagesIntOrNull
                            }
                                if (bookNumberOfPagesInt > 0 || whatIsClicked == BOOK_STATUS_IN_PROGRESS || whatIsClicked == BOOK_STATUS_TO_READ) {
                                    if (bookFinishDateMs!=null || whatIsClicked == BOOK_STATUS_IN_PROGRESS || whatIsClicked == BOOK_STATUS_TO_READ) {
                                        when (whatIsClicked) {
                                            BOOK_STATUS_READ -> bookRating = rbAdderRating.rating
                                            BOOK_STATUS_IN_PROGRESS -> bookRating = 0.0F
                                            BOOK_STATUS_TO_READ -> {
                                                bookRating = 0.0F
                                                bookNumberOfPagesInt = 0
                                            }
                                        }

                                        val REGEX_UNACCENT = "\\p{InCombiningDiacriticalMarks}+".toRegex()
                                        fun CharSequence.unaccent(): String {
                                            val temp = Normalizer.normalize(this, Normalizer.Form.NFD)
                                            return REGEX_UNACCENT.replace(temp, "")
                                        }

                                        val editedBook = Book(
                                            bookTitle,
                                            bookAuthor,
                                            bookRating,
                                            bookStatus = whatIsClicked,
                                            bookPriority = DATABASE_EMPTY_VALUE,
                                            bookStartDate = DATABASE_EMPTY_VALUE,
                                            bookFinishDate = bookFinishDateMs.toString(),
                                            bookNumberOfPages = bookNumberOfPagesInt,
                                            bookTitle_ASCII = bookTitle.unaccent().replace("ł", "l", false),
                                            bookAuthor_ASCII = bookAuthor.unaccent().replace("ł", "l", false)
                                        )
                                        addBookDialogListener.onSaveButtonClicked(editedBook)
                                        dismiss()
                                } else {
                                    Snackbar.make(it, R.string.sbWarningMissingFinishDate, Snackbar.LENGTH_SHORT).show()
                                }

                            } else {
                                Snackbar.make(it, R.string.sbWarningPagesMissing, Snackbar.LENGTH_SHORT).show()
                            }
                        } else {
                            Snackbar.make(it, R.string.sbWarningPagesMissing, Snackbar.LENGTH_SHORT).show()
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

    fun View.hideKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun showKeyboard(et: EditText, delay: Long) {
        val timer = Timer()
        timer.schedule(object : TimerTask() {
            override fun run() {
                val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
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

        val sharedPref = context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_AMBER_500 -> accentColor = ContextCompat.getColor(context, R.color.amber_500)
            Constants.THEME_ACCENT_BLUE_500 -> accentColor = ContextCompat.getColor(context, R.color.blue_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor = ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor = ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_INDIGO_500 -> accentColor = ContextCompat.getColor(context, R.color.indigo_500)
            Constants.THEME_ACCENT_LIME_500 -> accentColor = ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_500 -> accentColor = ContextCompat.getColor(context, R.color.pink_500)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor = ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor = ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor = ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}
