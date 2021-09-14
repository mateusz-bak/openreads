package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.MotionEvent
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.swiperefreshlayout.widget.CircularProgressDrawable
import com.google.android.material.snackbar.Snackbar
import com.squareup.picasso.Picasso
import kotlinx.android.synthetic.main.fragment_display_book.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_IN_PROGRESS
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_READ
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_TO_READ
import software.mdev.bookstracker.other.Constants.SERIALIZABLE_BUNDLE_BOOK
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import java.text.SimpleDateFormat
import java.util.*
import android.graphics.*
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.app.AlertDialog
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import com.squareup.picasso.Transformation
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch


class DisplayBookFragment : Fragment(R.layout.fragment_display_book) {

    lateinit var viewModel: BooksViewModel
    private val args: DisplayBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val book = args.book

        tvBookTitle.text = book.bookTitle
        tvBookAuthor.text = book.bookAuthor
        rbRatingIndicator.rating = book.bookRating
        tvBookPages.text = book.bookNumberOfPages.toString()

        tvDateFinished.visibility = View.GONE
        tvDateFinishedTitle.visibility = View.GONE

        tvDateStarted.visibility = View.GONE
        tvDateStartedTitle.visibility = View.GONE

        tvBookPages.visibility = View.GONE
        tvBookPagesTitle.visibility = View.GONE

        tvBookISBN.visibility = View.GONE
        tvBookISBNTitle.visibility = View.GONE

        tvBookURL.visibility = View.GONE

        if (book.bookCoverUrl == Constants.DATABASE_EMPTY_VALUE) {
            ivBookCover.visibility = View.GONE
        } else {
            val circularProgressDrawable = CircularProgressDrawable(view.context)
            circularProgressDrawable.strokeWidth = 5f
            circularProgressDrawable.centerRadius = 30f
            circularProgressDrawable.setColorSchemeColors(
                ContextCompat.getColor(
                    view.context,
                    R.color.grey
                )
            )
            circularProgressDrawable.start()

            var coverID = book.bookCoverUrl
            var coverUrl = "https://covers.openlibrary.org/b/id/$coverID-L.jpg"

            Picasso
                .get()
                .load(coverUrl)
                .placeholder(circularProgressDrawable)
                .error(R.drawable.ic_baseline_error_outline_24)
                .transform(RoundCornersTransform(16.0f))
                .into(ivBookCover)
        }

        if (book.bookISBN13 != Constants.DATABASE_EMPTY_VALUE) {
            tvBookISBN.text = book.bookISBN13
        } else if (book.bookISBN10 != Constants.DATABASE_EMPTY_VALUE) {
            tvBookISBN.text = book.bookISBN10
        } else {
            tvBookISBN.text = getString(R.string.not_set)
        }

        if (book.bookOLID != Constants.DATABASE_EMPTY_VALUE) {
            var olid: String = book.bookOLID
            var url: String = "https://openlibrary.org/books/$olid"
            tvBookURL.text = url
        }

        if(book.bookFinishDate == "none" || book.bookFinishDate == "null") {
            tvDateFinished.text = getString(R.string.not_set)
        } else {
            var bookFinishTimeStampLong = book.bookFinishDate.toLong()
            tvDateFinished.text = convertLongToTime(bookFinishTimeStampLong)
        }

        if(book.bookStartDate == "none" || book.bookStartDate == "null") {
            tvDateStarted.text = getString(R.string.not_set)
        } else {
            var bookStartTimeStampLong = book.bookStartDate.toLong()
            tvDateStarted.text = convertLongToTime(bookStartTimeStampLong)
        }

        when (book.bookStatus) {
            BOOK_STATUS_READ -> {
                tvBookStatus.text = getString(R.string.finished)
                ivBookStatusInProgress.visibility = View.GONE
                ivBookStatusToRead.visibility = View.GONE
                rbRatingIndicator.visibility = View.VISIBLE
            }
            BOOK_STATUS_IN_PROGRESS -> {
                tvBookStatus.text = getString(R.string.inProgress)
                ivBookStatusRead.visibility = View.GONE
                ivBookStatusToRead.visibility = View.GONE
                rbRatingIndicator.visibility = View.GONE
                tvBookPagesTitle.visibility = View.GONE
                tvBookPages.visibility = View.GONE
                tvDateFinishedTitle.visibility = View.GONE
                tvDateFinished.visibility = View.GONE
            }
            BOOK_STATUS_TO_READ -> {
                tvBookStatus.text = getString(R.string.toRead)
                ivBookStatusInProgress.visibility = View.GONE
                ivBookStatusRead.visibility = View.GONE
                rbRatingIndicator.visibility = View.GONE
                tvBookPagesTitle.visibility = View.GONE
                tvBookPages.visibility = View.GONE
                tvDateFinishedTitle.visibility = View.GONE
                tvDateFinished.visibility = View.GONE
            }
        }

