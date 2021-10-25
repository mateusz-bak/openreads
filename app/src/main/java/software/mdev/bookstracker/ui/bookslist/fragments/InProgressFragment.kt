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
import kotlinx.android.synthetic.main.fragment_in_progress.*
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
import android.widget.LinearLayout
import com.google.android.material.bottomsheet.BottomSheetDialog


class InProgressFragment : Fragment(R.layout.fragment_in_progress) {

    lateinit var viewModel: BooksViewModel
    private val currentFragment = Constants.BOOK_STATUS_IN_PROGRESS
    private val functions = Functions()

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel

        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()

        etSearch.visibility = View.INVISIBLE
        ivClearSearch.visibility = View.GONE
        tvLooksEmpty.visibility = View.GONE

        ivClearSearch.isClickable = false

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

        fabAddBook.setOnClickListener {
            showBottomSheetDialog()
        }

        ivSort.setOnClickListener{
            animateClickView(it)
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
                R.id.action_inProgressFragment_to_displayBookFragment,
                bundle
            )
        }

        ivSearch.setOnClickListener {
            animateClickView(it)
            when(etSearch.visibility) {
                View.VISIBLE -> {
                    when (etSearch.text.isEmpty()){
                        false -> {
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
            animateClickView(it)
            it.hideKeyboard()
            findNavController().navigate(R.id.settingsFragment, null)
        }
    }

    private fun View.hideKeyboard() {
        val inputManager = context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
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

            Constants.SORT_ORDER_PAGES_DESC -> viewModel.getSortedBooksByPagesDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })

            Constants.SORT_ORDER_PAGES_ASC -> viewModel.getSortedBooksByPagesAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })

            Constants.SORT_ORDER_START_DATE_DESC -> viewModel.getSortedBooksByStartDateDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })

            Constants.SORT_ORDER_START_DATE_ASC -> viewModel.getSortedBooksByStartDateAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })

            else -> viewModel.getSortedBooksByTitleAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
                bookAdapter.differ.submitList(some_books)
            })
        }
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

    private fun animateClickView(view: View, multiplier: Float = 1F) {
        view.animate().scaleX(0.7F * multiplier).scaleY(0.7F * multiplier).setDuration(150L).start()

        MainScope().launch {
            delay(160L)
            view.animate().scaleX(1F).scaleY(1F).setDuration(150L).start()
        }
    }

    private fun showBottomSheetDialog() {
        if (context != null) {
            val bottomSheetDialog = BottomSheetDialog(requireContext(), R.style.AppBottomSheetDialogTheme)
            bottomSheetDialog.setContentView(R.layout.bottom_sheet_add_books)

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddManual)
                ?.setOnClickListener {
                    addManualGoToFrag()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddScan)
                ?.setOnClickListener {
                    addScanGoToFrag()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddSearch)
                ?.setOnClickListener {
                    addSearchGoToFrag()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.show()
        }
    }

    private fun addManualGoToFrag() {
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
            R.id.action_inProgressFragment_to_addEditBookFragment,
            bundle
        )
    }

    private fun addScanGoToFrag() {
        if (Functions().checkPermission(activity as ListActivity, android.Manifest.permission.CAMERA)) {
            findNavController().navigate(R.id.action_inProgressFragment_to_addBookScanFragment)
        } else {
            Functions().requestPermission(
                activity as ListActivity,
                android.Manifest.permission.CAMERA,
                Constants.PERMISSION_CAMERA_FROM_LIST_2)
        }
    }

    private fun addSearchGoToFrag() {
        findNavController().navigate(
            R.id.action_inProgressFragment_to_addBookSearchFragment)
    }
}