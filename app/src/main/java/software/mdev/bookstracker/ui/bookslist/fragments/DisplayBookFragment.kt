package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.content.res.ColorStateList
import android.os.Bundle
import android.view.View
import androidx.core.content.ContextCompat
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.fragment_display_book.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import java.text.SimpleDateFormat
import java.util.*
import android.view.animation.AnticipateOvershootInterpolator
import android.view.inputmethod.InputMethodManager
import androidx.appcompat.app.AlertDialog
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import android.widget.Toast
import android.widget.RatingBar.OnRatingBarChangeListener
import kotlinx.coroutines.MainScope
import androidx.activity.OnBackPressedCallback
import android.graphics.BitmapFactory


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

        ivBookCover.setOnClickListener {
            animateClickView(it)

            if (ivDetails2.visibility == View.VISIBLE)
                hideDetails()
            else
                showDetails()
        }

        ivEdit.setOnClickListener {
            animateClickView(it)
            editBook()
        }

        ivFav.setOnClickListener {
            animateClickView(it, 0.6F)

            var firstCheck = true
            viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->
                if (firstCheck) {
                    firstCheck = false

                    if (book.bookIsFav) {
                        changeBooksFav(book, false)

                        Toast.makeText(
                            (activity as ListActivity).baseContext,
                            R.string.removed_from_fav, Toast.LENGTH_SHORT
                        ).show()
                    } else {
                        changeBooksFav(book, true)

                        Toast.makeText(
                            (activity as ListActivity).baseContext,
                            R.string.added_to_fav, Toast.LENGTH_SHORT
                        ).show()
                    }
                }
            }
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
            OnRatingBarChangeListener { _, rating, fromUser ->

                if (fromUser) {
                    var firstCheck = true
                    viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->
                        if (firstCheck) {
                            firstCheck = false
                            changeBooksRating(book, rating)

                            Toast.makeText(
                                (activity as ListActivity).baseContext,
                                R.string.rating_changes_succesfully, Toast.LENGTH_SHORT
                            ).show()
                        }
                    }
                }
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

        clDetails.setOnClickListener {
            hideDetails()
        }

        class UndoBookDeletion(book: Book) : View.OnClickListener {
            var book = book
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
                    book.bookPublishYear,
                    book.bookIsFav,
                    book.bookCoverImg
                )
            }
        }

        ivDelete.setOnClickListener{
            animateClickView(it)
            var firstCheck = true
            viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->

                if (firstCheck) {
                    firstCheck = false

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
                                    book.bookPublishYear,
                                    book.bookIsFav,
                                    book.bookCoverImg
                                )
                                recalculateChallenges(book.bookStatus)

                                Snackbar.make(it, getString(R.string.bookDeleted), Snackbar.LENGTH_LONG)
                                    .setAction(getString(R.string.undo), UndoBookDeletion(book))
                                    .show()
                            }
                            .setNegativeButton(R.string.warning_delete_book_cancel) { _, _ ->
                            }
                            .create()
                    }

                    deleteBookWarningDialog?.show()
                    deleteBookWarningDialog?.getButton(AlertDialog.BUTTON_NEGATIVE)?.setTextColor(ContextCompat.getColor(listActivity.baseContext, R.color.grey_500))
                }
            }
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

    override fun onResume() {
        super.onResume()
        initialViewsSetup()
    }

    private fun showDetails() {
        blockDetails()
        ivDetails2.visibility = View.VISIBLE

        cvBookDisplay2.animate().translationY(0F).setInterpolator(AnticipateOvershootInterpolator(1.2F)).setDuration(500L).start()
        cvBookDisplay1.animate().translationY(0F).setInterpolator(AnticipateOvershootInterpolator(1.2F)).setDuration(500L).start()

        cvBookDisplay2.scaleX = 0.2F
        cvBookDisplay2.scaleY = 0.2F
        cvBookDisplay2.animate().scaleX(1F).setInterpolator(AnticipateOvershootInterpolator(1.2F)).setDuration(600L).start()
        cvBookDisplay2.animate().scaleY(1F).setInterpolator(AnticipateOvershootInterpolator(1.2F)).setDuration(600L).start()


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
        blockDetails()
        ivDetails.visibility = View.VISIBLE

        cvBookDisplay2.animate().translationY(-1500F).setInterpolator(AnticipateOvershootInterpolator(1.2F)).setDuration(500L).start()
        cvBookDisplay1.animate().translationY(500F).setDuration(500L).start()

        cvBookDisplay2.animate().scaleX(0.2F).setInterpolator(AnticipateOvershootInterpolator(1.2F)).setDuration(400L).start()
        cvBookDisplay2.animate().scaleY(0.2F).setInterpolator(AnticipateOvershootInterpolator(1.2F)).setDuration(400L).start()

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

    private fun blockDetails() {
        ivDetails.isClickable = false
        ivDetails2.isClickable = false
        ivBookCover.isClickable = false

        MainScope().launch {
            delay(300)

            ivDetails.isClickable = true
            ivDetails2.isClickable = true
            ivBookCover.isClickable = true
        }
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
        cvBookDisplay1.bringToFront()

        cvBookDisplay2.translationY = -1500F
        cvBookDisplay1.translationY = 500F

        ivDetails.bringToFront()
        ivDetails.visibility = View.VISIBLE

        ivDetails2.alpha = 0F
        ivDetails2.visibility = View.INVISIBLE



        viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->
            tvBookTitle.text = book.bookTitle
            tvBookAuthor.text = book.bookAuthor
            rbRatingIndicator.rating = book.bookRating

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

            setCover(book.bookCoverImg)
            setISBN(book.bookISBN13, book.bookISBN10)
            setOLID(book.bookOLID)
            setPages(book.bookNumberOfPages)
            setPublishDate(book.bookPublishYear)
            setFinishDate(book.bookFinishDate)
            setStartDate(book.bookStartDate)
            setFav(book.bookIsFav, book.bookStatus)
        }
    }

    private fun setPages(bookNumberOfPages: Int) {
        if (bookNumberOfPages > 0)
            tvBookPages.text = bookNumberOfPages.toString()
        else {
            tvBookPagesTitle.visibility = View.GONE
            tvBookPages.visibility = View.GONE
            ivPages.visibility = View.GONE
        }
    }

    private fun setPublishDate(bookPublishYear: Int) {
        if (bookPublishYear > 0)
            tvBookPublishYear.text = book.bookPublishYear.toString()
        else {
            tvBookPublishYearTitle.visibility = View.GONE
            tvBookPublishYear.visibility = View.GONE
            ivPublishYear.visibility = View.GONE
        }
    }

    private fun animateClickView(view: View, multiplier: Float = 1F) {
        view.animate().scaleX(0.9F * multiplier).scaleY(0.9F * multiplier).setDuration(150L).start()

        MainScope().launch {
            delay(160L)
            view.animate().scaleX(1F).scaleY(1F).setDuration(150L).start()
        }
    }

    private fun setCover(bookCoverImg: ByteArray?) {
        if (bookCoverImg == null)
            rearrangeViewsWhenCoverMissing()
        else {
            val bmp = BitmapFactory.decodeByteArray(bookCoverImg, 0, bookCoverImg.size)
            ivBookCover.setImageBitmap(bmp)
        }
    }

    private fun rearrangeViewsWhenCoverMissing() {
        ivBookCover.visibility = View.GONE

        val tvBookTitleLayout = tvBookTitle.layoutParams as ConstraintLayout.LayoutParams
        tvBookTitleLayout.startToStart = R.id.clBookDisplay1
        tvBookTitle.layoutParams = tvBookTitleLayout

        val rbRatingIndicatorLayout = rbRatingIndicator.layoutParams as ConstraintLayout.LayoutParams
        rbRatingIndicatorLayout.endToStart = R.id.guideline16
        rbRatingIndicatorLayout.marginStart = -20
        rbRatingIndicatorLayout.marginEnd = 0
        rbRatingIndicator.layoutParams = rbRatingIndicatorLayout

        var margin = 0

        val ivDetailsLayout = ivDetails.layoutParams as ConstraintLayout.LayoutParams
        ivDetailsLayout.startToStart = R.id.clBookDisplay1
        ivDetailsLayout.marginEnd = margin
        ivDetails.layoutParams = ivDetailsLayout

        val ivFavLayout = ivFav.layoutParams as ConstraintLayout.LayoutParams
        ivFavLayout.marginStart = margin
        ivFavLayout.marginEnd = margin
        ivFav.layoutParams = ivFavLayout

        val ivEditLayout = ivEdit.layoutParams as ConstraintLayout.LayoutParams
        ivEditLayout.marginStart = margin
        ivEditLayout.marginEnd = margin
        ivEdit.layoutParams = ivEditLayout

        val ivDeleteLayout = ivDelete.layoutParams as ConstraintLayout.LayoutParams
        ivDeleteLayout.endToStart = R.id.guideline16
        ivDeleteLayout.marginStart = margin
        ivDeleteLayout.marginEnd = 0
        ivDelete.layoutParams = ivDeleteLayout
    }

    private fun setISBN(bookISBN13: String, bookISBN10: String) {
        if (bookISBN13 != Constants.DATABASE_EMPTY_VALUE && bookISBN13 != "") {
            tvBookISBN.text = bookISBN13
        } else if (bookISBN10 != Constants.DATABASE_EMPTY_VALUE && bookISBN10 != "") {
            tvBookISBN.text = bookISBN10
        } else {
            tvBookISBNTitle.visibility = View.GONE
            tvBookISBN.visibility = View.GONE
            ivISBN.visibility = View.GONE
        }
    }

    private fun setOLID(bookOLID: String) {
        if (bookOLID != Constants.DATABASE_EMPTY_VALUE && bookOLID != "") {
            val olid: String = bookOLID
            val url = "https://openlibrary.org/books/$olid"
            tvBookOLID.text = bookOLID
            tvBookURL.text = url
        } else {
            tvBookOLIDTitle.visibility = View.GONE
            tvBookOLID.visibility = View.GONE
            ivOLID.visibility = View.GONE
            tvBookURL.visibility = View.GONE
        }
    }

    private fun setFinishDate(bookFinishDate: String) {
        if(bookFinishDate == "none" || bookFinishDate == "null") {
            tvDateFinished.text = getString(R.string.not_set)
        } else {
            val bookFinishTimeStampLong = bookFinishDate.toLong()
            tvDateFinished.text = convertLongToTime(bookFinishTimeStampLong)
        }
    }

    private fun setStartDate(bookStartDate: String) {
        if(bookStartDate == "none" || bookStartDate == "null") {
            tvDateStarted.text = getString(R.string.not_set)
        } else {
            val bookStartTimeStampLong = bookStartDate.toLong()
            tvDateStarted.text = convertLongToTime(bookStartTimeStampLong)
        }
    }

    private fun editBook() {
        viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->
            val bundle = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, book)
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK_SOURCE, Constants.FROM_DISPLAY)
            }

            findNavController().navigate(
                R.id.action_displayBookFragment_to_addEditBookFragment,
                bundle
            )
        }
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
        book.bookRating = newRating

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
            book.bookPublishYear,
            book.bookIsFav,
            book.bookCoverImg
        )
    }

    private fun setFav(bookIsFav: Boolean, bookStatus: String) {
        if (bookIsFav && bookStatus == Constants.BOOK_STATUS_READ) {
            var color = context?.let { getAccentColor(it) }
            ivFav.imageTintList = color?.let { ColorStateList.valueOf(it) }
            ivFav.setImageDrawable(resources.getDrawable(R.drawable.ic_baseline_favorite_24))
        } else if (bookStatus == Constants.BOOK_STATUS_IN_PROGRESS || bookStatus == Constants.BOOK_STATUS_TO_READ) {
            ivFav.visibility = View.GONE
        }
    }

    private fun changeBooksFav(book: Book, fav: Boolean) {
        if (fav) {
            var color = context?.let { getAccentColor(it) }
            ivFav.imageTintList = color?.let { ColorStateList.valueOf(it) }
            ivFav.setImageDrawable(resources.getDrawable(R.drawable.ic_baseline_favorite_24))
        } else {
            ivFav.imageTintList = ColorStateList.valueOf(resources.getColor(R.color.grey_777))
            ivFav.setImageDrawable(resources.getDrawable(R.drawable.ic_baseline_favorite_border_24))
        }

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
            book.bookIsDeleted,
            book.bookCoverUrl,
            book.bookOLID,
            book.bookISBN10,
            book.bookISBN13,
            book.bookPublishYear,
            fav,
            book.bookCoverImg
        )
    }

    private fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

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
}