        ivBookCover.setOnClickListener {
            val bundle = Bundle().apply {
                putSerializable("cover", book.bookCoverUrl)
            }
            findNavController().navigate(
                R.id.action_displayBookFragment_to_displayCoverFragment,
                bundle
            )
        }

        fabEditBook.setOnClickListener {
            val bundle = Bundle().apply {
                putSerializable(SERIALIZABLE_BUNDLE_BOOK, book)
            }
            findNavController().navigate(
                R.id.action_displayBookFragment_to_editBookFragment,
                bundle
            )
        }

        tvMoreAboutBook.setOnClickListener {
            when(tvBookPagesTitle.visibility){
                View.GONE -> {
                    tvBookPagesTitle.visibility = View.VISIBLE
                    tvBookPages.visibility = View.VISIBLE
                    tvBookISBNTitle.visibility = View.VISIBLE
                    tvBookISBN.visibility = View.VISIBLE
                    if (book.bookOLID != Constants.DATABASE_EMPTY_VALUE)
                        tvBookURL.visibility = View.VISIBLE
                    if (book.bookStatus == Constants.BOOK_STATUS_READ) {

                        tvDateFinishedTitle.visibility = View.VISIBLE
                        tvDateFinished.visibility = View.VISIBLE

                        val tvDateStartedTitleLayut = tvDateStartedTitle.layoutParams as ConstraintLayout.LayoutParams // btn is a View here
                        tvDateStartedTitleLayut.startToStart = R.id.guideline4 // resource ID of new parent field
                        tvDateStartedTitleLayut.endToEnd = R.id.guideline4 // resource ID of new parent field
                        tvDateStartedTitle.layoutParams = tvDateStartedTitleLayut
                        tvDateStartedTitle.visibility = View.VISIBLE

                        val tvDateStartedLayut = tvDateStarted.layoutParams as ConstraintLayout.LayoutParams // btn is a View here
                        tvDateStartedLayut.startToStart = R.id.guideline4 // resource ID of new parent field
                        tvDateStartedLayut.endToEnd = R.id.guideline4 // resource ID of new parent field
                        tvDateStarted.layoutParams = tvDateStartedLayut
                        tvDateStarted.visibility = View.VISIBLE
                    } else if (book.bookStatus == Constants.BOOK_STATUS_IN_PROGRESS){

                        val tvDateStartedTitleLayut = tvDateStartedTitle.layoutParams as ConstraintLayout.LayoutParams // btn is a View here
                        tvDateStartedTitleLayut.startToStart = R.id.guideline3 // resource ID of new parent field
                        tvDateStartedTitleLayut.endToEnd = R.id.guideline3 // resource ID of new parent field
                        tvDateStartedTitle.layoutParams = tvDateStartedTitleLayut
                        tvDateStartedTitle.visibility = View.VISIBLE

                        val tvDateStartedLayut = tvDateStarted.layoutParams as ConstraintLayout.LayoutParams // btn is a View here
                        tvDateStartedLayut.startToStart = R.id.guideline3 // resource ID of new parent field
                        tvDateStartedLayut.endToEnd = R.id.guideline3 // resource ID of new parent field
                        tvDateStarted.layoutParams = tvDateStartedLayut
                        tvDateStarted.visibility = View.VISIBLE
                    }
                }
                View.VISIBLE -> {
                    tvBookPagesTitle.visibility = View.GONE
                    tvBookPages.visibility = View.GONE
                    tvDateFinishedTitle.visibility = View.GONE
                    tvDateFinished.visibility = View.GONE
                    tvBookISBNTitle.visibility = View.GONE
                    tvBookISBN.visibility = View.GONE
                    tvDateStartedTitle.visibility = View.GONE
                    tvDateStarted.visibility = View.GONE
                    tvBookURL.visibility = View.GONE
                }
            }
        }

