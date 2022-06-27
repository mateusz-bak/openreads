package software.mdev.bookstracker.ui.bookslist.fragments

import android.os.Bundle
import android.view.MenuItem
import android.view.View
import android.view.animation.AnimationUtils
import android.widget.LinearLayout
import android.widget.RatingBar
import androidx.activity.result.ActivityResultLauncher
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.tabs.TabLayoutMediator
import com.journeyapps.barcodescanner.ScanContract
import com.journeyapps.barcodescanner.ScanIntentResult
import com.journeyapps.barcodescanner.ScanOptions
import kotlinx.android.synthetic.main.fragment_books.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.adapters.BookListAdapter
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.dialogs.AddEditBookDialog
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.utils.DateTimeUtils.clearDateOfTime
import java.util.*


class BooksFragment : Fragment(R.layout.fragment_books) {

    lateinit var viewModel: BooksViewModel
    private var wiggleBlocker = true
    lateinit var listActivity: ListActivity
    private lateinit var barcodeLauncher: ActivityResultLauncher<ScanOptions>
    private lateinit var adapter: BookListAdapter

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        listActivity = activity as ListActivity

        viewModel = (activity as ListActivity).booksViewModel
        var listOfTabs = context?.resources?.let {
            listOf(
                it.getString(R.string.readFragment),
                it.getString(R.string.inProgressFragment),
                it.getString(R.string.toReadFragment)
            )
        }

        adapter = BookListAdapter(this)
        vpBooks.adapter = adapter

        adapter?.differ?.submitList(listOfTabs)

        TabLayoutMediator(tlBooks, vpBooks) { tab, position ->
            tab.text = listOfTabs?.get(position)
        }.attach()

        vpBooks.registerOnPageChangeCallback(object : ViewPager2.OnPageChangeCallback() {
            override fun onPageSelected(position: Int) {
                if (!wiggleBlocker) {
                    var anim = AnimationUtils.loadAnimation(context, R.anim.shake_1_light)
                    fabAddBook.startAnimation(anim)
                } else
                    wiggleBlocker = false
            }
        })

        fabAddBook.setOnClickListener {
            var anim = AnimationUtils.loadAnimation(context, R.anim.shake_1)
            fabAddBook.startAnimation(anim)
            showBottomSheetDialog(vpBooks.currentItem)
        }

        barcodeLauncher = registerForActivityResult(
            ScanContract()
        ) { result: ScanIntentResult ->
            if (result.contents != null)
                addSearchGoToFrag(result.contents, vpBooks.currentItem)
        }
    }

    private fun showBottomSheetDialog(currentItem: Int) {
        if (context != null) {
            val bottomSheetDialog =
                BottomSheetDialog(requireContext(), R.style.AppBottomSheetDialogTheme)
            bottomSheetDialog.setContentView(R.layout.bottom_sheet_add_books)

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddManual)
                ?.setOnClickListener {
                    addManualGoToFrag(currentItem)
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddScan)
                ?.setOnClickListener {
                    openCodeScanner()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddSearch)
                ?.setOnClickListener {
                    addSearchGoToFrag("manual_search", currentItem)
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.show()
        }
    }

    private fun addManualGoToFrag(currentItem: Int) {
        val emptyBook = Book("", "")
        val addEditBookDialog = AddEditBookDialog()

        if (addEditBookDialog != null) {
            addEditBookDialog!!.arguments = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, emptyBook)
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK_SOURCE, Constants.NO_SOURCE)
                putSerializable(Constants.SERIALIZABLE_BUNDLE_ACCENT, (activity as ListActivity).getAccentColor(activity as ListActivity, true))
                putInt(Constants.SERIALIZABLE_BUNDLE_BOOK_STATUS, currentItem)
            }
            addEditBookDialog!!.show(childFragmentManager, AddEditBookDialog.TAG)
        }
    }

    private fun openCodeScanner() {
        val options = ScanOptions()
        options.setDesiredBarcodeFormats(ScanOptions.ALL_CODE_TYPES)
        options.setPrompt(listActivity.getString(R.string.tbScannerTip))
        options.setCameraId(0)
        options.setBeepEnabled(true)
        options.setBarcodeImageEnabled(true)
        options.setOrientationLocked(true)
        barcodeLauncher.launch(options)
    }

    private fun addSearchGoToFrag(isbn: String = "manual_search", currentItem: Int) {
        val bundle = Bundle().apply {
            putString(Constants.SERIALIZABLE_BUNDLE_ISBN, isbn)
            putInt(Constants.SERIALIZABLE_BUNDLE_BOOK_STATUS, currentItem)
        }

        findNavController().navigate(
            R.id.action_booksFragment_to_addBookSearchFragment,
            bundle
        )
    }

    override fun onContextItemSelected(item: MenuItem): Boolean {
        val selectedBook: Book? = adapter.selectedBook
        val currentDate = clearDateOfTime(Calendar.getInstance().timeInMillis).toString()
        when (item.title) {
            activity?.getString(R.string.menu_start_reading_book) -> {
                selectedBook?.bookStartDate = currentDate
                selectedBook?.bookStatus = Constants.BOOK_STATUS_IN_PROGRESS
                updateBookFromContext(selectedBook)
            }
            activity?.getString(R.string.menu_finished_reading_book) -> {
                selectedBook?.bookStatus = Constants.BOOK_STATUS_READ
                selectedBook?.bookFinishDate = currentDate
                showRatingBarDialog(selectedBook)
            }
        }
        return super.onContextItemSelected(item)
    }

    private fun showRatingBarDialog(book: Book?) {
        val view = activity?.layoutInflater?.inflate(R.layout.dialog_rating, null)
        val rbView = view?.findViewById<RatingBar>(R.id.rbBookRating)
        context?.let { it ->
            val dialog = AlertDialog.Builder(it)
                .setView(view)
                .setTitle(R.string.insert_book_rating)
                .setPositiveButton(R.string.btnAdderSaveBook) { dialog, id ->
                    rbView?.let {rv ->
                        book?.bookRating = rv.rating
                        updateBookFromContext(book)
                    }
                }
                .setNegativeButton(R.string.btnAdderCancelFinishDate) {dialog, _ ->
                    dialog.cancel()
                }
                .create()
            dialog.show()
        }
    }

    private fun updateBookFromContext(book: Book?) {
        book?.let {
            viewModel.updateBook(it.id,
                it.bookTitle,
                it.bookAuthor,
                it.bookRating,
                it.bookStatus,
                it.bookPriority,
                it.bookStartDate,
                it.bookFinishDate,
                it.bookNumberOfPages,
                it.bookTitle_ASCII,
                it.bookAuthor_ASCII,
                it.bookIsDeleted,
                it.bookCoverUrl,
                it.bookOLID,
                it.bookISBN10,
                it.bookISBN13,
                it.bookPublishYear,
                it.bookIsFav,
                it.bookCoverImg,
                it.bookNotes,
                it.bookTags
            )
        }
    }
}