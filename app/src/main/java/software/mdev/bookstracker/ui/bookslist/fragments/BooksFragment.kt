package software.mdev.bookstracker.ui.bookslist.fragments

import android.os.Bundle
import android.view.View
import android.view.animation.*
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Functions
import android.widget.LinearLayout
import androidx.viewpager2.widget.ViewPager2
import com.google.android.material.bottomsheet.BottomSheetDialog
import com.google.android.material.tabs.TabLayoutMediator
import kotlinx.android.synthetic.main.fragment_books.*
import software.mdev.bookstracker.adapters.BookListAdapter
import software.mdev.bookstracker.ui.bookslist.dialogs.AddEditBookDialog


class BooksFragment : Fragment(R.layout.fragment_books) {

    lateinit var viewModel: BooksViewModel
    private var wiggleBlocker = true

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)

        var listOfTabs = context?.resources?.let {
            listOf(
                it.getString(R.string.readFragment),
                it.getString(R.string.inProgressFragment),
                it.getString(R.string.toReadFragment)
            )
        }

        val adapter = BookListAdapter(this)
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
            showBottomSheetDialog()
        }
    }

    private fun showBottomSheetDialog() {
        if (context != null) {
            val bottomSheetDialog =
                BottomSheetDialog(requireContext(), R.style.AppBottomSheetDialogTheme)
            bottomSheetDialog.setContentView(R.layout.bottom_sheet_add_books)

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddManual)
                ?.setOnClickListener {
                    addManualGoToFrag()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddScan)
                ?.setOnClickListener {
                    addScanGoToFrag()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llAddSearch)
                ?.setOnClickListener {
                    addSearchGoToFrag()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.show()
        }
    }

    private fun addManualGoToFrag() {
        var emptyBook = Book("", "")
        val addEditBookDialog = AddEditBookDialog()

        if (addEditBookDialog != null) {
            addEditBookDialog!!.arguments = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, emptyBook)
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK_SOURCE, Constants.NO_SOURCE)
                putSerializable(Constants.SERIALIZABLE_BUNDLE_ACCENT, (activity as ListActivity).getAccentColor(activity as ListActivity, true))
            }
            addEditBookDialog!!.show(childFragmentManager, AddEditBookDialog.TAG)
        }
    }

    private fun addScanGoToFrag() {
        if (Functions().checkPermission(
                activity as ListActivity,
                android.Manifest.permission.CAMERA
            )
        ) {
            findNavController().navigate(R.id.action_booksFragment_to_addBookScanFragment)
        } else {
            Functions().requestPermission(
                activity as ListActivity,
                android.Manifest.permission.CAMERA,
                Constants.PERMISSION_CAMERA_FROM_BOOK_LIST
            )
        }
    }

    private fun addSearchGoToFrag() {
        findNavController().navigate(
            R.id.action_booksFragment_to_addBookSearchFragment
        )
    }
}