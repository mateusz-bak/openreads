package com.example.mybooks.ui.bookslist.fragments

import android.os.Bundle
import android.util.Log
import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.fragment.navArgs
import com.example.mybooks.R
import com.example.mybooks.data.db.BooksDatabase
import com.example.mybooks.data.db.entities.Book
import com.example.mybooks.data.repositories.BooksRepository
import com.example.mybooks.ui.bookslist.BooksViewModel
import com.example.mybooks.ui.bookslist.BooksViewModelProviderFactory
import com.example.mybooks.ui.bookslist.ListActivity
import kotlinx.android.synthetic.main.fragment_display_book.*


class DisplayBookFragment : Fragment(R.layout.fragment_display_book) {

    lateinit var viewModel: BooksViewModel
    private val args: DisplayBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val database = BooksDatabase(view.context)
        val repository = BooksRepository(database)
        val factory = BooksViewModelProviderFactory(repository)

        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        viewModel.getSingleBook(args.bookId).observe(viewLifecycleOwner, Observer {
            val book = it

            tvBookTitle.text = book.bookTitle
            tvBookAuthor.text = book.bookAuthor
            rbRatingIndicator.rating = book.bookRating

            when (book.bookStatus) {
                "read" -> {
                    tvBookStatus.text = "Finished"
                    ivBookStatusInProgress.visibility = View.GONE
                    ivBookStatusToRead.visibility = View.GONE
                }
                "in_progress" -> {
                    tvBookStatus.text = "In progress"
                    ivBookStatusRead.visibility = View.GONE
                    ivBookStatusToRead.visibility = View.GONE
                }
                "to_read" -> {
                    tvBookStatus.text = "To read"
                    ivBookStatusInProgress.visibility = View.GONE
                    ivBookStatusRead.visibility = View.GONE
                }
            }
        })
    }
}