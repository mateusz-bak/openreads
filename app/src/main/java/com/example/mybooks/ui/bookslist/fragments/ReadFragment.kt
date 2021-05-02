package com.example.mybooks.ui.bookslist.fragments

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.mybooks.R
import com.example.mybooks.adapters.BookAdapter
import com.example.mybooks.data.db.BooksDatabase
import com.example.mybooks.data.repositories.BooksRepository
import com.example.mybooks.ui.bookslist.ListActivity
import com.example.mybooks.ui.bookslist.BooksViewModel
import com.example.mybooks.ui.bookslist.BooksViewModelProviderFactory
import kotlinx.android.synthetic.main.fragment_read.*

class ReadFragment : Fragment(R.layout.fragment_read) {

    lateinit var viewModel: BooksViewModel
    lateinit var listActivity: ListActivity

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel
        listActivity = activity as ListActivity

        val database = BooksDatabase(view.context)
        val booksRepository = BooksRepository(database)
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)

        viewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

        val factory = BooksViewModelProviderFactory(booksRepository)
        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        val bookAdapter = BookAdapter(viewModel, view.context, whichFragment = "read")

        rvReadBooks.adapter = bookAdapter
        rvReadBooks.layoutManager = LinearLayoutManager(view.context)

        listActivity.showFabExpandAddOptions()
        listActivity.hideFabEditBook()

        viewModel.getReadBooks().observe(viewLifecycleOwner, Observer { some_books ->
            bookAdapter.differ.submitList(some_books)
        })

        bookAdapter.setOnBookClickListener {
            val bundle = Bundle().apply {
                putInt("bookId", it.id!!)
            }
            findNavController().navigate(
                R.id.action_readFragment_to_displayBookFragment,
                bundle
            )
        }
    }
}