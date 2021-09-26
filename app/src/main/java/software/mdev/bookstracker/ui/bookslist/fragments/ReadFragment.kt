package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.animation.AnimationUtils
import android.view.inputmethod.InputMethodManager
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.activity_list.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.adapters.BookAdapter
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import kotlinx.android.synthetic.main.fragment_read.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Functions
import software.mdev.bookstracker.ui.bookslist.dialogs.*
import java.util.*


class ReadFragment : Fragment(R.layout.fragment_read) {

    lateinit var viewModel: BooksViewModel
    val currentFragment = Constants.BOOK_STATUS_READ
    val functions = Functions()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel

        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        etSearch.visibility = View.GONE
        ivClearSearch.visibility = View.GONE
        tvLooksEmpty.visibility = View.GONE
        btnAddManual.visibility = View.GONE
        btnAddSearch.visibility = View.GONE
        btnAddScan.visibility = View.GONE
        ivClearSearch.isClickable = false
        ivFilterBooks.isClickable = false
        btnAddManual.isClickable = false
        btnAddSearch.isClickable = false
        btnAddScan.isClickable = false
        view.hideKeyboard()

        val database = BooksDatabase(view.context)
        val yearDatabase = YearDatabase(view.context)
        val languageDatabase = LanguageDatabase(view.context)

        val booksRepository = BooksRepository(database)
        val yearRepository = YearRepository(yearDatabase)
        val openLibraryRepository = OpenLibraryRepository()
        val languageRepository = LanguageRepository(languageDatabase)

        val booksViewModelProviderFactory = BooksViewModelProviderFactory(
            booksRepository,
            yearRepository,
            openLibraryRepository,
            languageRepository
        )

        viewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

        val viewModel = ViewModelProviders.of(this, booksViewModelProviderFactory).get(BooksViewModel::class.java)

        val bookAdapter = BookAdapter(view.context, whichFragment = currentFragment)

        rvBooks.adapter = bookAdapter
        rvBooks.layoutManager = LinearLayoutManager(view.context)

        // bounce effect on the recyclerview
        OverScrollDecoratorHelper.setUpOverScroll(rvBooks, OverScrollDecoratorHelper.ORIENTATION_VERTICAL)

        this.getBooks(bookAdapter)

        viewModel.getBookCount(currentFragment).observe(viewLifecycleOwner, Observer {
                count ->
            run {
                when(count.toInt()) {
                    0 -> tvLooksEmpty.visibility = View.VISIBLE
                    else -> tvLooksEmpty.visibility = View.GONE
                }
            }
        })

        btnAddManual.setOnClickListener{
            hideAddOptionButtons()

            AddBookDialog(view.context,
                object: AddBookDialogListener {
                    override fun onSaveButtonClicked(item: Book) {
                        viewModel.upsert(item)
                        recalculateChallenges()
                        when(item.bookStatus) {
                            Constants.BOOK_STATUS_IN_PROGRESS -> { findNavController().navigate(
                                R.id.action_readFragment_to_inProgressFragment
                                )
                            }
                            Constants.BOOK_STATUS_TO_READ -> { findNavController().navigate(
                                R.id.action_readFragment_to_toReadFragment
                                )
                            }
                        }
                    }
                }
            ).show()
        }

        fabAddBook.setOnClickListener {
            if (btnAddManual.visibility == View.GONE) {
                showAddOptionButtons()
            }
            else {
                hideAddOptionButtons()
            }
        }

        btnAddSearch.setOnClickListener {
            hideAddOptionButtons()

            findNavController().navigate(
                R.id.action_readFragment_to_addBookSearchFragment)
        }

        btnAddScan.setOnClickListener {
            hideAddOptionButtons()

            if (Functions().checkPermission(activity as ListActivity, android.Manifest.permission.CAMERA)) {
                findNavController().navigate(R.id.action_readFragment_to_addBookScanFragment)
            } else {
                Functions().requestPermission(
                    activity as ListActivity,
                    android.Manifest.permission.CAMERA,
                    Constants.PERMISSION_CAMERA_FROM_LIST_1)
            }
        }

