package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.KeyEvent
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.core.widget.addTextChangedListener
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import androidx.lifecycle.lifecycleScope
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import software.mdev.bookstracker.R
import software.mdev.bookstracker.adapters.BookAdapter
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import software.mdev.bookstracker.ui.bookslist.dialogs.AddBookDialog
import software.mdev.bookstracker.ui.bookslist.dialogs.AddBookDialogListener
import software.mdev.bookstracker.ui.bookslist.dialogs.SortBooksDialog
import software.mdev.bookstracker.ui.bookslist.dialogs.SortBooksDialogListener
import kotlinx.android.synthetic.main.fragment_in_progress.*
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_IN_PROGRESS
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_READ
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_TO_READ
import software.mdev.bookstracker.other.Constants.EMPTY_STRING
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_KEY_SORT_ORDER
import software.mdev.bookstracker.other.Constants.SERIALIZABLE_BUNDLE_BOOK
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_NAME
import software.mdev.bookstracker.other.Constants.SORT_ORDER_AUTHOR_ASC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_AUTHOR_DESC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_PAGES_ASC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_PAGES_DESC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_RATING_ASC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_RATING_DESC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_TITLE_ASC
import software.mdev.bookstracker.other.Constants.SORT_ORDER_TITLE_DESC


class InProgressFragment : Fragment(R.layout.fragment_in_progress) {

    lateinit var viewModel: BooksViewModel
    val currentFragment = BOOK_STATUS_IN_PROGRESS

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel

        val sharedPref = (activity as ListActivity).getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        etSearch.visibility = View.GONE
        ivClearSearch.visibility = View.GONE
        ivClearSearch.isClickable = false
        view.hideKeyboard()

        val database = BooksDatabase(view.context)
        val booksRepository = BooksRepository(database)
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)

        viewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

        val factory = BooksViewModelProviderFactory(booksRepository)
        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        val bookAdapter = BookAdapter(view.context, whichFragment = currentFragment)

        rvBooks.adapter = bookAdapter
        rvBooks.layoutManager = LinearLayoutManager(view.context)

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

        fabAddBook.setOnClickListener{
            AddBookDialog(view.context,
                object: AddBookDialogListener {
                    override fun onSaveButtonClicked(item: Book) {
                        viewModel.upsert(item)
                        when(item.bookStatus) {
                            BOOK_STATUS_READ -> { findNavController().navigate(
                                R.id.action_inProgressFragment_to_readFragment
                            )
                            }
                            BOOK_STATUS_TO_READ -> { findNavController().navigate(
                                R.id.action_inProgressFragment_to_toReadFragment
                            )
                            }
                        }
                    }
                }
            ).show()
        }

        ivSort.setOnClickListener{
            SortBooksDialog(view.context,
                object: SortBooksDialogListener {
                    override fun onSaveButtonClicked(sortOrder: String) {
                        editor.apply {
                            putString(SHARED_PREFERENCES_KEY_SORT_ORDER, sortOrder)
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
                , sharedPref.getString(SHARED_PREFERENCES_KEY_SORT_ORDER, SORT_ORDER_TITLE_ASC)).show()
        }

        bookAdapter.setOnBookClickListener {
            etSearch.setText(EMPTY_STRING)
            val bundle = Bundle().apply {
                putSerializable(SERIALIZABLE_BUNDLE_BOOK, it)
            }
            findNavController().navigate(
                R.id.action_inProgressFragment_to_displayBookFragment,
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
                    etSearch.setText(EMPTY_STRING)
                    viewModel.searchBooks(etSearch.text.toString()).observe(viewLifecycleOwner, Observer { some_books ->
                        bookAdapter.differ.submitList(some_books)
                    })
                }
                true -> {
                    etSearch.visibility = View.GONE
                    ivClearSearch.visibility = View.GONE
                    ivClearSearch.isClickable = false
                    it.hideKeyboard()
                    this.getBooks(bookAdapter)
                }
            }
        }

        ivMore.setOnClickListener{
            it.hideKeyboard()
            findNavController().navigate(R.id.settingsFragment, null)
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

    fun getBooks(bookAdapter: BookAdapter) {
        val sharedPref = (activity as ListActivity).getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        when(sharedPref.getString(SHARED_PREFERENCES_KEY_SORT_ORDER, SORT_ORDER_TITLE_ASC)) {
            SORT_ORDER_TITLE_DESC -> viewModel.getSortedBooksByTitleDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
            SORT_ORDER_TITLE_ASC -> viewModel.getSortedBooksByTitleAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
            SORT_ORDER_AUTHOR_DESC -> viewModel.getSortedBooksByAuthorDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
            SORT_ORDER_AUTHOR_ASC -> viewModel.getSortedBooksByAuthorAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
            SORT_ORDER_RATING_DESC -> viewModel.getSortedBooksByRatingDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
            SORT_ORDER_RATING_ASC -> viewModel.getSortedBooksByRatingAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
            SORT_ORDER_PAGES_DESC -> viewModel.getSortedBooksByPagesDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
            SORT_ORDER_PAGES_ASC -> viewModel.getSortedBooksByPagesAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books -> bookAdapter.differ.submitList(some_books)})
        }
    }
}