        tvBookTitle.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_title, Snackbar.LENGTH_SHORT).show()
        }

        tvBookAuthor.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_author, Snackbar.LENGTH_SHORT).show()
        }

        rbRatingIndicator.setOnTouchListener(View.OnTouchListener { v, event ->
                if (event.action == MotionEvent.ACTION_UP) {
                    Snackbar.make(view, R.string.click_edit_button_to_edit_rating, Snackbar.LENGTH_SHORT).show()
                }
                return@OnTouchListener true
            })

        tvBookStatus.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_status, Snackbar.LENGTH_SHORT).show()
        }

        ivBookStatusRead.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_status, Snackbar.LENGTH_SHORT).show()
        }

        ivBookStatusInProgress.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_status, Snackbar.LENGTH_SHORT).show()
        }

        ivBookStatusToRead.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_status, Snackbar.LENGTH_SHORT).show()
        }

        tvDateFinishedTitle.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_date, Snackbar.LENGTH_SHORT).show()
        }

        tvDateFinished.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_date, Snackbar.LENGTH_SHORT).show()
        }

        tvBookPagesTitle.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_pages, Snackbar.LENGTH_SHORT).show()
        }

        tvBookPages.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_pages, Snackbar.LENGTH_SHORT).show()
        }

        class UndoBookDeletion : View.OnClickListener {
            override fun onClick(view: View) {
                viewModel.updateBook(
                    book.id,
                    book.bookTitle,
                    book.bookAuthor,
                    book.bookRating,
                    book.bookStatus,
                    book.bookPriority,
                    book.bookStartDate,
                    book.bookFinishDate,
                    book.bookNumberOfPages,
                    book.bookTitle_ASCII,
                    book.bookAuthor_ASCII,
                    false,
                    book.bookCoverUrl,
                    book.bookOLID,
                    book.bookISBN10,
                    book.bookISBN13
                )
            }
        }

        fabDeleteBook.setOnClickListener{
            val deleteBookWarningDialog = this.context?.let { it1 ->
                AlertDialog.Builder(it1)
                    .setTitle(R.string.warning_delete_book_title)
                    .setMessage(R.string.warning_delete_book_message)
                    .setIcon(R.drawable.ic_baseline_warning_amber_24)
                    .setNegativeButton(R.string.warning_delete_book_delete) { _, _ ->
                        viewModel.updateBook(
                            book.id,
                            book.bookTitle,
                            book.bookAuthor,
                            book.bookRating,
                            book.bookStatus,
                            book.bookPriority,
                            book.bookStartDate,
                            book.bookFinishDate,
                            book.bookNumberOfPages,
                            book.bookTitle_ASCII,
                            book.bookAuthor_ASCII,
                            true,
                            book.bookCoverUrl,
                            book.bookOLID,
                            book.bookISBN10,
                            book.bookISBN13
                        )
                        recalculateChallenges(book.bookStatus)

                        Snackbar.make(it, getString(R.string.bookDeleted), Snackbar.LENGTH_LONG)
                            .setAction(getString(R.string.undo), UndoBookDeletion())
                            .show()
                    }
                    .setPositiveButton(R.string.warning_delete_book_cancel) { _, _ ->
                    }
                    .create()
            }

            deleteBookWarningDialog?.show()
            if (this.context !=null && deleteBookWarningDialog?.getButton(AlertDialog.BUTTON_POSITIVE) != null) {
                deleteBookWarningDialog?.getButton(AlertDialog.BUTTON_POSITIVE)!!.setBackgroundColor(getAccentColor(this.requireContext()))
                deleteBookWarningDialog?.getButton(AlertDialog.BUTTON_POSITIVE)!!.setTextColor(ContextCompat.getColor(this.requireContext(),R.color.design_default_color_on_primary))
            }
        }
    }

    private fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref = context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor = ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor = ContextCompat.getColor(context, R.color.orange_500)
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

    fun View.hideKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun convertLongToTime(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("dd MMM yyyy")
        return format.format(date)
    }

    private fun recalculateChallenges(bookStatus: String) {
        viewModel.getSortedBooksByFinishDateDesc(Constants.BOOK_STATUS_READ)
            .observe(viewLifecycleOwner, Observer { books ->
                var year: Int
                var years = listOf<Int>()

                for (item in books) {
                    if (item.bookFinishDate != "null" && item.bookFinishDate != "none") {
                        year = convertLongToYear(item.bookFinishDate.toLong()).toInt()
                        if (year !in years) {
                            years = years + year
                        }
                    }
                }

                for (item_year in years) {
                    var booksInYear = 0

                    for (item_book in books) {
                        if (item_book.bookFinishDate != "none" && item_book.bookFinishDate != "null") {
                            year = convertLongToYear(item_book.bookFinishDate.toLong()).toInt()
                            if (year == item_year) {
                                booksInYear++
                            }
                        }
                    }
                    viewModel.updateYearsNumberOfBooks(item_year.toString(), booksInYear)
                }
            }
            )
        lifecycleScope.launch {
            delay(300L)
            view?.hideKeyboard()

            when (bookStatus) {
                Constants.BOOK_STATUS_READ -> findNavController().navigate(R.id.action_displayBookFragment_to_readFragment)
                Constants.BOOK_STATUS_IN_PROGRESS -> findNavController().navigate(R.id.action_displayBookFragment_to_inProgressFragment)
                Constants.BOOK_STATUS_TO_READ -> findNavController().navigate(R.id.action_displayBookFragment_to_toReadFragment)
            }
        }
    }

    fun convertLongToYear(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("yyyy")
        return format.format(date)
    }
}

class RoundCornersTransform(private val radiusInPx: Float) : Transformation {

    override fun transform(source: Bitmap): Bitmap {
        val bitmap = Bitmap.createBitmap(source.width, source.height, source.config)
        val canvas = Canvas(bitmap)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG or Paint.DITHER_FLAG)
        val shader = BitmapShader(source, Shader.TileMode.CLAMP, Shader.TileMode.CLAMP)
        paint.shader = shader
        val rect = RectF(0.0f, 0.0f, source.width.toFloat(), source.height.toFloat())
        canvas.drawRoundRect(rect, radiusInPx, radiusInPx, paint)
        source.recycle()

        return bitmap
    }

    override fun key(): String {
        return "round_corners"
    }

}