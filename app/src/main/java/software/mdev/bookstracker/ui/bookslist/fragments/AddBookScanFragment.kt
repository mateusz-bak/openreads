package software.mdev.bookstracker.ui.bookslist.fragments


import android.os.Bundle
import android.view.View
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.budiyev.android.codescanner.CodeScanner
import com.budiyev.android.codescanner.CodeScannerView
import com.budiyev.android.codescanner.DecodeCallback
import kotlinx.android.synthetic.main.fragment_add_book_scan.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.ListActivity


class AddBookScanFragment : Fragment(R.layout.fragment_add_book_scan) {

    lateinit var viewModel: BooksViewModel
    lateinit var listActivity: ListActivity
    private lateinit var codeScanner: CodeScanner

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val scannerView = view.findViewById<CodeScannerView>(R.id.scanner_view)

        codeScanner = CodeScanner(listActivity, scannerView)
        codeScanner.decodeCallback = DecodeCallback {
            listActivity.runOnUiThread {
                Toast.makeText(activity, it.text, Toast.LENGTH_LONG).show()
            }
        }
        scannerView.setOnClickListener {
            codeScanner.startPreview()
        }
    }

    override fun onResume() {
        super.onResume()
        codeScanner.startPreview()
    }

    override fun onPause() {
        codeScanner.releaseResources()
        super.onPause()
    }

    private fun hideProgressBar() {
        paginationProgressBar?.visibility = View.INVISIBLE
    }

    private fun showProgressBar() {
        paginationProgressBar?.visibility = View.VISIBLE
    }
}
