package software.mdev.bookstracker.ui.bookslist.fragments

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.DatePicker
import android.widget.EditText
import androidx.appcompat.app.AlertDialog
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
import kotlinx.android.synthetic.main.fragment_add_edit_book.*
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import java.text.Normalizer
import java.text.SimpleDateFormat
import java.util.*
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import android.widget.ArrayAdapter
import androidx.constraintlayout.widget.ConstraintLayout
import android.view.ViewGroup
import android.view.animation.BounceInterpolator
import androidx.core.view.marginTop
import kotlinx.coroutines.MainScope
import android.widget.RelativeLayout
import android.widget.AdapterView

import android.widget.TextView
import androidx.activity.OnBackPressedCallback
import kotlinx.android.synthetic.main.fragment_changelog.*
import kotlinx.android.synthetic.main.fragment_display_book.*


class EditBookFragment : Fragment(R.layout.fragment_add_edit_book) {

    lateinit var viewModel: BooksViewModel
    private val args: EditBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity
    private var bookFinishDateMs: Long? = null
    private var bookStartDateMs: Long? = null
    private var animateRating = false
    private var whatIsClicked = Constants.BOOK_STATUS_NOTHING

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val database = BooksDatabase(view.context)
        val yearDatabase = YearDatabase(view.context)
        val languageDatabase = LanguageDatabase(view.context)

        val repository = BooksRepository(database)
        val yearRepository = YearRepository(yearDatabase)
        val openLibraryRepository = OpenLibraryRepository()
        val languageRepository = LanguageRepository(languageDatabase)

        val booksViewModelProviderFactory = BooksViewModelProviderFactory(
            repository,
            yearRepository,
            openLibraryRepository,
            languageRepository
        )

        book = args.book
        val trueForEdit = args.trueForEdit
        var accentColor = getAccentColor(view.context)

        val viewModel = ViewModelProviders.of(this, booksViewModelProviderFactory).get(BooksViewModel::class.java)


        startDatePickerVis(false)
        finishDatePickerVis(false)
        setSpinner()
        initConfig()

        if (trueForEdit)
            populateBooksDetails()

        setInitialViews()

        tietBookTitle.requestFocus()
        showKeyboard(tietBookTitle,350)

        btnBookSave.setOnClickListener{
            view?.hideKeyboard()
            recalculateChallenges()
        }

        btnBookCancel.setOnClickListener{
            view?.hideKeyboard()
            recalculateChallenges()
        }

        clBookStartDate.setOnClickListener {
            view?.hideKeyboard()
            svEditor.visibility = View.GONE
            startDatePickerVis(true)
        }

        clBookFinishDate.setOnClickListener {
            view?.hideKeyboard()
            svEditor.visibility = View.GONE
            finishDatePickerVis(true)
        }

        btnStartDateCancel.setOnClickListener {
            svEditor.visibility = View.VISIBLE
            startDatePickerVis(false)
        }

        btnStartDateSave.setOnClickListener {
            svEditor.visibility = View.VISIBLE
            startDatePickerVis(false)
        }

        btnFinishDateCancel.setOnClickListener {
            svEditor.visibility = View.VISIBLE
            finishDatePickerVis(false)
        }

        btnFinishDateSave.setOnClickListener {
            svEditor.visibility = View.VISIBLE
            finishDatePickerVis(false)
        }

