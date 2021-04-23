package com.example.mybooks.ui.bookslist

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProviders
import com.example.mybooks.R
import com.example.mybooks.data.db.BooksDatabase
import com.example.mybooks.data.db.entities.ListElement
import com.example.mybooks.data.repositories.BooksRepository
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_adder.*


class AdderActivity: AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_adder)

        val database = BooksDatabase(this)
        val repository = BooksRepository(database)
        val factory = BooksViewModelFactory(repository)

        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)

        btnAddBook.setOnClickListener { view ->
            val bookTitle = etTitle.text.toString()
            val bookAuthor = etAuthor.text.toString()
            val bookRating = rbRating.rating

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    Intent(this, ListActivity::class.java).also {
                        val item = ListElement(bookTitle, bookAuthor, bookRating)
                        viewModel.upsert(item)
                        startActivity(it)
                    }

                    etAuthor.text.clear()
                    etTitle.text.clear()
                    rbRating.setRating(0.0f)
                }
                else {
                    Snackbar.make(view, "Fill in the author", Snackbar.LENGTH_SHORT).show()
                }
            } else {
                Snackbar.make(view, "Fill in the title", Snackbar.LENGTH_SHORT).show()
            }
        }
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.app_bar_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when(item.itemId) {
            R.id.miAbout -> Intent(this, AdderActivity::class.java).also {
                startActivity(it)
            }
        }
        return true
    }
}