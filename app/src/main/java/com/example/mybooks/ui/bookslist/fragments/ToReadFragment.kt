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
import com.example.mybooks.data.db.entities.Book
import com.example.mybooks.data.repositories.BooksRepository
import com.example.mybooks.ui.bookslist.ListActivity
import com.example.mybooks.ui.bookslist.BooksViewModel
import com.example.mybooks.ui.bookslist.BooksViewModelProviderFactory
import com.example.mybooks.ui.bookslist.readbooks.AddReadBookDialog
import com.example.mybooks.ui.bookslist.readbooks.AddReadBookDialogListener
import kotlinx.android.synthetic.main.fragment_to_read.*

class ToReadFragment : Fragment(R.layout.fragment_to_read) {

    lateinit var viewModel: BooksViewModel

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel

        val database = BooksDatabase(view.context)
        val booksRepository = BooksRepository(database)
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)

        viewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

        val factory = BooksViewModelProviderFactory(booksRepository)
        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        val bookAdapter = BookAdapter(view.context, whichFragment = "to_read")

        rvToReadBooks.adapter = bookAdapter
        rvToReadBooks.layoutManager = LinearLayoutManager(view.context)

        viewModel.getToReadBooks().observe(viewLifecycleOwner, Observer { some_books ->
            bookAdapter.differ.submitList(some_books)
        })

        fabAddBook.setOnClickListener{
            AddReadBookDialog(view.context,
                object: AddReadBookDialogListener {
                    override fun onSaveButtonClicked(item: Book) {
                        viewModel.upsert(item)
                    }
                }
            ).show()
        }

        bookAdapter.setOnBookClickListener {
            val bundle = Bundle().apply {
                putSerializable("book", it)
            }
            findNavController().navigate(
                R.id.action_toReadFragment_to_displayBookFragment,
                bundle
            )
        }
    }
}