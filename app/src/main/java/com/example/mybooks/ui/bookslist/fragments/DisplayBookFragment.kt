package com.example.mybooks.ui.bookslist.fragments

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import com.example.mybooks.R
import com.example.mybooks.data.db.entities.Book
import com.example.mybooks.ui.bookslist.viewmodel.BooksViewModel
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

        var book = args.book

            tvBookTitle.text = book.bookTitle
            tvBookAuthor.text = book.bookAuthor
            rbRatingIndicator.rating = book.bookRating

            when (book.bookStatus) {
                "read" -> {
                    tvBookStatus.text = "Finished"
                    ivBookStatusInProgress.visibility = View.GONE
                    ivBookStatusToRead.visibility = View.GONE
                    rbRatingIndicator.visibility = View.VISIBLE
                }
                "in_progress" -> {
                    tvBookStatus.text = "In progress"
                    ivBookStatusRead.visibility = View.GONE
                    ivBookStatusToRead.visibility = View.GONE
                    rbRatingIndicator.visibility = View.GONE
                }
                "to_read" -> {
                    tvBookStatus.text = "To read"
                    ivBookStatusInProgress.visibility = View.GONE
                    ivBookStatusRead.visibility = View.GONE
                    rbRatingIndicator.visibility = View.GONE
                }
            }

        fabEditBook.setOnClickListener{
            val bundle = Bundle().apply {
                putSerializable("book", book)
            }
            findNavController().navigate(
                R.id.action_displayBookFragment_to_editBookFragment,
                bundle
            )
        }
    }
}