        requireActivity()
            .onBackPressedDispatcher
            .addCallback(viewLifecycleOwner, object : OnBackPressedCallback(true) {

                override fun handleOnBackPressed() {
                    if (dpBookStartDate.visibility == View.VISIBLE ||
                        dpBookFinishDate.visibility == View.VISIBLE) {
                            startDatePickerVis(false)
                            finishDatePickerVis(false)
                            svEditor.visibility = View.VISIBLE
                    }
                    else
                        findNavController().popBackStack()
                }
            }
            )

//        fabSaveEditedBook.setOnClickListener {
//            val bookTitle = etEditedBookTitle.text.toString()
//            val bookAuthor = etEditedBookAuthor.text.toString()
//
//            val bookPublishYear = etEditedPublishYear.text.toString()
//            var bookPublishYearInt = 0
//
//            if (bookPublishYear.isNotEmpty())
//                bookPublishYearInt = bookPublishYear.toInt()
//
//            var bookRating = 0.0F
//            val bookNumberOfPagesIntOrNull = etEditedPagesNumber.text.toString().toIntOrNull()
//            var bookNumberOfPagesInt: Int
//
//            var bookOLID = etEditedBookOLID.text.toString()
//            if (bookOLID.isEmpty()) {
//                bookOLID = Constants.DATABASE_EMPTY_VALUE
//            }
//
//            var bookISBN10 = etEditedBookISBN10.text.toString()
//            if (bookISBN10.isEmpty()) {
//                bookISBN10 = Constants.DATABASE_EMPTY_VALUE
//            }
//
//            var bookISBN13 = etEditedBookISBN13.text.toString()
//            if (bookISBN13.isEmpty()) {
//                bookISBN13 = Constants.DATABASE_EMPTY_VALUE
//            }
//
//            if (bookTitle.isNotEmpty()) {
//                if (bookAuthor.isNotEmpty()) {
//                    if (whatIsClicked != Constants.BOOK_STATUS_NOTHING) {
//                            bookNumberOfPagesInt = when (bookNumberOfPagesIntOrNull) {
//                                null -> 0
//                                else -> bookNumberOfPagesIntOrNull
//                            }
//
//                                    if ((bookFinishDateMs != null && bookStartDateMs != null && bookStartDateMs!! < bookFinishDateMs!!)
//                                        || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS
//                                        || whatIsClicked == Constants.BOOK_STATUS_TO_READ
//                                        || bookFinishDateMs == null
//                                        || bookStartDateMs == null ) {
//
//                                        when (whatIsClicked) {
//                                            Constants.BOOK_STATUS_READ -> {
//                                                bookRating = rbEditedRating.rating
//                                            }
//                                            Constants.BOOK_STATUS_IN_PROGRESS -> {
//                                                bookRating = 0.0F
//                                                bookFinishDateMs = null
//                                            }
//                                            Constants.BOOK_STATUS_TO_READ -> {
//                                                bookRating = 0.0F
//                                                bookNumberOfPagesInt = 0
//                                                bookStartDateMs = null
//                                                bookFinishDateMs = null
//                                            }
//                                        }
//
//                                            val REGEX_UNACCENT =
//                                                "\\p{InCombiningDiacriticalMarks}+".toRegex()
//
//                                            fun CharSequence.unaccent(): String {
//                                                val temp =
//                                                    Normalizer.normalize(this, Normalizer.Form.NFD)
//                                                return REGEX_UNACCENT.replace(temp, "")
//                                            }
//
//                                            val bookStatus = whatIsClicked
//
//                                            var newStartDate = bookStartDateMs.toString()
//                                            var newFinishDate = bookFinishDateMs.toString()
//
//                                            if (whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS || whatIsClicked == Constants.BOOK_STATUS_TO_READ) {
//                                                newStartDate = Constants.DATABASE_EMPTY_VALUE
//                                                newFinishDate = Constants.DATABASE_EMPTY_VALUE
//                                            }
//
//                                            viewModel.updateBook(
//                                                book.id,
//                                                bookTitle,
//                                                bookAuthor,
//                                                bookRating,
//                                                bookStatus,
//                                                book.bookPriority,
//                                                newStartDate,
//                                                newFinishDate,
//                                                bookNumberOfPagesInt,
//                                                bookTitle_ASCII = bookTitle.unaccent()
//                                                    .replace("ł", "l", false),
//                                                bookAuthor_ASCII = bookAuthor.unaccent()
//                                                    .replace("ł", "l", false),
//                                                false,
//                                                book.bookCoverUrl,
//                                                bookOLID,
//                                                bookISBN10,
//                                                bookISBN13,
//                                                bookPublishYearInt
//                                            )
//
//                                            recalculateChallenges()
//                                        } else {
//                                            Snackbar.make(it, R.string.sbWarningStartDateMustBeBeforeFinishDate, Snackbar.LENGTH_SHORT).show()
//                                        }
//                    } else {
//                        Snackbar.make(it, getString(R.string.sbWarningState), Snackbar.LENGTH_SHORT).show()
//                    }
//                } else {
//                    Snackbar.make(it, getString(R.string.sbWarningAuthor), Snackbar.LENGTH_SHORT).show()
//                }
//            } else {
//                Snackbar.make(it, getString(R.string.sbWarningTitle), Snackbar.LENGTH_SHORT).show()
//            }
//        }
    }

    private fun setInitialViews() {
        // add minimal delay to get proper height of views
        MainScope().launch {
            delay(50)
            rlBookStatus.layoutParams.height = tietBookTitle.height
            rlBookRating.layoutParams.height = tietBookTitle.height
            clBookStartDate.layoutParams.height = tietBookTitle.height
            clBookFinishDate.layoutParams.height = tietBookTitle.height

            rlBookStatus.requestLayout()
            rlBookRating.requestLayout()
            clBookStartDate.requestLayout()
            clBookFinishDate.requestLayout()
            ivBookFinishDate.requestLayout()
        }

        setRatingAndDatesVis()
    }

    private fun setSpinner() {
        val spinner = spBookStatus
        val bookStatuses = arrayListOf<String>()

        activity?.let {
            bookStatuses.add(it.getString(R.string.finished))
            bookStatuses.add(it.getString(R.string.inProgress))
            bookStatuses.add(it.getString(R.string.toRead))

            val spinnerAdapter = ArrayAdapter(requireActivity().baseContext, android.R.layout.simple_spinner_item, bookStatuses)
            spinnerAdapter.setDropDownViewResource(R.layout.simple_spinner_dropdown)
            spinner.adapter = spinnerAdapter
        }

        val listener: AdapterView.OnItemSelectedListener =
            object : AdapterView.OnItemSelectedListener {
                override fun onItemSelected(
                    parent: AdapterView<*>,
                    view: View,
                    position: Int,
                    id: Long
                ) {
                    activity?.resources?.getColor(R.color.colorGreyText)?.let {
                        (parent.getChildAt(0) as TextView).setTextColor(
                            it
                        )
                    }

                    when (position) {
                        0 -> ivBookStatus.setImageDrawable(activity?.baseContext?.resources?.getDrawable(R.drawable.ic_book_black_24dp))
                        1 -> ivBookStatus.setImageDrawable(activity?.baseContext?.resources?.getDrawable(R.drawable.ic_auto_stories_black_24dp))
                        2 -> ivBookStatus.setImageDrawable(activity?.baseContext?.resources?.getDrawable(R.drawable.ic_library_books_black_24dp))
                    }

                    when (position) {
                        0 -> whatIsClicked = Constants.BOOK_STATUS_READ
                        1 -> whatIsClicked = Constants.BOOK_STATUS_IN_PROGRESS
                        2 -> whatIsClicked = Constants.BOOK_STATUS_TO_READ
                    }

                    setRatingAndDatesVis()
                    animateRating = true
                }
                override fun onNothingSelected(parent: AdapterView<*>?) {}
            }

        spinner.onItemSelectedListener = listener
    }

    private fun populateBooksDetails() {
        tietBookTitle.setText(book.bookTitle)
        tietBookAuthor.setText(book.bookAuthor)

        when (book.bookStatus) {
            Constants.BOOK_STATUS_READ -> {
                whatIsClicked = Constants.BOOK_STATUS_READ
                rbBookRating.rating = book.bookRating
                spBookStatus.setSelection(0)
            }
            Constants.BOOK_STATUS_IN_PROGRESS -> {
                whatIsClicked = Constants.BOOK_STATUS_IN_PROGRESS
                tvBookRating.visibility = View.GONE
                rlBookRating.visibility = View.GONE
                spBookStatus.setSelection(1)
            }
            Constants.BOOK_STATUS_TO_READ -> {
                whatIsClicked = Constants.BOOK_STATUS_TO_READ
                tvBookRating.visibility = View.GONE
                rlBookRating.visibility = View.GONE
                spBookStatus.setSelection(2)
            }
        }

        tietBookPages.setText(book.bookNumberOfPages.toString())
        tietBookPublishYear.setText(book.bookPublishYear.toString())
        tietBookISBN.setText(book.bookISBN13)

        if(book.bookISBN13 == "none" || book.bookISBN13 == "null") {
            if(book.bookISBN10 == "none" || book.bookISBN10 == "null") {
                tietBookISBN.setText(Constants.EMPTY_STRING)
            } else {
                tietBookISBN.setText(book.bookISBN10)
            }
        } else {
            tietBookISBN.setText(book.bookISBN13)
        }

        if(book.bookOLID == "none" || book.bookOLID == "null") {
            tietBookOLID.setText(Constants.EMPTY_STRING)
        } else {
            tietBookOLID.setText(book.bookOLID)
        }

        if(book.bookStartDate == "none" || book.bookStartDate == "null") {
            tvBookStartDateValue.text = getString(R.string.set)
//            ivClearStartDate.visibility = View.INVISIBLE
        } else {
            var timeStampLong = book.bookStartDate.toLong()
            tvBookStartDateValue.text = convertLongToTime(timeStampLong)
//            ivClearStartDate.visibility = View.VISIBLE
        }

        if(book.bookFinishDate == "none" || book.bookFinishDate == "null") {
            tvBookFinishDateValue.text = getString(R.string.set)
//            ivClearStartDate.visibility = View.INVISIBLE
        } else {
            var timeStampLong = book.bookFinishDate.toLong()
            tvBookFinishDateValue.text = convertLongToTime(timeStampLong)
//            ivClearStartDate.visibility = View.VISIBLE
        }
    }

    private fun setRatingAndDatesVis() {
        when (whatIsClicked) {
            Constants.BOOK_STATUS_READ -> {
                tvBookRating.visibility = View.VISIBLE
                rlBookRating.visibility = View.VISIBLE

                tvBookStartDate.visibility = View.VISIBLE
                clBookStartDate.visibility = View.VISIBLE

                tvBookFinishDate.visibility = View.VISIBLE
                clBookFinishDate.visibility = View.VISIBLE

                val layoutParams: ConstraintLayout.LayoutParams = clBookStartDate.layoutParams as ConstraintLayout.LayoutParams
                layoutParams.endToEnd = tilBookPages.id
                clBookStartDate.layoutParams = layoutParams

                // disable scale anim on loading view when book status is finished
                if (animateRating)
                    hintRatingDatesAnim()
            }
            Constants.BOOK_STATUS_IN_PROGRESS -> {
                tvBookRating.visibility = View.GONE
                rlBookRating.visibility = View.GONE

                tvBookStartDate.visibility = View.VISIBLE
                clBookStartDate.visibility = View.VISIBLE

                tvBookFinishDate.visibility = View.GONE
                clBookFinishDate.visibility = View.GONE

                val layoutParams: ConstraintLayout.LayoutParams = clBookStartDate.layoutParams as ConstraintLayout.LayoutParams
                layoutParams.endToEnd = tilBookPublishYear.id
                clBookStartDate.layoutParams = layoutParams

                if (animateRating)
                    hintRatingDatesAnim()
            }
            Constants.BOOK_STATUS_TO_READ -> {
                tvBookRating.visibility = View.GONE
                rlBookRating.visibility = View.GONE

                tvBookStartDate.visibility = View.GONE
                clBookStartDate.visibility = View.GONE

                tvBookFinishDate.visibility = View.GONE
                clBookFinishDate.visibility = View.GONE
            }
        }
    }

    private fun startDatePickerVis(visibility: Boolean) {
        var viewVisibility = if (visibility)
            View.VISIBLE
        else
            View.GONE

        dpBookStartDate.visibility = viewVisibility
        btnStartDateCancel.visibility = viewVisibility
        btnStartDateSave.visibility = viewVisibility
    }

    private fun finishDatePickerVis(visibility: Boolean) {
        var viewVisibility = if (visibility)
            View.VISIBLE
        else
            View.GONE

        dpBookFinishDate.visibility = viewVisibility
        btnFinishDateCancel.visibility = viewVisibility
        btnFinishDateSave.visibility = viewVisibility
    }

    private fun initConfig() {
        dpBookStartDate.maxDate = System.currentTimeMillis()
//        dpBookFinishDate.maxDate = System.currentTimeMillis()
    }

    private fun hintRatingDatesAnim() {
        val scaleMap = arrayOf(1F, 1.1F)
        val myDuration = 200L
        val myRepeatCount = 1

        val viewsToAnimate = arrayOf(
            rlBookRating,
            clBookStartDate,
            clBookFinishDate
        )

        for (view in viewsToAnimate) {
            val animScaleX = scaleMap.map { map ->
                ObjectAnimator.ofFloat(view, "scaleX", map).apply {
                    duration = myDuration
                    repeatCount = myRepeatCount
                    repeatMode = ObjectAnimator.REVERSE
                }
            }

            val animScaleY = scaleMap.map { map ->
                ObjectAnimator.ofFloat(view, "scaleY", map).apply {
                    duration = myDuration
                    repeatCount = myRepeatCount
                    repeatMode = ObjectAnimator.REVERSE
                }
            }

            val set = AnimatorSet()
            set.playTogether(animScaleX)
            set.playTogether(animScaleY)
            set.start()
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

    fun showKeyboard(et: EditText, delay: Long) {
        val timer = Timer()
        timer.schedule(object : TimerTask() {
            override fun run() {
                val inputManager = context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                inputManager.showSoftInput(et, 0)
            }
        }, delay)
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

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        var accent = sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_ACCENT, Constants.THEME_ACCENT_DEFAULT).toString()

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

    fun convertLongToYear(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("yyyy")
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
            delay(100L)
            view?.hideKeyboard()
            findNavController().popBackStack()
        }
    }
}