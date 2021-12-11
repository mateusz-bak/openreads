package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
import android.widget.Toast
import androidx.constraintlayout.widget.ConstraintLayout
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.ListActivity
import kotlinx.android.synthetic.main.fragment_add_book_search.*
import software.mdev.bookstracker.other.Constants
import java.text.SimpleDateFormat
import java.util.*
import androidx.lifecycle.Observer
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.coroutines.*
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import software.mdev.bookstracker.adapters.*
import software.mdev.bookstracker.api.models.OpenLibraryBook
import software.mdev.bookstracker.api.models.OpenLibraryOLIDResponse
import software.mdev.bookstracker.data.db.entities.Language
import software.mdev.bookstracker.other.Resource
import software.mdev.bookstracker.ui.bookslist.dialogs.*
import kotlin.collections.ArrayList
import android.view.inputmethod.EditorInfo
import android.widget.TextView
import android.widget.TextView.OnEditorActionListener


class AddBookSearchFragment : Fragment(R.layout.fragment_add_book_search) {

    lateinit var viewModel: BooksViewModel
    lateinit var foundBooksAdapter: FoundBookAdapter
    lateinit var languageAdapter: LanguageAdapter

    lateinit var book: Book
    lateinit var listActivity: ListActivity

    private var searchQueryJob: Job? = null
    private var searchQueryAutoJob: Job? = null
    private var searchByOLIDJob: Job? = null
    private var searchAuthorJob: Job? = null
    private var hideProgressBarJob: Job? = null
    private var filterBooksByLanguage: Job? = null

    private val args: AddBookSearchFragmentArgs by navArgs()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val isbn = args.isbn

        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        rvLanguages.visibility = View.GONE

        if (isbn == "manual_search") {
            etAdderBookTitleSearch.requestFocus()
            showKeyboard(etAdderBookTitleSearch, 250)
        } else {
            etAdderBookTitleSearch.setText(isbn)

            searchQueryJob?.cancel()
            searchQueryAutoJob?.cancel()
            searchByOLIDJob?.cancel()
            searchAuthorJob?.cancel()
            var editable = etAdderBookTitleSearch.text.toString()

            viewModel.openLibrarySearchResult.value = null
            viewModel.openLibraryBooksByOLID.value = null

            searchQueryJob?.cancel()
            searchQueryAutoJob?.cancel()
            searchByOLIDJob?.cancel()
            searchAuthorJob?.cancel()

            searchQueryJob = MainScope().launch {

                editable?.let {
                    if (editable.isNotEmpty()) {
                        if (editable.last().toString() == " ")
                            editable.dropLast(1)
                        viewModel.searchBooksInOpenLibrary(editable, context)
                    }
                }
            }
        }

        setupRvLanguages()
        setupRvFoundBooks()

        if (sharedPref.getBoolean(Constants.SHARED_PREFERENCES_KEY_SHOW_OL_ALERT, true)
            && isbn == "manual_search") {
            AlertDialog(
                view,
                object : AlertDialogListener {
                    override fun onOkButtonClicked(isChecked: Boolean) {
                        if (isChecked) {
                            editor.apply {
                                putBoolean(Constants.SHARED_PREFERENCES_KEY_SHOW_OL_ALERT, false)
                                apply()
                            }
                        }

                        etAdderBookTitleSearch.requestFocus()
                        showKeyboard(etAdderBookTitleSearch, 100)
                    }
                }, activity as ListActivity
            ).show()
        }

        ivClearTitleSearch.visibility = View.GONE

        etAdderBookTitleSearch.addTextChangedListener { editable ->
            editable?.let {
                if (it.isNotEmpty())
                    ivClearTitleSearch.visibility = View.VISIBLE
                else
                    ivClearTitleSearch.visibility = View.GONE
            }
        }

        ivClearTitleSearch.setOnClickListener {
            etAdderBookTitleSearch.setText(Constants.EMPTY_STRING)
            ivClearTitleSearch.visibility = View.GONE

            etAdderBookTitleSearch.requestFocus()
            showKeyboard(etAdderBookTitleSearch, 50)
        }

