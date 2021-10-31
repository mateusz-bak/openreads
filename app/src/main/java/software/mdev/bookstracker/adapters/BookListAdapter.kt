package software.mdev.bookstracker.adapters

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
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

    inner class BookListViewHolder(itemView: View) : RecyclerView.ViewHolder(itemView)
    lateinit var viewModel: BooksViewModel
    private val functions = Functions()

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

        viewModel = ViewModelProvider(booksFragment, booksViewModelProviderFactory).get(
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

        val bookAdapter = BookAdapter(holder.itemView.context, bookStatus)
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

        var booksMoreThanZero = getBooks(bookAdapter, bookStatus)

        if (booksMoreThanZero)
            holder.itemView.tvLooksEmpty.visibility = View.VISIBLE
        else
            holder.itemView.tvLooksEmpty.visibility = View.GONE
    }

    private fun getBooks(bookAdapter: BookAdapter, bookStatusInProgress: String): Boolean {
        var booksMoreThanZero = false
//        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
//        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

//        when(sharedPref.getString(
//            Constants.SHARED_PREFERENCES_KEY_SORT_ORDER,
//            Constants.SORT_ORDER_TITLE_ASC
//        )) {

        viewModel.getSortedBooksByTitleDesc(bookStatusInProgress).observe(booksFragment.viewLifecycleOwner, androidx.lifecycle.Observer { some_books ->
//            var booksFilteredForFav = filterBooksForFav(some_books)
            functions.filterBooksList(booksFragment.activity as ListActivity, bookAdapter, some_books)

            if (some_books.isNotEmpty())
                booksMoreThanZero = true
        })

//            Constants.SORT_ORDER_TITLE_ASC -> viewModel.getSortedBooksByTitleAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_AUTHOR_DESC -> viewModel.getSortedBooksByAuthorDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_AUTHOR_ASC -> viewModel.getSortedBooksByAuthorAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_RATING_DESC -> viewModel.getSortedBooksByRatingDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_RATING_ASC -> viewModel.getSortedBooksByRatingAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_PAGES_DESC -> viewModel.getSortedBooksByPagesDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_PAGES_ASC -> viewModel.getSortedBooksByPagesAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_START_DATE_DESC -> viewModel.getSortedBooksByStartDateDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_START_DATE_ASC -> viewModel.getSortedBooksByStartDateAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_FINISH_DATE_DESC -> viewModel.getSortedBooksByFinishDateDesc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//
//            Constants.SORT_ORDER_FINISH_DATE_ASC -> viewModel.getSortedBooksByFinishDateAsc(currentFragment).observe(viewLifecycleOwner, Observer { some_books ->
//                var booksFilteredForFav = filterBooksForFav(some_books)
//                functions.filterBooksList(activity as ListActivity, bookAdapter, booksFilteredForFav)
//            })
//        }
        return booksMoreThanZero
    }

//    private fun filterBooksForFav(someBooks: List<Book>): List<Book> {
//        var sharedPreferencesName = (activity as ListActivity).getString(R.string.shared_preferences_name)
//        val sharedPref = (activity as ListActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
//
//        if(sharedPref.getBoolean(Constants.SHARED_PREFERENCES_KEY_ONLY_FAV, false)) {
//            val listOnlyFav = emptyList<Book>().toMutableList()
//
//            for (i in someBooks) {
//                if (i.bookIsFav)
//                    listOnlyFav += i
//            }
//            return listOnlyFav
//        } else {
//            return someBooks
//        }
//    }
}