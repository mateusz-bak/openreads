package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.animation.*
import android.view.inputmethod.InputMethodManager
import android.widget.EditText
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
import kotlinx.android.synthetic.main.fragment_to_read.*
import kotlinx.coroutines.MainScope
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


class ToReadFragment : Fragment(R.layout.fragment_to_read) {

    lateinit var viewModel: BooksViewModel
    val currentFragment = Constants.BOOK_STATUS_TO_READ
    val functions = Functions()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel

        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        etSearch.visibility = View.INVISIBLE
        ivClearSearch.visibility = View.GONE
        tvLooksEmpty.visibility = View.GONE
        btnAddManual.visibility = View.GONE
        btnAddSearch.visibility = View.GONE
        btnAddScan.visibility = View.GONE
        ivClearSearch.isClickable = false
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
            hideAddOptionButtons(false)

            var emptyBook = Book(
                "","",0F,"",
                "","","",
                0,"",
                "",true,
                "","",
                "","",0)


            val bundle = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, emptyBook)
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK_SOURCE, Constants.NO_SOURCE)
            }

            findNavController().navigate(
                R.id.action_toReadFragment_to_addEditBookFragment,
                bundle
            )
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
            hideAddOptionButtons(false)

            findNavController().navigate(
                R.id.action_toReadFragment_to_addBookSearchFragment)
        }

        btnAddScan.setOnClickListener {
            hideAddOptionButtons(false)

            if (Functions().checkPermission(activity as ListActivity, android.Manifest.permission.CAMERA)) {
                findNavController().navigate(R.id.action_toReadFragment_to_addBookScanFragment)
            } else {
                Functions().requestPermission(
                    activity as ListActivity,
                    android.Manifest.permission.CAMERA,
                    Constants.PERMISSION_CAMERA_FROM_LIST_3)
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

        bookAdapter.setOnBookClickListener {
            etSearch.setText(Constants.EMPTY_STRING)
            fabAddBook.visibility = View.GONE
            val bundle = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, it)
            }
            findNavController().navigate(
                R.id.action_toReadFragment_to_displayBookFragment,
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
                else -> {
                    var anim = ScaleAnimation(0.0f, 1.0f, 1.0f, 1.0f, Animation.RELATIVE_TO_SELF,0f, Animation.RELATIVE_TO_SELF, 0f)
                    anim.duration = 250L
                    etSearch.startAnimation(anim)

                    etSearch.visibility = View.VISIBLE

                    MainScope().launch {
                        delay(200L)
                        ivClearSearch.visibility = View.VISIBLE
                        ivClearSearch.isClickable = true
                    }

                    etSearch.requestFocus()
                    showKeyboard(etSearch, 150)
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
                    etSearch.requestFocus()
                    showKeyboard(etSearch, 50)

                    etSearch.setText(Constants.EMPTY_STRING)
                    viewModel.searchBooks(etSearch.text.toString()).observe(viewLifecycleOwner, Observer { some_books ->
                        bookAdapter.differ.submitList(some_books)
                    })
                }
                true -> {
                    etSearch.visibility = View.INVISIBLE
                    ivClearSearch.visibility = View.INVISIBLE
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

    private fun hideAddOptionButtons(animateHiding: Boolean = true) {
        btnAddManual.animate().translationY(500F).setDuration(500L).setInterpolator(AnticipateOvershootInterpolator()).start()
        btnAddSearch.animate().translationY(500F).setDuration(500L).setInterpolator(AnticipateOvershootInterpolator()).start()
        btnAddScan.animate().translationY(500F).setDuration(500L).setInterpolator(AnticipateOvershootInterpolator()).start()

        fabAddBook.animate().rotation( 0F).setDuration(500L).start()
        fabAddBook.animate().scaleX(0.8F).setDuration(250L).start()
        fabAddBook.animate().scaleY(0.8F).setDuration(250L).start()

        if (animateHiding) {
            MainScope().launch {
                delay(250)

                fabAddBook.animate().scaleX(1F).setDuration(250L).start()
                fabAddBook.animate().scaleY(1F).setDuration(250L).start()

                delay(250)
                btnAddManual.visibility = View.GONE
                btnAddSearch.visibility = View.GONE
                btnAddScan.visibility = View.GONE
                btnAddManual.isClickable = false
                btnAddSearch.isClickable = false
                btnAddScan.isClickable = false
            }
        } else {
            btnAddManual.visibility = View.GONE
            btnAddSearch.visibility = View.GONE
            btnAddScan.visibility = View.GONE
            btnAddManual.isClickable = false
            btnAddSearch.isClickable = false
            btnAddScan.isClickable = false
        }
    }

    private fun showAddOptionButtons() {
        btnAddManual.translationY = 500F
        btnAddSearch.translationY = 500F
        btnAddScan.translationY = 500F

        btnAddManual.visibility = View.VISIBLE
        btnAddSearch.visibility = View.VISIBLE
        btnAddScan.visibility = View.VISIBLE

        btnAddManual.isClickable = true
        btnAddSearch.isClickable = true
        btnAddScan.isClickable = true

        fabAddBook.animate().rotation(180F).setDuration(500L).start()
        fabAddBook.animate().scaleX(0.8F).setDuration(250L).start()
        fabAddBook.animate().scaleY(0.8F).setDuration(250L).start()

        btnAddManual.animate().translationY(0F).setDuration(500L).setInterpolator(AnticipateOvershootInterpolator()).start()
        btnAddSearch.animate().translationY(0F).setDuration(500L).setInterpolator(AnticipateOvershootInterpolator()).start()
        btnAddScan.animate().translationY(0F).setDuration(500L).setInterpolator(AnticipateOvershootInterpolator()).start()

        MainScope().launch {
            delay(250)

            fabAddBook.animate().scaleX(1F).setDuration(250L).start()
            fabAddBook.animate().scaleY(1F).setDuration(250L).start()

            delay(250)

            btnAddManual.visibility = View.VISIBLE
            btnAddSearch.visibility = View.VISIBLE
            btnAddScan.visibility = View.VISIBLE

            btnAddManual.isClickable = true
            btnAddSearch.isClickable = true
            btnAddScan.isClickable = true
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

    private fun getBooks(bookAdapter: BookAdapter) {
        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        when(sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_SORT_ORDER, Constants.SORT_ORDER_TITLE_ASC)) {
            Constants.SORT_ORDER_TITLE_DESC -> viewModel.getSortedBooksByTitleDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })

            Constants.SORT_ORDER_AUTHOR_DESC -> viewModel.getSortedBooksByAuthorDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })

            Constants.SORT_ORDER_AUTHOR_ASC -> viewModel.getSortedBooksByAuthorAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })

            else -> viewModel.getSortedBooksByTitleAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })
        }
    }

    private fun recalculateChallenges() {
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
}