        btnFilterLanguage.setOnClickListener {
            if (rvLanguages.visibility == View.GONE) {
                rvLanguages.visibility = View.VISIBLE
                rvLanguages.scrollToPosition(0)

                val currentLayout = frameLayout2.layoutParams as ConstraintLayout.LayoutParams
                currentLayout.topToBottom = R.id.frLanguages
                frameLayout2.layoutParams = currentLayout
            }
            else {
                rvLanguages.visibility = View.GONE

                val currentLayout = frameLayout2.layoutParams as ConstraintLayout.LayoutParams

                currentLayout.topToBottom = R.id.btnFilterLanguage
                frameLayout2.layoutParams = currentLayout
            }
        }

        etAdderBookTitleSearch.addTextChangedListener { editable ->
            searchQueryJob?.cancel()
            searchQueryAutoJob?.cancel()
            searchByOLIDJob?.cancel()
            searchAuthorJob?.cancel()

            viewModel.openLibrarySearchResult.value = null
            viewModel.openLibraryBooksByOLID.value = null

            searchQueryJob?.cancel()
            searchQueryAutoJob?.cancel()
            searchByOLIDJob?.cancel()
            searchAuthorJob?.cancel()

            searchQueryAutoJob = MainScope().launch {
                delay(500L)

                editable?.let {
                    if (it.isNotEmpty()) {
                        var searchQuery = it.toString()

                        if (searchQuery.last().toString() == " ")
                            searchQuery = searchQuery.dropLast(1)

                        viewModel.searchBooksInOpenLibrary(searchQuery, context)
                    }
                }
            }
        }

        btnSearchInOL.setOnClickListener {
            it.hideKeyboard()

            searchQueryJob?.cancel()
            searchQueryAutoJob?.cancel()
            searchByOLIDJob?.cancel()
            searchAuthorJob?.cancel()
            var editable = etAdderBookTitleSearch.text.toString()

            viewModel.openLibrarySearchResult.value = null
            viewModel.openLibraryBooksByOLID.value = null

            searchQueryJob?.cancel()
            searchQueryAutoJob?.cancel()
            searchByOLIDJob?.cancel()
            searchAuthorJob?.cancel()

            searchQueryJob = MainScope().launch {

                editable?.let {
                    if (editable.isNotEmpty()) {
                        if (editable.last().toString() == " ")
                            editable.dropLast(1)
                        viewModel.searchBooksInOpenLibrary(editable, context)
                    }
                }
            }
        }

        viewModel.openLibrarySearchResult.observe(viewLifecycleOwner, Observer { response ->
            when (response) {
                is Resource.Success -> {
                    response.data?.let { booksResponse ->
                        var booksResponseCleaned: MutableList<OpenLibraryBook>? =
                            ArrayList<OpenLibraryBook>()

                        for (item in booksResponse.docs) {
                            if (item.title != null || item.author_name != null) {
                                booksResponseCleaned?.add(item)
                            }
                        }

                        if (booksResponseCleaned != null) {
                            if (booksResponseCleaned.isNotEmpty()) {
                                searchByOLIDJob =
                                    viewModel.getBooksByOLID(booksResponseCleaned, context)
                            } else {
                                Toast.makeText(context?.applicationContext, R.string.toast_no_results_from_OL, Toast.LENGTH_SHORT).show()
                            }
                        }
                    }
                }
                is Resource.Error -> {
                }
                is Resource.Loading -> {
                }
            }
        })

        viewModel.getLanguages().observe(viewLifecycleOwner, Observer { languages ->
            var newList: List<Language> = emptyList()

            for (language in languages) {
                if (language.isSelected == 1) {
                    newList += language
                }
            }

            viewModel.selectedLanguages.postValue(newList)

            var selectedLanguages = newList.size
            if (selectedLanguages == 0) {
                btnFilterLanguage.text = getString(R.string.button_language)
            } else {
                var buttonText = getString(R.string.button_language) + " (" + selectedLanguages.toString() + ")"
                btnFilterLanguage.text = buttonText
            }

        })

        var currentSelectedLanguages: List<Language>? = null

