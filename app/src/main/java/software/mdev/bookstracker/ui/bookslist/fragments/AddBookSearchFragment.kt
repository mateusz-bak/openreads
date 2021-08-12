package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.DatePicker
import android.widget.EditText
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.content.ContextCompat
import androidx.core.view.updateLayoutParams
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import software.mdev.bookstracker.ui.bookslist.ListActivity
import kotlinx.android.synthetic.main.fragment_add_book_search.*
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import java.text.SimpleDateFormat
import java.util.*
import androidx.lifecycle.Observer
import androidx.lifecycle.lifecycleScope
import androidx.recyclerview.widget.LinearLayoutManager
import com.google.android.material.snackbar.Snackbar
import kotlinx.coroutines.*
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import software.mdev.bookstracker.adapters.ByOLIDBookAdapter
import software.mdev.bookstracker.adapters.LanguageAdapter
import software.mdev.bookstracker.adapters.SearchedBookAdapter
import software.mdev.bookstracker.api.models.OpenLibraryBook
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.other.Resource
import kotlin.collections.ArrayList


class AddBookSearchFragment : Fragment(R.layout.fragment_add_book_search) {

    lateinit var viewModel: BooksViewModel
    lateinit var searchedBookAdapter: SearchedBookAdapter
    lateinit var byOLIDBookAdapter: ByOLIDBookAdapter
    lateinit var languageAdapter: LanguageAdapter

    lateinit var book: Book
    lateinit var listActivity: ListActivity
    private var bookFinishDateMs: Long? = null

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        var whatIsClicked = Constants.BOOK_STATUS_NOTHING

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

        var accentColor = getAccentColor(view.context.applicationContext)

        rbRating.visibility = View.GONE
//        tvRateThisBook.visibility = View.GONE
//        etPagesNumber.visibility = View.GONE
        btnSetFinishDate.visibility = View.GONE
        btnSetFinishDate.isClickable = false
        dpBookFinishDate.visibility = View.GONE
        btnSaveFinishDate.visibility = View.GONE
        btnCancelFinishDate.visibility = View.GONE
        dpBookFinishDate.maxDate = System.currentTimeMillis()

        ivBookStatusRead.visibility         = View.GONE
        ivBookStatusInProgress.visibility   = View.GONE
        ivBookStatusToRead.visibility       = View.GONE

        tvFinished.visibility               = View.GONE
        tvInProgress.visibility             = View.GONE
        tvToRead.visibility                 = View.GONE

        rvBooksByOLID.visibility = View.GONE
        rvBooksSearched.visibility = View.VISIBLE

        etAdderBookTitleSearch.requestFocus()
        showKeyboard(etAdderBookTitleSearch, 350)

        setupRvBooksSearched()
        setupRvBooksByOLID()
        setupRvLanguages()

        frameLayout2.layoutParams.height = 0

        var job: Job? = null
//        etAdderBookTitleSearch.addTextChangedListener { editable ->

        btnSearchInOL.setOnClickListener {
            var editable = etAdderBookTitleSearch.text.toString()

            viewModel.booksByOLID.value = null
            viewModel.booksByOLIDFiltered.value = null

            var currentList = byOLIDBookAdapter.differ.currentList
            var newList = currentList.toList()
            newList = emptyList()

            byOLIDBookAdapter.differ.submitList(
                newList
            )

            job?.cancel()
            job = MainScope().launch {
                delay(Constants.OPEN_LIBRARY_SEARCH_DELAY)
                editable?.let {
                    if (editable.toString().isNotEmpty()) {
                        rvBooksByOLID.visibility = View.GONE
                        rvBooksSearched.visibility = View.VISIBLE
                        rvLanguages.visibility = View.VISIBLE
                        ivSeparator0.visibility = View.VISIBLE
                        frameLayout2.updateLayoutParams<ConstraintLayout.LayoutParams> {
                            topToBottom = ivSeparator0.id
                        }

                        if (editable.last().toString() == " ")
                            editable.dropLast(1)
                        viewModel.searchBooksInOpenLibrary(editable.toString())
                    }
                }
            }
        }

