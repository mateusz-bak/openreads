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
import android.graphics.BitmapFactory
import android.view.animation.AnimationUtils
import androidx.core.content.res.ResourcesCompat
import androidx.recyclerview.widget.GridLayoutManager
import com.google.gson.Gson
import software.mdev.bookstracker.adapters.BookDetailsAdapter
import software.mdev.bookstracker.data.db.entities.BookDetail
import software.mdev.bookstracker.other.Functions
import software.mdev.bookstracker.ui.bookslist.dialogs.AddEditBookDialog


class DisplayBookFragment : Fragment(R.layout.fragment_display_book) {

    lateinit var viewModel: BooksViewModel
    private val args: DisplayBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity
    private var layoutManager: GridLayoutManager? = null
    private var adapter: BookDetailsAdapter? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        book = args.book

        val span = readDetailsMode()
        setDetailsRV(listActivity, span)
        initialViewsSetup()

        ivBookCover.setOnClickListener {
            animateClickView(it)
        }

        ivEdit.setOnClickListener {
            editBook()
        }

        ivFav.setOnClickListener {
            animatShakeView(it)

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
                    book.bookCoverImg,
                    book.bookNotes,
                    book.bookTags
                )
            }
        }

        ivDelete.setOnClickListener{
            var firstCheck = true
            viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->

                if (firstCheck) {
                    firstCheck = false

                    val deleteBookWarningDialog = this.context?.let { it1 ->
                        AlertDialog.Builder(it1)
                            .setTitle(R.string.warning_delete_book_title)
                            .setMessage(R.string.warning_delete_book_message)
                            .setIcon(R.drawable.ic_iconscout_exclamation_triangle_24)
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
                                    book.bookCoverImg,
                                    book.bookNotes,
                                    book.bookTags
                                )
                                recalculateChallenges()

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

        ivGrid.setOnClickListener {
            animatShakeView(it)
            if (layoutManager?.spanCount == 1) {
                layoutManager?.spanCount = 2
                showGridIcon(false)
                saveDetailsMode(true)
            } else {
                layoutManager?.spanCount = 1
                showGridIcon(true)
                saveDetailsMode(false)
            }

            adapter?.notifyItemRangeChanged(0, adapter?.itemCount ?: 0)
        }
    }

    private fun showGridIcon(show: Boolean) {
        if (show) {
            ivGrid.setImageDrawable(activity?.resources?.getDrawable(R.drawable.ic_iconscout_apps_24))
            ivGrid.imageTintList = ColorStateList.valueOf(resources.getColor(R.color.grey_777))
        } else {
            ivGrid.setImageDrawable(activity?.resources?.getDrawable(R.drawable.ic_iconscout_align_justify_24))
            ivGrid.imageTintList = ColorStateList.valueOf(resources.getColor(R.color.grey_777))
        }
    }

    private fun saveDetailsMode(show: Boolean) {
        var sharedPreferencesName = context?.getString(R.string.shared_preferences_name)
        val sharedPref = context?.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        val editor = sharedPref?.edit()

        editor?.apply {
            putBoolean(Constants.SHARED_PREFERENCES_KEY_DETAILS_MODE, show)
            apply()
        }
    }

    private fun readDetailsMode(): Int {
        var sharedPreferencesName = context?.getString(R.string.shared_preferences_name)
        val sharedPref = context?.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        return if (sharedPref?.getBoolean(
                Constants.SHARED_PREFERENCES_KEY_DETAILS_MODE,
                true
            ) == true
        ) {
            showGridIcon(false)
            2
        } else {
            showGridIcon(true)
            1
        }
    }

    private fun setDetailsRV(activity: ListActivity, span: Int) {
        layoutManager = GridLayoutManager(activity, span)
        rvBookDetails.layoutManager = layoutManager

        adapter = BookDetailsAdapter(requireContext())
        rvBookDetails.adapter = adapter
    }

    private fun initialViewsSetup() {
        viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->
            tvBookTitle.text = book.bookTitle
            tvBookAuthor.text = book.bookAuthor
            rbRatingIndicator.rating = book.bookRating

            when (book.bookStatus) {
                Constants.BOOK_STATUS_READ -> {
                    tvBookStatus.text = getString(R.string.finished)
                    ivBookStatusRead.visibility = View.VISIBLE
                    ivBookStatusInProgress.visibility = View.INVISIBLE
                    ivBookStatusToRead.visibility = View.INVISIBLE
                    ivBookStatusNotFinished.visibility = View.INVISIBLE
                    rbRatingIndicator.visibility = View.VISIBLE
                    rearrangeViewsWhenFinished()
                }
                Constants.BOOK_STATUS_IN_PROGRESS -> {
                    tvBookStatus.text = getString(R.string.inProgress)
                    ivBookStatusRead.visibility = View.INVISIBLE
                    ivBookStatusInProgress.visibility = View.VISIBLE
                    ivBookStatusToRead.visibility = View.INVISIBLE
                    ivBookStatusNotFinished.visibility = View.INVISIBLE
                    rbRatingIndicator.visibility = View.GONE
                    rearrangeViewsWhenNotFinished()
                }
                Constants.BOOK_STATUS_NOT_FINISHED -> {
                    tvBookStatus.text = getString(R.string.notFinished)
                    ivBookStatusRead.visibility = View.INVISIBLE
                    ivBookStatusInProgress.visibility = View.INVISIBLE
                    ivBookStatusToRead.visibility = View.INVISIBLE
                    ivBookStatusNotFinished.visibility = View.VISIBLE
                    rbRatingIndicator.visibility = View.GONE
                    rearrangeViewsWhenNotFinished()
                }
                Constants.BOOK_STATUS_TO_READ -> {
                    tvBookStatus.text = getString(R.string.toRead)
                    ivBookStatusRead.visibility = View.INVISIBLE
                    ivBookStatusInProgress.visibility = View.INVISIBLE
                    ivBookStatusToRead.visibility = View.VISIBLE
                    ivBookStatusNotFinished.visibility = View.INVISIBLE
                    rbRatingIndicator.visibility = View.GONE
                    rearrangeViewsWhenNotFinished()
                }
            }

            setDetails(book)
        }
    }

    private fun setDetails(book: Book) {
        setCover(book.bookCoverImg)
        setFav(book.bookIsFav, book.bookStatus)

        var details = emptyList<BookDetail>()

        // below lines set order for displaying details
        details = getBookDate(book.bookStartDate, details, Constants.detailStartDate)
        details = getBookDate(book.bookFinishDate, details, Constants.detailFinishDate)
        details = getReadingTime(book.bookStartDate, book.bookFinishDate, details)
        details = getPages(book.bookNumberOfPages, details)
        details = getPublishDate(book.bookPublishYear, details)
        details = getTags(book.bookTags, details)
        details = getISBN(book.bookISBN13, book.bookISBN10, details)
        details = getOLID(book.bookOLID, details)
        details = getNotes(book.bookNotes, details)
        details = getOLIDURL(book.bookOLID, details)

        adapter?.differ?.submitList(details)
        adapter?.notifyDataSetChanged()
    }

    private fun getTags(tags: List<String>?, details: List<BookDetail>): List<BookDetail> {
        return if (tags != null) {
            val json = Gson().toJson(tags)
            details + BookDetail(Constants.detailTags, json)
        } else
            details
    }

    private fun getPages(bookNumberOfPages: Int, details: List<BookDetail>): List<BookDetail> {
        return if (bookNumberOfPages > 0) {
            details + BookDetail(Constants.detailPages, bookNumberOfPages.toString())
        } else {
            details
        }
    }

    private fun getReadingTime(
        start: String,
        finish: String,
        details: List<BookDetail>
    ): List<BookDetail> {
        return if (finish != "none" &&
            finish != "null" &&
            start != "none" &&
            start != "null"
        ) {
            val startTimeStampLong = start.toLong()
            val finishTimeStampLong = finish.toLong()
            val diff = finishTimeStampLong - startTimeStampLong
            val result = Functions().convertLongToDays(diff, resources)

            details + BookDetail(Constants.detailReadingTime, result)
        } else {
            details
        }
    }

    private fun getPublishDate(bookPublishYear: Int, details: List<BookDetail>): List<BookDetail> {
        return if (bookPublishYear > 0) {
            details + BookDetail(Constants.detailPublishYear, bookPublishYear.toString())
        } else {
            details
        }
    }

    private fun animateClickView(view: View, multiplier: Float = 1F) {
        view.animate().scaleX(0.9F * multiplier).scaleY(0.9F * multiplier).setDuration(150L).start()

        MainScope().launch {
            delay(160L)
            view.animate().scaleX(1F).scaleY(1F).setDuration(150L).start()
        }
    }

    private fun animatShakeView(view: View) {
        var anim = AnimationUtils.loadAnimation(context, R.anim.shake_1_light)
        view.startAnimation(anim)
    }

    private fun setCover(bookCoverImg: ByteArray?) {
        if (bookCoverImg == null)
            rearrangeViewsWhenCoverMissing()
        else {
            rearrangeViewsWhenCoverNotMissing()

            val bmp = BitmapFactory.decodeByteArray(bookCoverImg, 0, bookCoverImg.size)
            ivBookCover.setImageBitmap(bmp)
        }
    }

    private fun rearrangeViewsWhenNotFinished() {
        val ivEditLayout = ivEdit.layoutParams as ConstraintLayout.LayoutParams
        ivEditLayout.bottomToBottom = ConstraintLayout.LayoutParams.UNSET
        ivEditLayout.endToStart = ConstraintLayout.LayoutParams.UNSET
        ivEditLayout.startToEnd = ConstraintLayout.LayoutParams.UNSET
        ivEditLayout.topToTop = ConstraintLayout.LayoutParams.UNSET

        ivEditLayout.startToStart = R.id.tvBookAuthor
        ivEditLayout.topToBottom = R.id.tvBookStatus

        ivEditLayout.marginStart = -20
        ivEditLayout.topMargin = 36
        ivEdit.layoutParams = ivEditLayout

        val ivDeleteLayout = ivDelete.layoutParams as ConstraintLayout.LayoutParams
        ivDeleteLayout.bottomToBottom = ConstraintLayout.LayoutParams.UNSET
        ivDeleteLayout.endToEnd = ConstraintLayout.LayoutParams.UNSET

        ivDeleteLayout.startToEnd = R.id.ivEdit
        ivDeleteLayout.endToStart = R.id.ivGrid
        ivDelete.layoutParams = ivDeleteLayout

        val ivGridLayout = ivGrid.layoutParams as ConstraintLayout.LayoutParams
        ivGridLayout.bottomToBottom = ConstraintLayout.LayoutParams.UNSET
        ivGridLayout.endToEnd = ConstraintLayout.LayoutParams.UNSET

        ivGridLayout.endToEnd = R.id.guideline16
        ivGridLayout.startToEnd = R.id.ivDelete
        ivGrid.layoutParams = ivGridLayout

        ivFav.visibility = View.GONE
    }

    private fun rearrangeViewsWhenFinished() {
        ivFav.visibility = View.VISIBLE

        val ivEditLayout = ivEdit.layoutParams as ConstraintLayout.LayoutParams
        ivEditLayout.bottomToBottom = ConstraintLayout.LayoutParams.UNSET
        ivEditLayout.endToStart = ConstraintLayout.LayoutParams.UNSET
        ivEditLayout.startToEnd = ConstraintLayout.LayoutParams.UNSET
        ivEditLayout.startToStart = ConstraintLayout.LayoutParams.UNSET
        ivEditLayout.topToTop = ConstraintLayout.LayoutParams.UNSET

        ivEditLayout.startToEnd = R.id.ivFav
        ivEditLayout.endToStart = R.id.ivDelete
        ivEditLayout.topToTop = R.id.ivFav
        ivEditLayout.bottomToBottom = R.id.ivFav

        ivEditLayout.marginStart = 0
        ivEditLayout.marginEnd = 0
        ivEditLayout.topMargin = 0
        ivEdit.layoutParams = ivEditLayout
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
    }
    private fun rearrangeViewsWhenCoverNotMissing() {
        ivBookCover.visibility = View.VISIBLE

        val tvBookTitleLayout = tvBookTitle.layoutParams as ConstraintLayout.LayoutParams
        tvBookTitleLayout.startToStart = R.id.guideline13
        tvBookTitle.layoutParams = tvBookTitleLayout

        val rbRatingIndicatorLayout = rbRatingIndicator.layoutParams as ConstraintLayout.LayoutParams
        rbRatingIndicatorLayout.endToStart = ConstraintLayout.LayoutParams.UNSET
        rbRatingIndicatorLayout.endToEnd = R.id.tvBookAuthor
        rbRatingIndicatorLayout.marginStart = -20 // TODO ???
        rbRatingIndicatorLayout.marginEnd = 0 // TODO ???
        rbRatingIndicator.layoutParams = rbRatingIndicatorLayout

        val ivDeleteLayout = ivDelete.layoutParams as ConstraintLayout.LayoutParams
        ivDeleteLayout.startToEnd = R.id.ivEdit
        ivDeleteLayout.endToStart = R.id.ivGrid
        ivDelete.layoutParams = ivDeleteLayout

        val ivGridLayout = ivGrid.layoutParams as ConstraintLayout.LayoutParams
        ivGridLayout.startToEnd = R.id.ivDelete
        ivGridLayout.endToEnd = R.id.tvBookAuthor
        ivGrid.layoutParams = ivGridLayout
    }

    private fun getISBN(
        bookISBN13: String,
        bookISBN10: String,
        details: List<BookDetail>
    ): List<BookDetail> {
        return if (bookISBN13 != Constants.DATABASE_EMPTY_VALUE && bookISBN13 != "")
            details + BookDetail(Constants.detailISBN, bookISBN13)
        else if (bookISBN10 != Constants.DATABASE_EMPTY_VALUE && bookISBN10 != "")
            details + BookDetail(Constants.detailISBN, bookISBN10)
        else
            details
    }

    private fun getNotes(bookNotes: String, details: List<BookDetail>): List<BookDetail> {
        return if (bookNotes != Constants.EMPTY_STRING)
            details + BookDetail(Constants.detailNotes, bookNotes)
        else
            details
    }

    private fun getOLID(bookOLID: String, details: List<BookDetail>): List<BookDetail> {
        return if (bookOLID != Constants.DATABASE_EMPTY_VALUE && bookOLID != "")
            details + BookDetail(Constants.detailOLID, bookOLID)
        else
            details
    }

    private fun getOLIDURL(bookOLID: String, details: List<BookDetail>): List<BookDetail> {
        return if (bookOLID != Constants.DATABASE_EMPTY_VALUE && bookOLID != "") {
            val olid: String = bookOLID
            val url = "https://openlibrary.org/books/$olid"

            details + BookDetail(Constants.detailUrl, url)
        } else
            details
    }

    private fun getBookDate(date: String, details: List<BookDetail>, id: Int): List<BookDetail> {
        return if (date == "none" || date == "null") {
            details
        } else {
            val dateTimeStampLong = date.toLong()
            details + BookDetail(id, convertLongToTime(dateTimeStampLong))
        }
    }

    private fun editBook() {
        var firstTime = true
        viewModel.getBook(book.id).observe(viewLifecycleOwner) { book ->
            val addEditBookDialog = AddEditBookDialog()

            val bookStatusInt = when (book.bookStatus) {
                Constants.BOOK_STATUS_IN_PROGRESS -> 1
                Constants.BOOK_STATUS_TO_READ -> 2
                Constants.BOOK_STATUS_NOT_FINISHED -> 3
                else -> 0
            }

            if (addEditBookDialog != null && firstTime) {
                addEditBookDialog!!.arguments = Bundle().apply {
                    putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, book)
                    putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK_SOURCE, Constants.FROM_DISPLAY)
                    putSerializable(Constants.SERIALIZABLE_BUNDLE_ACCENT, (activity as ListActivity).getAccentColor(activity as ListActivity, true))
                    putInt(Constants.SERIALIZABLE_BUNDLE_BOOK_STATUS, bookStatusInt)
                }
                addEditBookDialog!!.show(childFragmentManager, AddEditBookDialog.TAG)
                firstTime = false
            }
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

    private fun recalculateChallenges() {
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
            findNavController().navigate(R.id.action_displayBookFragment_to_booksFragment)
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
            book.bookCoverImg,
            book.bookNotes,
            book.bookTags
        )
    }

    private fun setFav(bookIsFav: Boolean, bookStatus: String) {
        if (bookIsFav && bookStatus == Constants.BOOK_STATUS_READ) {
            var color = context?.let { getAccentColor(it) }
            ivFav.imageTintList = color?.let { ColorStateList.valueOf(it) }
            ivFav.setImageDrawable(activity?.baseContext?.resources?.let {
                ResourcesCompat.getDrawable(
                    it, R.drawable.ic_iconscout_heart_filled_24, null
                )
            })
        } else if (bookStatus == Constants.BOOK_STATUS_IN_PROGRESS || bookStatus == Constants.BOOK_STATUS_TO_READ) {
            ivFav.visibility = View.GONE
        }
    }

    private fun changeBooksFav(book: Book, fav: Boolean) {
        if (fav) {
            var color = context?.let { getAccentColor(it) }
            ivFav.imageTintList = color?.let { ColorStateList.valueOf(it) }
            ivFav.setImageDrawable(activity?.baseContext?.resources?.let {
                ResourcesCompat.getDrawable(
                    it, R.drawable.ic_iconscout_heart_filled_24, null
                )
            })
        } else {
            ivFav.imageTintList = ColorStateList.valueOf(resources.getColor(R.color.grey_777))
            ivFav.setImageDrawable(activity?.baseContext?.resources?.let {
                ResourcesCompat.getDrawable(
                    it, R.drawable.ic_iconscout_heart_24, null
                )
            })
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
            book.bookCoverImg,
            book.bookNotes,
            book.bookTags
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