        viewModel.selectedLanguages.observe(viewLifecycleOwner, Observer { languages ->

            if (currentSelectedLanguages != null) {

                if (currentSelectedLanguages?.size != languages.size) {

                    if (languages != null) {
                        for (selectedLanguage in languages) {
                            var oldCounter = selectedLanguage.selectCounter

                            if (oldCounter == null)
                                viewModel.updateCounter(selectedLanguage.id, 1)
                            else
                                viewModel.updateCounter(selectedLanguage.id, oldCounter + 1)
                        }
                    }

                    currentSelectedLanguages = languages
                }
            } else {
                currentSelectedLanguages = languages
            }
        })

        viewModel.openLibraryBooksByOLID.observe(viewLifecycleOwner, Observer { list ->

            viewModel.selectedLanguages.observe(viewLifecycleOwner, Observer { languages ->

                filterBooksByLanguage?.cancel()
                filterBooksByLanguage = MainScope().launch {
                    var newList: List<Resource<OpenLibraryOLIDResponse>> = emptyList()

                    if (list != null) {
                        for (item in list) {
                            if (item.data != null) {
                                if (item.data.title != null) {

                                    var add = false
                                    if (languages.isNotEmpty()) {

                                        if (item.data.languages != null) {

                                            for (language in languages) {

                                                if (language.isSelected == 1) {

                                                    for (itemLanguage in item.data.languages) {

                                                        if (language.language6392B == itemLanguage.key.replace(
                                                                "/languages/",
                                                                ""
                                                            )
                                                        ) {
                                                            add = true
                                                        }
                                                    }
                                                } else {
                                                    add = true
                                                }
                                            }
                                        }
                                    } else {
                                        add = true
                                    }

                                    for (currentItem in newList) {
                                        if (currentItem.data?.key == item.data.key)
                                            add = false
                                    }

                                    if (add)
                                        newList += item
                                }
                            }
                        }
                    }

                    foundBooksAdapter.differ.submitList(
                        newList
                    )

                    var numberOfFilteredBooks = newList.size

                    when (numberOfFilteredBooks) {
                        0 -> tvResultsNumber.text = ""
                        1 -> tvResultsNumber.text = "1 " + getString(R.string.results_1)
                        2 -> tvResultsNumber.text = "2 " + getString(R.string.results_2_4)
                        3 -> tvResultsNumber.text = "3 " + getString(R.string.results_2_4)
                        4 -> tvResultsNumber.text = "4 " + getString(R.string.results_2_4)
                        else -> tvResultsNumber.text = newList.size.toString() + " " + getString(R.string.results_5_)
                    }
                }
            })
        })

        viewModel.getLanguages().observe(viewLifecycleOwner, Observer { languages ->
            languageAdapter.differ.submitList(languages)
        })

        viewModel.showLoadingCircle.observe(viewLifecycleOwner, Observer { bool ->
            if (bool) {
                hideProgressBarJob?.cancel()
                showProgressBar()
            }
            else {
                hideProgressBarJob?.cancel()
                hideProgressBarJob = MainScope().launch {
                    delay(500L)
                    if (isActive) {
                        hideProgressBar()
                    }
                }
            }
        })

        foundBooksAdapter.setOnBookClickListener {
            goToAddFragment(it, isbn)
        }