        viewModel.booksFromOpenLibrary.observe(viewLifecycleOwner, Observer { response ->
            when (response) {
                is Resource.Success -> {
                    hideProgressBar()

                    response.data?.let { booksResponse ->
                        var booksResponseCleaned: MutableList<OpenLibraryBook>? =
                            ArrayList<OpenLibraryBook>()

                        for (item in booksResponse.docs) {
                            if (item.title != null && item.author_name != null) {

                                booksResponseCleaned?.add(item)
                            }
                        }
                        searchedBookAdapter.differ.submitList(booksResponseCleaned)
                    }
                }
                is Resource.Error -> {
                    hideProgressBar()
                }
                is Resource.Loading -> {
                    showProgressBar()
                }
            }
        })

        searchedBookAdapter.setOnBookClickListener { curBook ->

            var willLanguageCounterBeUpdate = true

            view?.hideKeyboard()

            rvBooksSearched.visibility = View.GONE
            rvLanguages.visibility = View.GONE
            ivSeparator0.visibility = View.GONE
            rvBooksByOLID.visibility = View.VISIBLE

            frameLayout2.updateLayoutParams<ConstraintLayout.LayoutParams> {
                topToBottom = etAdderBookTitleSearch.id
            }

            viewModel.booksByOLID.value = null
            viewModel.booksByOLIDFiltered.value = null

            var currentList = byOLIDBookAdapter.differ.currentList
            var newList = currentList.toList()
            newList = emptyList()

            byOLIDBookAdapter.differ.submitList(
                newList
            )

            job?.cancel()
            job = MainScope().launch {
                var authorsName = ""
                for (author in curBook.author_name)
                    authorsName += author
                if (authorsName.last().toString() == ",")
                    authorsName.dropLast(1)
                viewModel.selectedAuthorsName = authorsName
                curBook.isbn?.let {
                    for (isbn in it)
                        viewModel.getBooksByOLID(isbn)
                }
            }

            viewModel.getLanguages().observe(viewLifecycleOwner, Observer { languages ->

                if (willLanguageCounterBeUpdate) {
                    willLanguageCounterBeUpdate = false

                    for (language in languages) {
                        if (language.isSelected == 1) {
                            val currentCounter = language.selectCounter
                            if (currentCounter != null)
                                viewModel.updateCounter(language.id, currentCounter + 1)
                            else
                                viewModel.updateCounter(language.id, 1)

                            lifecycleScope.launch {
                                delay(100L)
                                rvLanguages.scrollToPosition(0)
                            }
                        }
                    }
                }
            }
            )

        }


        viewModel.booksByOLID.observe(viewLifecycleOwner, Observer { response ->

            if (response != null) {
                when (response) {
                    is Resource.Success -> {
                        hideProgressBar()

                        response.data?.let { booksResponse ->


                            lifecycleScope.launch(Dispatchers.IO) {
                                val selectedLanguages = viewModel.getSelectedLanguages()

                                if (booksResponse != null) {

                                    if (booksResponse.languages != null) {

                                        if (selectedLanguages.isNotEmpty()) {

                                            for (language in selectedLanguages) {
                                                if (booksResponse.languages[0].key.replace(
                                                        "/languages/",
                                                        ""
                                                    ) == language.language6392B
                                                ) {
                                                    viewModel.booksByOLIDFiltered.postValue(
                                                        booksResponse
                                                    )
                                                }
                                            }

                                        } else {
                                            viewModel.booksByOLIDFiltered.postValue(booksResponse)
                                        }


                                    }
                                }

                            }
                        }
                    }

                    is Resource.Error -> {
                        hideProgressBar()
                        response.message?.let { message ->
                            Snackbar.make(view, "An error occurred: $message", Snackbar.LENGTH_SHORT)
                                .show()
                        }
                    }
                    is Resource.Loading -> {
                        showProgressBar()
                    }
                }
            }
        })


