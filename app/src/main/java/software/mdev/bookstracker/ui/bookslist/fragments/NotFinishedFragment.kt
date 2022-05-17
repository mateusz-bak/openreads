package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.Context
import android.os.Bundle
import android.view.View
import android.view.inputmethod.InputMethodManager
import androidx.fragment.app.Fragment
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.fragment_not_finished.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import me.everything.android.ui.overscroll.OverScrollDecoratorHelper
import software.mdev.bookstracker.adapters.NotFinishedAdapter
import software.mdev.bookstracker.other.Constants


class NotFinishedFragment : Fragment(R.layout.fragment_not_finished) {

    lateinit var viewModel: BooksViewModel

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel

        view.hideKeyboard()

        val notFinishedAdapter = NotFinishedAdapter(view.context)

        rvBooks.adapter = notFinishedAdapter
        rvBooks.layoutManager = LinearLayoutManager(view.context)

        // bounce effect on the recyclerview
        OverScrollDecoratorHelper.setUpOverScroll(
            rvBooks,
            OverScrollDecoratorHelper.ORIENTATION_VERTICAL
        )

        this.getBooks(notFinishedAdapter)

        notFinishedAdapter.setOnBookClickListener {
            val bundle = Bundle().apply {
                putSerializable(Constants.SERIALIZABLE_BUNDLE_BOOK, it)
            }
            findNavController().navigate(
                R.id.action_notFinishedFragment_to_displayBookFragment,
                bundle
            )
        }
    }

    private fun View.hideKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun getBooks(notFinishedAdapter: NotFinishedAdapter) {
        viewModel.getNotFinishedBooks().observe(
            viewLifecycleOwner
        ) { books -> notFinishedAdapter.differ.submitList(books) }
    }
}