        etAdderBookTitleSearch.setOnEditorActionListener(OnEditorActionListener { v, actionId, event ->
            if (actionId == EditorInfo.IME_ACTION_SEARCH) {
                performSearch(v)
                return@OnEditorActionListener true
            }
            false
        })
    }

    private fun goToAddFragment(resource: Resource<OpenLibraryOLIDResponse>, isbn: String) {
        if (resource.data != null) {
            var bookTitle = ""
            var bookAuthor = ""
            var bookPages = 0
            var bookPublishYear = 0
            var bookISBN = ""
            var bookOLID = ""
            var bookCoverUrl = ""

            if (resource.data!!.title != null)
                bookTitle = resource.data!!.title

            if (resource.data!!.authors != null)
                bookAuthor = resource.data!!.authors[0].key

            if (resource.data!!.number_of_pages != null)
                bookPages = resource.data!!.number_of_pages

            if (resource.data!!.publish_date != null)
                bookPublishYear = getYearFromPublishDate(resource.data!!.publish_date)

            if (resource.data!!.isbn_13 != null) {
                bookISBN = resource.data!!.isbn_13.toString()
                bookISBN = bookISBN.replace("[", "")
            }

            if (resource.data!!.key != null) {
                bookOLID = resource.data!!.key
                bookOLID = bookOLID.replace("/books/", "")
            }

            if (resource.data!!.covers != null)
                bookCoverUrl = resource.data!!.covers[0].toString()

            var book = Book(bookTitle, bookAuthor)
            book.bookNumberOfPages = bookPages
            book.bookPublishYear = bookPublishYear
            book.bookISBN13 = bookISBN
            book.bookOLID = bookOLID
            book.bookCoverUrl = bookCoverUrl

            Constants.SERIALIZABLE_BUNDLE_ISBN_DEFAULT

            var bookSource = Constants.FROM_SEARCH
            if (isbn != Constants.SERIALIZABLE_BUNDLE_ISBN_DEFAULT)
                bookSource = Constants.FROM_SCAN

            val addEditBookDialog = AddEditBookDialog()

            if (addEditBookDialog != null ) {
                addEditBookDialog!!.arguments = Bundle().apply {
                    putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, book)
                    putSerializable(
                        Constants.SERIALIZABLE_BUNDLE_BOOK_SOURCE,
                        bookSource
                    )
                }
                addEditBookDialog!!.show(childFragmentManager, AddEditBookDialog.TAG)
            }
        }
    }

    private fun getYearFromPublishDate(publishDate: String): Int {
        var publishYear = 0

        val numbers = Regex("[0-9]+").findAll(publishDate)
            .map(MatchResult::value)
            .toList()

        for (i in numbers) {
            if (i.length == 4)
                publishYear = i.toInt()
        }

        return publishYear
    }

    private fun performSearch(v: TextView) {
        v.hideKeyboard()

        searchQueryJob?.cancel()
        searchQueryAutoJob?.cancel()
        searchByOLIDJob?.cancel()
        searchAuthorJob?.cancel()
        var editable = etAdderBookTitleSearch.text.toString()

        viewModel.openLibrarySearchResult.value = null
        viewModel.openLibraryBooksByOLID.value = null

        searchQueryJob?.cancel()
        searchQueryAutoJob?.cancel()
        searchByOLIDJob?.cancel()
        searchAuthorJob?.cancel()

        searchQueryJob = MainScope().launch {

            editable?.let {
                if (editable.isNotEmpty()) {
                    if (editable.last().toString() == " ")
                        editable.dropLast(1)
                    viewModel.searchBooksInOpenLibrary(editable, context)
                }
            }
        }
    }

    override fun onDestroyView() {
        super.onDestroyView()
        searchQueryJob?.cancel()
        searchQueryAutoJob?.cancel()
        searchByOLIDJob?.cancel()
        searchAuthorJob?.cancel()
        hideProgressBarJob?.cancel()
        filterBooksByLanguage?.cancel()
    }

    private fun setupRvFoundBooks() {
        foundBooksAdapter = FoundBookAdapter(viewModel)

        rvFoundBooks.apply {
            adapter = foundBooksAdapter
            layoutManager = LinearLayoutManager(context)
        }

        // bounce effect on the recyclerview
        OverScrollDecoratorHelper.setUpOverScroll(
            rvFoundBooks,
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
        paginationProgressBar?.visibility = View.INVISIBLE
    }

    private fun showProgressBar() {
        paginationProgressBar?.visibility = View.VISIBLE
        paginationProgressBar.bringToFront()
    }

    fun View.hideKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    private fun showKeyboard(et: EditText, delay: Long) {
        val timer = Timer()
        timer.schedule(object : TimerTask() {
            override fun run() {
                val inputManager =
                    context?.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                inputManager.showSoftInput(et, 0)
            }
        }, delay)
    }

    private fun convertLongToYear(time: Long): String {
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
    }
}