        viewModel.booksByOLIDFiltered.observe(viewLifecycleOwner, Observer { response ->
                            if (response != null) {
                                hideProgressBar()

                                    lifecycleScope.launch {
                                        var currentList = byOLIDBookAdapter.differ.currentList
                                        var newList = currentList.toList()

                                        if (response.number_of_pages > 0) {
                                            if (currentList.isNotEmpty()) {
                                                var add = true

                                                for (item in currentList) {
                                                    if (item.isbn_10 != null && response.isbn_10 != null) {
                                                        if (item.isbn_10[0] == response.isbn_10[0])
                                                            add = false
                                                    }

                                                    if (item.isbn_13 != null && response.isbn_13 != null) {
                                                        if (item.isbn_13[0] == response.isbn_13[0]) {
                                                            add = false
                                                        }
                                                    }

                                                    if (item.covers != null && response.covers != null) {
                                                        if (item.covers[0] == response.covers[0]) {
                                                            add = false
                                                        }
                                                    }
                                                }

                                                if (add) {
                                                    newList += response
                                                    byOLIDBookAdapter.differ.submitList(
                                                        newList
                                                    )
                                                    byOLIDBookAdapter.notifyDataSetChanged()
                                                }
                                            } else {
                                                newList += response
                                                byOLIDBookAdapter.differ.submitList(
                                                    newList
                                                )
                                                byOLIDBookAdapter.notifyDataSetChanged()
                                            }
                                        }
                                    }

                                    byOLIDBookAdapter.selectedAuthorsName =
                                        viewModel.selectedAuthorsName
                                    hideProgressBar()
                            }
        })

        viewModel.getLanguages().observe(viewLifecycleOwner, Observer { languages ->
            languageAdapter.differ.submitList(languages)})