        rvBooks.setOnClickListener {
            btnAddManual.visibility = View.GONE
            btnAddSearch.visibility = View.GONE
            btnAddScan.visibility = View.GONE
            btnAddManual.isClickable = false
            btnAddSearch.isClickable = false
            btnAddScan.isClickable = false

            fabAddBook.animate().rotation( 0F).setDuration(350L).start()
        }

        ivSort.setOnClickListener{
            SortBooksDialog(view.context,
                object: SortBooksDialogListener {
                    override fun onSaveButtonClicked(sortOrder: String) {
                        editor.apply {
                            putString(Constants.SHARED_PREFERENCES_KEY_SORT_ORDER, sortOrder)
                            apply()
                        }
                        bookAdapter.notifyDataSetChanged()
                        getBooks(bookAdapter)
                        lifecycleScope.launch {
                            delay(250L)
                            rvBooks.scrollToPosition(0)
                        }
                    }
                }
            , sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_SORT_ORDER, Constants.SORT_ORDER_TITLE_ASC)).show()
        }

        ivFilterBooks.setOnClickListener{
            // changes variable to false when ivFilterBooks is clicked
            var willDialogBeShownAfterClick = true

            viewModel.getSortedBooksByFinishDateDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                var arrayOfYears = functions.calculateYearsFromDb(some_books)

                // checks variable whether dialog is called by user (true) or by some_books change (false)
                if (willDialogBeShownAfterClick) {
                    // changes variable to false so dialog won't be shown when not called by user
                    willDialogBeShownAfterClick = false

                    FilterBooksDialog(
                        view,
                        object : FilterBooksDialogListener {
                            override fun onSaveFilterButtonClicked() {
                                bookAdapter.notifyDataSetChanged()
                                getBooks(bookAdapter)
                                lifecycleScope.launch {
                                    delay(250L)
                                    rvBooks.scrollToPosition(0)
                                }
                            }
                        },
                        arrayOfYears,
                        activity as ListActivity
                    ).show()
                }
            })
        }

        bookAdapter.setOnBookClickListener {
            etSearch.setText(Constants.EMPTY_STRING)
            fabAddBook.visibility = View.GONE
            val bundle = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, it)
            }
            findNavController().navigate(
                R.id.action_readFragment_to_displayBookFragment,
                bundle
            )
        }

        ivSearch.setOnClickListener {
            when(etSearch.visibility) {
                View.VISIBLE -> {
                    when (etSearch.text.isEmpty()){
                        false -> {
                            viewModel.searchBooks(etSearch.text.toString()).observe(viewLifecycleOwner, Observer { some_books ->
                                bookAdapter.differ.submitList(some_books)
                            })
                        }
                    }
                }
                View.GONE -> {
                    etSearch.visibility = View.VISIBLE
                    ivClearSearch.visibility = View.VISIBLE
                    ivClearSearch.isClickable = true
                    etSearch.requestFocus()
                    it.showKeyboard()
                }
                View.INVISIBLE -> {
                    etSearch.visibility = View.VISIBLE
                    ivClearSearch.visibility = View.VISIBLE
                    ivClearSearch.isClickable = true
                    etSearch.requestFocus()
                    it.showKeyboard()
                }
            }
        }

        etSearch.setOnKeyListener(View.OnKeyListener { v, keyCode, event ->
            if (keyCode == KeyEvent.KEYCODE_ENTER && event.action == KeyEvent.ACTION_UP) {
                when (etSearch.text.isEmpty()){
                    false -> {
                        viewModel.searchBooks(etSearch.text.toString()).observe(viewLifecycleOwner, Observer { some_books ->
                            bookAdapter.differ.submitList(some_books)
                        })
                        view.hideKeyboard()
                    }
                }
                return@OnKeyListener true
            }
            false
        })

        etSearch.addTextChangedListener {
            if (etSearch.text.isNotEmpty()) {
                viewModel.searchBooks(etSearch.text.toString())
                    .observe(viewLifecycleOwner, Observer { some_books ->
                        bookAdapter.differ.submitList(some_books)
                    })
            }
        }

        ivClearSearch.setOnClickListener {
            when (etSearch.text.isEmpty()) {
                false -> {
                    etSearch.setText(Constants.EMPTY_STRING)
                    viewModel.searchBooks(etSearch.text.toString()).observe(viewLifecycleOwner, Observer { some_books ->
                        bookAdapter.differ.submitList(some_books)
                    })
                }
                true -> {
                    etSearch.visibility = View.GONE
                    ivClearSearch.visibility = View.GONE
                    ivClearSearch.isClickable = false
                    it.hideKeyboard()
                    getBooks(bookAdapter)
                }
            }
        }

        ivMore.setOnClickListener{
            it.hideKeyboard()
            findNavController().navigate(R.id.settingsFragment, null)
        }
    }

    private fun hideAddOptionButtons() {
        btnAddManual.visibility = View.GONE
        btnAddSearch.visibility = View.GONE
        btnAddScan.visibility = View.GONE
        btnAddManual.isClickable = false
        btnAddSearch.isClickable = false
        btnAddScan.isClickable = false

        fabAddBook.animate().rotation( 0F).setDuration(350L).start()
        btnAddSearch.startAnimation(AnimationUtils.loadAnimation(context,R.anim.slide_out_down))
        btnAddScan.startAnimation(AnimationUtils.loadAnimation(context,R.anim.slide_out_down))
        btnAddManual.startAnimation(AnimationUtils.loadAnimation(context,R.anim.slide_out_down))
    }

    private fun showAddOptionButtons() {
        btnAddManual.visibility = View.VISIBLE
        btnAddSearch.visibility = View.VISIBLE
        btnAddScan.visibility = View.VISIBLE
        btnAddManual.isClickable = true
        btnAddSearch.isClickable = true
        btnAddScan.isClickable = true

        fabAddBook.animate().rotation(180F).setDuration(350L).start()
        btnAddSearch.startAnimation(AnimationUtils.loadAnimation(context,R.anim.slide_in_up))
        btnAddScan.startAnimation(AnimationUtils.loadAnimation(context,R.anim.slide_in_up))
        btnAddManual.startAnimation(AnimationUtils.loadAnimation(context,R.anim.slide_in_up))
    }

    fun View.hideKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun View.showKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.toggleSoftInputFromWindow(windowToken, 0, 0)
    }

    fun getBooks(
        bookAdapter: BookAdapter) {
        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        when(sharedPref.getString(
            Constants.SHARED_PREFERENCES_KEY_SORT_ORDER,
            Constants.SORT_ORDER_TITLE_ASC
        )) {
            Constants.SORT_ORDER_TITLE_DESC -> viewModel.getSortedBooksByTitleDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_TITLE_ASC -> viewModel.getSortedBooksByTitleAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_AUTHOR_DESC -> viewModel.getSortedBooksByAuthorDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_AUTHOR_ASC -> viewModel.getSortedBooksByAuthorAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_RATING_DESC -> viewModel.getSortedBooksByRatingDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_RATING_ASC -> viewModel.getSortedBooksByRatingAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_PAGES_DESC -> viewModel.getSortedBooksByPagesDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_PAGES_ASC -> viewModel.getSortedBooksByPagesAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_START_DATE_DESC -> viewModel.getSortedBooksByStartDateDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_START_DATE_ASC -> viewModel.getSortedBooksByStartDateAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_FINISH_DATE_DESC -> viewModel.getSortedBooksByFinishDateDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })

            Constants.SORT_ORDER_FINISH_DATE_ASC -> viewModel.getSortedBooksByFinishDateAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                functions.filterBooksList(activity as ListActivity, bookAdapter, some_books)
            })
        }
    }

    fun recalculateChallenges() {
        viewModel.getSortedBooksByFinishDateDesc(Constants.BOOK_STATUS_READ)
            .observe(viewLifecycleOwner, Observer { books ->
                var year: Int
                var years = listOf<Int>()

                for (item in books) {
                    if (item.bookFinishDate != "null" && item.bookFinishDate != "none") {
                        year = functions.convertLongToYear(item.bookFinishDate.toLong()).toInt()
                        if (year !in years) {
                            years = years + year
                        }
                    }
                }

                for (item_year in years) {
                    var booksInYear = 0

                    for (item_book in books) {
                        if (item_book.bookFinishDate != "none" && item_book.bookFinishDate != "null") {
                            year = functions.convertLongToYear(item_book.bookFinishDate.toLong()).toInt()
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