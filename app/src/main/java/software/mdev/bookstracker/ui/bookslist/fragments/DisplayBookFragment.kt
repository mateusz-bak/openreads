package software.mdev.bookstracker.ui.bookslist.fragments

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import kotlinx.android.synthetic.main.fragment_display_book.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_IN_PROGRESS
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_READ
import software.mdev.bookstracker.other.Constants.BOOK_STATUS_TO_READ
import software.mdev.bookstracker.other.Constants.SERIALIZABLE_BUNDLE_BOOK
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel


class DisplayBookFragment : Fragment(R.layout.fragment_display_book) {

    lateinit var viewModel: BooksViewModel
    private val args: DisplayBookFragmentArgs by navArgs()
    lateinit var book: Book
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val book = args.book

        tvBookTitle.text = book.bookTitle
        tvBookAuthor.text = book.bookAuthor
        rbRatingIndicator.rating = book.bookRating

        when (book.bookStatus) {
            BOOK_STATUS_READ -> {
                tvBookStatus.text = getString(R.string.finished)
                ivBookStatusInProgress.visibility = View.GONE
                ivBookStatusToRead.visibility = View.GONE
                rbRatingIndicator.visibility = View.VISIBLE
            }
            BOOK_STATUS_IN_PROGRESS -> {
                tvBookStatus.text = getString(R.string.inProgress)
                ivBookStatusRead.visibility = View.GONE
                ivBookStatusToRead.visibility = View.GONE
                rbRatingIndicator.visibility = View.GONE
            }
            BOOK_STATUS_TO_READ -> {
                tvBookStatus.text = getString(R.string.toRead)
                ivBookStatusInProgress.visibility = View.GONE
                ivBookStatusRead.visibility = View.GONE
                rbRatingIndicator.visibility = View.GONE
            }
        }

        fabEditBook.setOnClickListener {
            val bundle = Bundle().apply {
                putSerializable(SERIALIZABLE_BUNDLE_BOOK, book)
            }
            findNavController().navigate(
                R.id.action_displayBookFragment_to_editBookFragment,
                bundle
            )
        }
    }
}