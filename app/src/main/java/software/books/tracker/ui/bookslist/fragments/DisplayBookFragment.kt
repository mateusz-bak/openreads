package software.books.tracker.ui.bookslist.fragments

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import software.books.tracker.R
import software.books.tracker.data.db.entities.Book
import software.books.tracker.ui.bookslist.viewmodel.BooksViewModel
import software.books.tracker.ui.bookslist.ListActivity
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

        val book = args.book

            tvBookTitle.text = book.bookTitle
            tvBookAuthor.text = book.bookAuthor
            rbRatingIndicator.rating = book.bookRating

            when (book.bookStatus) {
                "read" -> {
                    tvBookStatus.text = getString(R.string.finished)
                    ivBookStatusInProgress.visibility = View.GONE
                    ivBookStatusToRead.visibility = View.GONE
                    rbRatingIndicator.visibility = View.VISIBLE
                }
                "in_progress" -> {
                    tvBookStatus.text = getString(R.string.inProgress)
                    ivBookStatusRead.visibility = View.GONE
                    ivBookStatusToRead.visibility = View.GONE
                    rbRatingIndicator.visibility = View.GONE
                }
                "to_read" -> {
                    tvBookStatus.text = getString(R.string.toRead)
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