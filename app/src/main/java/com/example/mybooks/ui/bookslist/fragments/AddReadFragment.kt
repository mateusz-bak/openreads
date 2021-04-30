package com.example.mybooks.ui.bookslist.fragments

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.fragment.findNavController
import com.example.mybooks.R
import com.example.mybooks.data.db.BooksDatabase
import com.example.mybooks.data.db.entities.Book
import com.example.mybooks.data.repositories.BooksRepository
import com.example.mybooks.ui.bookslist.ListActivity
import com.example.mybooks.ui.bookslist.BooksViewModel
import com.example.mybooks.ui.bookslist.BooksViewModelProviderFactory
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.fragment_add_read.*

class AddReadFragment : Fragment(R.layout.fragment_add_read) {

    lateinit var viewModel: BooksViewModel

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        viewModel = (activity as ListActivity).booksViewModel

        val database = BooksDatabase(view.context)
        val repository = BooksRepository(database)
        val factory = BooksViewModelProviderFactory(repository)

        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        btnAddBook.setOnClickListener { view ->
            val bookTitle = etTitle.text.toString()
            val bookAuthor = etAuthor.text.toString()
            val bookRating = rbRating.rating

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    val item = Book(bookTitle, bookAuthor, bookRating, bookStatus = "read", bookPriority = "none", bookStartDate = "none", bookFinishDate = "none")
                    viewModel.upsert(item)

                    etAuthor.text.clear()
                    etTitle.text.clear()
                    rbRating.setRating(0.0f)

                    findNavController().navigate(R.id.action_addReadFragment_to_readFragment)
                }
                else {
                    Snackbar.make(view, "Fill in the author", Snackbar.LENGTH_SHORT).show()
                }
            } else {
                Snackbar.make(view, "Fill in the title", Snackbar.LENGTH_SHORT).show()
            }
        }
    }
}