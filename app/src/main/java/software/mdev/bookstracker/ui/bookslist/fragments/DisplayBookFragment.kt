package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
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
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import java.text.SimpleDateFormat
import java.util.*
import android.graphics.*
import android.view.animation.AccelerateInterpolator
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.app.AlertDialog
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import com.squareup.picasso.Transformation
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import android.widget.Toast
import android.widget.RatingBar.OnRatingBarChangeListener
import kotlinx.coroutines.MainScope
import androidx.activity.OnBackPressedCallback


class DisplayBookFragment : Fragment(R.layout.fragment_display_book) {

    lateinit var viewModel: BooksViewModel
    private val args: DisplayBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        book = args.book

        initialViewsSetup()
        setCover(view)
        setISBN()
        setOLID()
        setFinishDate()
        setStartDate()

        ivBookCover.setOnClickListener {
            animateCover()

            if (ivDetails2.visibility == View.VISIBLE)
                hideDetails()
            else
                showDetails()
        }

        ivEdit.setOnClickListener {
            editBook()
        }

        ivDetails.setOnClickListener {
            showDetails()
        }

        ivDetails2.setOnClickListener {
            hideDetails()
        }

        tvBookTitle.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_title, Snackbar.LENGTH_SHORT).show()
        }

        tvBookAuthor.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_author, Snackbar.LENGTH_SHORT).show()
        }

        rbRatingIndicator.onRatingBarChangeListener =
            OnRatingBarChangeListener { ratingBar, rating, fromUser ->

                changeBooksRating(book, rating)

                Toast.makeText(
                    (activity as ListActivity).baseContext,
                    R.string.rating_changes_succesfully, Toast.LENGTH_SHORT
                ).show()
            }

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

        tvBookPublishYearTitle.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_publish_year, Snackbar.LENGTH_SHORT).show()
        }

        tvBookPublishYear.setOnClickListener {
            Snackbar.make(it, R.string.click_edit_button_to_edit_publish_year, Snackbar.LENGTH_SHORT).show()
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
                    book.bookISBN13,
                    book.bookPublishYear
                )
            }
        }

        ivDelete.setOnClickListener{
            val deleteBookWarningDialog = this.context?.let { it1 ->
                AlertDialog.Builder(it1)
                    .setTitle(R.string.warning_delete_book_title)
                    .setMessage(R.string.warning_delete_book_message)
                    .setIcon(R.drawable.ic_baseline_warning_amber_24)
                    .setPositiveButton(R.string.warning_delete_book_delete) { _, _ ->
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
                            book.bookISBN13,
                            book.bookPublishYear
                        )
                        recalculateChallenges(book.bookStatus)

                        Snackbar.make(it, getString(R.string.bookDeleted), Snackbar.LENGTH_LONG)
                            .setAction(getString(R.string.undo), UndoBookDeletion())
                            .show()
                    }
                    .setNegativeButton(R.string.warning_delete_book_cancel) { _, _ ->
                    }
                    .create()
            }

            deleteBookWarningDialog?.show()
            deleteBookWarningDialog?.getButton(AlertDialog.BUTTON_NEGATIVE)?.setTextColor(ContextCompat.getColor(listActivity.baseContext, R.color.grey_500))
        }

        requireActivity()
            .onBackPressedDispatcher
            .addCallback(viewLifecycleOwner, object : OnBackPressedCallback(true) {

                override fun handleOnBackPressed() {
                    if (ivDetails2.visibility == View.VISIBLE)
                        hideDetails()
                    else
                        findNavController().popBackStack()
                }
            }
            )
    }

    private fun showDetails() {
        ivDetails2.visibility = View.VISIBLE

        cvBookDisplay2.animate().translationY(0F).setInterpolator(AccelerateInterpolator(0.2F)).setDuration(500L).start()
        cvBookDisplay1.animate().translationY(0F).setInterpolator(AccelerateInterpolator(0.8F)).setDuration(500L).start()

        ivDetails.animate().rotation(180F).setDuration(500L).start()
        ivDetails.animate().alpha(0F).setDuration(250L).start()

        ivDetails2.animate().rotation(180F).alpha(1F).setDuration(500L).start()
        ivDetails2.bringToFront()

        MainScope().launch {
            delay(250L)
            ivDetails.visibility = View.INVISIBLE
            ivDetails2.visibility = View.VISIBLE
        }

        showEditAndDeleteViews()
    }

    private fun hideDetails() {
        ivDetails.visibility = View.VISIBLE

        cvBookDisplay2.animate().translationY(-1500F).setInterpolator(AccelerateInterpolator(1.2F)).setDuration(400L).start()
        cvBookDisplay1.animate().translationY(500F).setDuration(400L).start()

        ivDetails.animate().rotation(0F).setDuration(500L).start()
        ivDetails.animate().alpha(1F).setDuration(500L).start()

        ivDetails2.animate().rotation(0F).setDuration(500L).start()
        ivDetails2.animate().alpha(0F).setDuration(250L).start()
        ivDetails.bringToFront()

        MainScope().launch {
            delay(250L)
            ivDetails2.visibility = View.INVISIBLE
            ivDetails.visibility = View.VISIBLE
        }

        hideEditAndDeleteViews()
    }

    private fun showEditAndDeleteViews(){
        ivDelete.alpha = 0F
        ivDelete.visibility = View.VISIBLE
        ivDelete.animate().alpha(1F).setDuration(500L).start()

        ivEdit.alpha = 0F
        ivEdit.visibility = View.VISIBLE
        ivEdit.animate().alpha(1F).setDuration(500L).start()
    }

    private fun hideEditAndDeleteViews(){
        ivDelete.animate().alpha(0F).setDuration(400L).start()
        ivEdit.animate().alpha(0F).setDuration(400L).start()

        MainScope().launch {
            delay(400L)
            ivDelete.visibility = View.INVISIBLE
            ivEdit.visibility = View.INVISIBLE
        }
    }

    private fun initialViewsSetup() {
        tvBookTitle.text = book.bookTitle
        tvBookAuthor.text = book.bookAuthor
        rbRatingIndicator.rating = book.bookRating
        tvBookPages.text = book.bookNumberOfPages.toString()
        tvBookPublishYear.text = book.bookPublishYear.toString()

        cvBookDisplay2.translationY = -1500F
        cvBookDisplay1.translationY = 500F

        ivDetails.bringToFront()
        ivDetails.visibility = View.VISIBLE

        ivDetails2.alpha = 0F
        ivDetails2.visibility = View.INVISIBLE

        when (book.bookStatus) {
            Constants.BOOK_STATUS_READ -> {
                tvBookStatus.text = getString(R.string.finished)
                ivBookStatusInProgress.visibility = View.INVISIBLE
                ivBookStatusToRead.visibility = View.INVISIBLE
                rbRatingIndicator.visibility = View.VISIBLE
            }
            Constants.BOOK_STATUS_IN_PROGRESS -> {
                tvBookStatus.text = getString(R.string.inProgress)
                ivBookStatusRead.visibility = View.INVISIBLE
                ivBookStatusToRead.visibility = View.INVISIBLE
                rbRatingIndicator.visibility = View.GONE
            }
            Constants.BOOK_STATUS_TO_READ -> {
                tvBookStatus.text = getString(R.string.toRead)
                ivBookStatusInProgress.visibility = View.INVISIBLE
                ivBookStatusRead.visibility = View.INVISIBLE
                rbRatingIndicator.visibility = View.GONE
            }
        }
    }

    private fun animateCover() {
        ivBookCover.animate().scaleX(0.9F).scaleY(0.9F).setDuration(150L).start()

        MainScope().launch {
            delay(160L)
            ivBookCover.animate().scaleX(1F).scaleY(1F).setDuration(150L).start()
        }
    }

    private fun animateShowingDetails() {
        val views = arrayOf(
            tvBookPagesTitle,
            tvBookPages,
            tvBookPublishYear,
            tvBookPublishYearTitle,
            tvBookISBNTitle,
            tvBookISBN,
            tvBookURL,
            tvDateFinishedTitle,
            tvDateFinished,
            tvDateStartedTitle,
            tvDateStarted
        )

        for (view in views) {
            val animDuration = 300L
            val translationY = 300F

            view.alpha = 0F
            view.translationY = - translationY

            view.animate().alpha(1F).setStartDelay(50L).setDuration(animDuration - 50L).start()
            view.animate().translationYBy(translationY).setDuration(animDuration).start()
        }
    }

    private fun setCover(view: View) {
        if (book.bookCoverUrl == Constants.DATABASE_EMPTY_VALUE) {
            ivBookCover.visibility = View.GONE

            val tvBookTitleLayout = tvBookTitle.layoutParams as ConstraintLayout.LayoutParams
            tvBookTitleLayout.startToStart = R.id.clBookDisplay1
            tvBookTitle.layoutParams = tvBookTitleLayout
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

            val coverID = book.bookCoverUrl
            val coverUrl = "https://covers.openlibrary.org/b/id/$coverID-L.jpg"

            Picasso
                .get()
                .load(coverUrl)
                .placeholder(circularProgressDrawable)
                .error(R.drawable.ic_baseline_error_outline_24)
                .transform(RoundCornersTransform(16.0f))
                .into(ivBookCover)
        }
    }

    private fun setISBN() {
        if (book.bookISBN13 != Constants.DATABASE_EMPTY_VALUE) {
            tvBookISBN.text = book.bookISBN13
        } else if (book.bookISBN10 != Constants.DATABASE_EMPTY_VALUE) {
            tvBookISBN.text = book.bookISBN10
        } else {
            tvBookISBN.text = getString(R.string.not_set)
        }
    }

    private fun setOLID() {
        if (book.bookOLID != Constants.DATABASE_EMPTY_VALUE) {
            val olid: String = book.bookOLID
            val url = "https://openlibrary.org/books/$olid"
            tvBookURL.text = url
        }
    }

    private fun setFinishDate() {
        if(book.bookFinishDate == "none" || book.bookFinishDate == "null") {
            tvDateFinished.text = getString(R.string.not_set)
        } else {
            val bookFinishTimeStampLong = book.bookFinishDate.toLong()
            tvDateFinished.text = convertLongToTime(bookFinishTimeStampLong)
        }
    }

    private fun setStartDate() {
        if(book.bookStartDate == "none" || book.bookStartDate == "null") {
            tvDateStarted.text = getString(R.string.not_set)
        } else {
            val bookStartTimeStampLong = book.bookStartDate.toLong()
            tvDateStarted.text = convertLongToTime(bookStartTimeStampLong)
        }
    }

    private fun editBook() {
        val bundle = Bundle().apply {
            putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, book)
        }
        findNavController().navigate(
            R.id.action_displayBookFragment_to_editBookFragment,
            bundle
        )
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

    private fun changeBooksRating(book: Book, newRating: Float) {
        viewModel.updateBook(
            book.id,
            book.bookTitle,
            book.bookAuthor,
            newRating,
            book.bookStatus,
            book.bookPriority,
            book.bookStartDate,
            book.bookFinishDate,
            book.bookNumberOfPages,
            book.bookTitle_ASCII,
            book.bookAuthor_ASCII,
            book.bookIsDeleted,
            book.bookCoverUrl,
            book.bookOLID,
            book.bookISBN10,
            book.bookISBN13,
            book.bookPublishYear
        )
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