        ivBookStatusRead.setOnClickListener {
            ivBookStatusRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            ivBookStatusInProgress.setColorFilter(
                ContextCompat.getColor(
                    view.context,
                    R.color.grey
                ), android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusToRead.setColorFilter(
                ContextCompat.getColor(view.context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            whatIsClicked = Constants.BOOK_STATUS_READ
            rbRating.visibility = View.VISIBLE
//            etPagesNumber.visibility = View.VISIBLE
            btnSetFinishDate.visibility = View.VISIBLE
            it.hideKeyboard()
        }

        ivBookStatusInProgress.setOnClickListener {
            ivBookStatusRead.setColorFilter(
                ContextCompat.getColor(view.context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusInProgress.setColorFilter(
                accentColor,
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusToRead.setColorFilter(
                ContextCompat.getColor(view.context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            whatIsClicked = Constants.BOOK_STATUS_IN_PROGRESS
            rbRating.visibility = View.GONE
//            etEditedPagesNumber.visibility = View.GONE
            btnSetFinishDate.visibility = View.GONE
            it.hideKeyboard()
        }

        ivBookStatusToRead.setOnClickListener {
            ivBookStatusRead.setColorFilter(
                ContextCompat.getColor(view.context, R.color.grey),
                android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusInProgress.setColorFilter(
                ContextCompat.getColor(
                    view.context,
                    R.color.grey
                ), android.graphics.PorterDuff.Mode.SRC_IN
            )
            ivBookStatusToRead.setColorFilter(accentColor, android.graphics.PorterDuff.Mode.SRC_IN)
            whatIsClicked = Constants.BOOK_STATUS_TO_READ
            rbRating.visibility = View.GONE
//            etEditedPagesNumber.visibility = View.GONE
            btnSetFinishDate.visibility = View.GONE
            it.hideKeyboard()
        }

        btnSetFinishDate.setOnClickListener {
            it.hideKeyboard()

            dpBookFinishDate.visibility = View.VISIBLE
            btnSaveFinishDate.visibility = View.VISIBLE
            btnCancelFinishDate.visibility = View.VISIBLE
            btnSaveFinishDate.isClickable = true
            btnCancelFinishDate.isClickable = true

            etAdderBookTitleSearch.visibility = View.GONE
            rvBooksSearched.visibility = View.GONE

            ivBookStatusRead.visibility = View.GONE
            ivBookStatusInProgress.visibility = View.GONE
            ivBookStatusToRead.visibility = View.GONE
            tvFinished.visibility = View.GONE
            tvInProgress.visibility = View.GONE
            tvToRead.visibility = View.GONE

//            etPagesNumber.visibility = View.GONE
            rbRating.visibility = View.GONE
            btnSetFinishDate.visibility = View.GONE
            fabAddNewBook.visibility = View.GONE
            fabCancelAddingNewBook.visibility = View.GONE
        }

        btnSaveFinishDate.setOnClickListener {
            bookFinishDateMs = getDateFromDatePickerInMillis(dpBookFinishDate)

            dpBookFinishDate.visibility = View.GONE
            btnSaveFinishDate.visibility = View.GONE
            btnCancelFinishDate.visibility = View.GONE
            btnSaveFinishDate.isClickable = false
            btnCancelFinishDate.isClickable = false

            etAdderBookTitleSearch.visibility = View.VISIBLE
            rvBooksSearched.visibility = View.VISIBLE

            ivBookStatusRead.visibility = View.VISIBLE
            ivBookStatusInProgress.visibility = View.VISIBLE
            ivBookStatusToRead.visibility = View.VISIBLE
            tvFinished.visibility = View.VISIBLE
            tvInProgress.visibility = View.VISIBLE
            tvToRead.visibility = View.VISIBLE

//            etPagesNumber.visibility = View.VISIBLE
            rbRating.visibility = View.VISIBLE
            btnSetFinishDate.visibility = View.VISIBLE
            fabAddNewBook.visibility = View.VISIBLE
            fabCancelAddingNewBook.visibility = View.VISIBLE

            btnSetFinishDate.text = bookFinishDateMs?.let { it1 -> convertLongToTime(it1) }
        }

        btnCancelFinishDate.setOnClickListener {
            dpBookFinishDate.visibility = View.GONE
            btnSaveFinishDate.visibility = View.GONE
            btnCancelFinishDate.visibility = View.GONE
            btnSaveFinishDate.isClickable = false
            btnCancelFinishDate.isClickable = false

            etAdderBookTitleSearch.visibility = View.VISIBLE
            rvBooksSearched.visibility = View.VISIBLE

            ivBookStatusRead.visibility = View.VISIBLE
            ivBookStatusInProgress.visibility = View.VISIBLE
            ivBookStatusToRead.visibility = View.VISIBLE
            tvFinished.visibility = View.VISIBLE
            tvInProgress.visibility = View.VISIBLE
            tvToRead.visibility = View.VISIBLE

//            etPagesNumber.visibility = View.VISIBLE
            rbRating.visibility = View.VISIBLE
            btnSetFinishDate.visibility = View.VISIBLE
            fabAddNewBook.visibility = View.VISIBLE
            fabCancelAddingNewBook.visibility = View.VISIBLE
        }

//        fabSaveEditedBook.setOnClickListener {
//            val bookTitle = etEditedBookTitle.text.toString()
//            val bookAuthor = etEditedBookAuthor.text.toString()
//            var bookRating = 0.0F
//            val bookNumberOfPagesIntOrNull = etEditedPagesNumber.text.toString().toIntOrNull()
//            var bookNumberOfPagesInt: Int
//
//            if (bookTitle.isNotEmpty()) {
//                if (bookAuthor.isNotEmpty()) {
//                    if (whatIsClicked != Constants.BOOK_STATUS_NOTHING) {
//                        if (bookNumberOfPagesIntOrNull != null || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS || whatIsClicked == Constants.BOOK_STATUS_TO_READ) {
//                            bookNumberOfPagesInt = when (bookNumberOfPagesIntOrNull) {
//                                null -> 0
//                                else -> bookNumberOfPagesIntOrNull
//                            }
//                            if (bookNumberOfPagesInt > 0 || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS || whatIsClicked == Constants.BOOK_STATUS_TO_READ) {
//                                if (bookFinishDateMs!=null || whatIsClicked == Constants.BOOK_STATUS_IN_PROGRESS || whatIsClicked == Constants.BOOK_STATUS_TO_READ) {
//                                    when (whatIsClicked) {
//                                        Constants.BOOK_STATUS_READ -> bookRating = rbEditedRating.rating
//                                        Constants.BOOK_STATUS_IN_PROGRESS -> bookRating = 0.0F
//                                        Constants.BOOK_STATUS_TO_READ -> bookRating = 0.0F
//                                    }
//
//                                    val REGEX_UNACCENT = "\\p{InCombiningDiacriticalMarks}+".toRegex()
//                                    fun CharSequence.unaccent(): String {
//                                        val temp = Normalizer.normalize(this, Normalizer.Form.NFD)
//                                        return REGEX_UNACCENT.replace(temp, "")
//                                    }
//
//                                    val bookStatus = whatIsClicked
//                                    viewModel.updateBook(
//                                        book.id,
//                                        bookTitle,
//                                        bookAuthor,
//                                        bookRating,
//                                        bookStatus,
//                                        bookFinishDateMs.toString(),
//                                        bookNumberOfPagesInt,
//                                        bookTitle_ASCII = bookTitle.unaccent().replace("ł", "l", false),
//                                        bookAuthor_ASCII = bookAuthor.unaccent().replace("ł", "l", false),
//                                        false
//                                    )
//
////                                    Snackbar.make(it, R.string.savingChanges, Snackbar.LENGTH_SHORT).show()
//                                    recalculateChallenges()
//
//                                    } else {
//                                    Snackbar.make(it, R.string.sbWarningMissingFinishDate, Snackbar.LENGTH_SHORT).show()
//                                }
//                            } else {
//                                Snackbar.make(it, R.string.sbWarningPages0, Snackbar.LENGTH_SHORT)
//                                    .show()
//                            }
//                        } else {
//                            Snackbar.make(it, R.string.sbWarningPagesMissing, Snackbar.LENGTH_SHORT)
//                                .show()
//                        }
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

    private fun setupRvBooksSearched() {
        searchedBookAdapter = SearchedBookAdapter()

        rvBooksSearched.apply {
            adapter = searchedBookAdapter
            layoutManager = LinearLayoutManager(context)
        }

        // bounce effect on the recyclerview
        OverScrollDecoratorHelper.setUpOverScroll(
            rvBooksSearched,
            OverScrollDecoratorHelper.ORIENTATION_VERTICAL
        )
    }

    private fun setupRvBooksByOLID() {
        byOLIDBookAdapter = ByOLIDBookAdapter()

        rvBooksByOLID.apply {
            adapter = byOLIDBookAdapter
            layoutManager = LinearLayoutManager(context)
        }

        // bounce effect on the recyclerview
        OverScrollDecoratorHelper.setUpOverScroll(
            rvBooksByOLID,
            OverScrollDecoratorHelper.ORIENTATION_VERTICAL
        )
    }

    private fun setupRvLanguages() {
        languageAdapter = LanguageAdapter(this)

        rvLanguages.apply {
            adapter = languageAdapter
            layoutManager = LinearLayoutManager(context)
        }
    }

    private fun hideProgressBar() {
        paginationProgressBar.visibility = View.INVISIBLE
    }

    private fun showProgressBar() {
        paginationProgressBar.visibility = View.VISIBLE
    }

    fun View.hideKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun View.showKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.toggleSoftInputFromWindow(windowToken, 0, 0)
    }

    fun showKeyboard(et: EditText, delay: Long) {
        val timer = Timer()
        timer.schedule(object : TimerTask() {
            override fun run() {
                val inputManager =
                    context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
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

        val sharedPref = (activity as ListActivity).getSharedPreferences(
            Constants.SHARED_PREFERENCES_NAME,
            Context.MODE_PRIVATE
        )

        var accent = sharedPref.getString(
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

    fun convertLongToYear(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("yyyy")
        return format.format(date)
    }

    private fun recalculateChallenges() {
        viewModel.getSortedBooksByDateDesc(Constants.BOOK_STATUS_READ)
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
            delay(500L)
            view?.hideKeyboard()
            findNavController().popBackStack()
            findNavController().popBackStack()
        }
    }
}
