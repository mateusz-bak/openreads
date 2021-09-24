package software.mdev.bookstracker.ui.bookslist.fragments


import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import kotlinx.android.synthetic.main.fragment_add_book_scan.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.ListActivity


class AddBookScanFragment : Fragment(R.layout.fragment_add_book_scan) {

    lateinit var viewModel: BooksViewModel
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity
    }

    override fun onResume() {
        super.onResume()
//        start scanning
    }

    override fun onPause() {
        super.onPause()
//        stop scanning
    }

    private fun hideProgressBar() {
        paginationProgressBar?.visibility = View.INVISIBLE
    }

    private fun showProgressBar() {
        paginationProgressBar?.visibility = View.VISIBLE
    }
}
