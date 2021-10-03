package software.mdev.bookstracker.ui.bookslist.fragments


import android.os.Bundle
import android.view.View
import android.view.WindowManager
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import com.budiyev.android.codescanner.CodeScanner
import com.budiyev.android.codescanner.CodeScannerView
import com.budiyev.android.codescanner.DecodeCallback
import kotlinx.android.synthetic.main.fragment_add_book_scan.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Constants
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

        (activity as ListActivity).window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
        (activity as ListActivity).window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)

        val scannerView = view.findViewById<CodeScannerView>(R.id.scanner_view)

        codeScanner = CodeScanner(listActivity, scannerView)
        codeScanner.decodeCallback = DecodeCallback {
            val bundle = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_ISBN, it.text)
            }

            listActivity.runOnUiThread {
                findNavController().navigate(
                    R.id.action_addBookScanFragment_to_addBookSearchFragment,
                    bundle
                )
            }
        }

        scannerView.setOnClickListener {
            codeScanner.startPreview()
        }
    }

    override fun onResume() {
        (activity as ListActivity).window.addFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
        (activity as ListActivity).window.addFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)

        codeScanner.startPreview()

        super.onResume()
    }

    override fun onPause() {
        (activity as ListActivity).window.clearFlags(WindowManager.LayoutParams.FLAG_LAYOUT_NO_LIMITS)
        (activity as ListActivity).window.clearFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS)
        codeScanner.releaseResources()
        super.onPause()
    }
}
