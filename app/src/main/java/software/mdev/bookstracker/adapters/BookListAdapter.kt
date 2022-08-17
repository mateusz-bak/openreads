package software.mdev.bookstracker.adapters

import android.content.Context
import android.os.Bundle
import android.view.ContextMenu
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.AsyncListDiffer
import androidx.recyclerview.widget.DiffUtil
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import kotlinx.android.synthetic.main.item_book_list.view.*
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Functions
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.fragments.BooksFragment
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory


class BookListAdapter(
    private val booksFragment: BooksFragment

) : RecyclerView.Adapter<BookListAdapter.BookListViewHolder>() {

    inner class BookListViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView), View.OnCreateContextMenuListener {
        init {
            itemView.setOnCreateContextMenuListener(this)
        }
        override fun onCreateContextMenu(
            menu: ContextMenu?,
            view: View?,
            p2: ContextMenu.ContextMenuInfo?
        ) {
            when (adapterPosition) {
                1 -> {
                    menu?.add(R.string.menu_finished_reading_book)
                }
                2 -> {
                    menu?.add(R.string.menu_start_reading_book)
                    menu?.add(R.string.menu_finished_reading_book)
                }
            }
        }
    }

    lateinit var viewModel: BooksViewModel
    private val functions = Functions()
    var selectedBook: Book? = null
        private set

    private val differCallback = object : DiffUtil.ItemCallback<String>() {
        override fun areItemsTheSame(oldItem: String, newItem: String): Boolean {
            return oldItem == newItem
        }

        override fun areContentsTheSame(oldItem: String, newItem: String): Boolean {
            return oldItem == newItem
        }
    }

    val differ = AsyncListDiffer(this, differCallback)

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): BookListViewHolder {
        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.item_book_list, parent, false)

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

        viewModel = ViewModelProvider(booksFragment.requireActivity(), booksViewModelProviderFactory).get(
            BooksViewModel::class.java
        )

        return BookListViewHolder(view)
    }

    override fun getItemCount(): Int {
        return differ.currentList.size
    }

    override fun onBindViewHolder(holder: BookListViewHolder, position: Int) {
        setUpBooksAdapter(holder, position)
    }

    private fun setUpBooksAdapter(holder: BookListViewHolder, position: Int) {
        var bookStatus = when (position) {
            0 -> Constants.BOOK_STATUS_READ
            1 -> Constants.BOOK_STATUS_IN_PROGRESS
            else -> Constants.BOOK_STATUS_TO_READ
        }

        val bookAdapter = BookAdapter(holder.itemView.context, bookStatus, setTagsVisibility(holder.itemView.context))
        holder.itemView.rvBooks.adapter = bookAdapter
        holder.itemView.rvBooks.layoutManager = LinearLayoutManager(holder.itemView.context)

        // bounce effect on the recyclerview
        OverScrollDecoratorHelper.setUpOverScroll(holder.itemView.rvBooks, OverScrollDecoratorHelper.ORIENTATION_VERTICAL)

        bookAdapter.setOnBookClickListener {
            val bundle = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, it)
            }
            booksFragment.findNavController().navigate(
                R.id.action_booksFragment_to_displayBookFragment,
                bundle
            )
        }

        booksFragment.registerForContextMenu(holder.itemView.rvBooks)

        bookAdapter.setOnBookLongClickListener {
            selectedBook = it
        }

        // triggers after saving new sort mode
        viewModel.getBooksTrigger.observe(booksFragment.requireActivity(), Observer {
            getBooks(bookAdapter, bookStatus, holder.itemView, true)
        })

        getBooks(bookAdapter, bookStatus, holder.itemView)
    }

    private fun setTagsVisibility(context: Context): Boolean {
        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        return sharedPref.getBoolean(Constants.SHARED_PREFERENCES_KEY_SHOW_TAGS, false)
    }

    private fun getBooks(adapter: BookAdapter, status: String, itemView: View, scroll: Boolean = false) {
        var sharedPreferencesName = booksFragment.activity?.getString(R.string.shared_preferences_name)
        val sharedPref = booksFragment.activity?.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        viewModel.getSortedBooksByTitleDesc(status).observe(booksFragment.requireActivity(), Observer { some_books ->
            if (some_books.isNotEmpty())
                itemView.tvLooksEmpty.visibility = View.GONE
            else
                itemView.tvLooksEmpty.visibility = View.VISIBLE
        })

        when(sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_SORT_ORDER,
            Constants.SORT_ORDER_TITLE_ASC
        )) {
            Constants.SORT_ORDER_TITLE_ASC -> viewModel.getSortedBooksByTitleAsc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
                })

            Constants.SORT_ORDER_TITLE_DESC -> viewModel.getSortedBooksByTitleDesc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_AUTHOR_ASC -> viewModel.getSortedBooksByAuthorAsc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_AUTHOR_DESC -> viewModel.getSortedBooksByAuthorDesc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_RATING_ASC -> viewModel.getSortedBooksByRatingAsc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_RATING_DESC -> viewModel.getSortedBooksByRatingDesc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_PAGES_ASC -> viewModel.getSortedBooksByPagesAsc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_PAGES_DESC -> viewModel.getSortedBooksByPagesDesc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_START_DATE_ASC -> viewModel.getSortedBooksByStartDateAsc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_START_DATE_DESC -> viewModel.getSortedBooksByStartDateDesc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_FINISH_DATE_ASC -> viewModel.getSortedBooksByFinishDateAsc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })

            Constants.SORT_ORDER_FINISH_DATE_DESC -> viewModel.getSortedBooksByFinishDateDesc(status)
                .observe(booksFragment.requireActivity(), Observer { some_books ->
                    if (booksFragment != null && adapter != null && some_books != null) {
                        var booksFilteredForFav = filterBooksForFav(booksFragment.requireActivity() as ListActivity, some_books)
                        functions.filterBooksList(booksFragment.requireActivity() as ListActivity, adapter, booksFilteredForFav, itemView?.rvBooks, scroll)
                    }
            })
        }
    }

    private fun filterBooksForFav(listActivity: ListActivity, someBooks: List<Book>): List<Book> {
        var sharedPreferencesName = listActivity.getString(R.string.shared_preferences_name)
        val sharedPref = listActivity.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        if(sharedPref.getBoolean(Constants.SHARED_PREFERENCES_KEY_ONLY_FAV, false)) {
            val listOnlyFav = emptyList<Book>().toMutableList()

            for (i in someBooks) {
                if (i.bookIsFav)
                    listOnlyFav += i
            }
            return listOnlyFav
        } else {
            return someBooks
        }
    }
}