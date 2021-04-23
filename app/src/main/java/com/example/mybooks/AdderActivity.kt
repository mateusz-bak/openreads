package com.example.mybooks

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.example.mybooks.ui.bookslist.ListActivity
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_adder.*


class AdderActivity: AppCompatActivity() {

    private lateinit var listElementAdapter: ListElementAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_adder)

        listElementAdapter = ListElementAdapter(mutableListOf())


        btnAddBook.setOnClickListener { view ->
            val bookTitle = etTitle.text.toString()
            val bookAuthor = etAuthor.text.toString()
            val bookRating = rbRating.rating

            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
                    Intent(this, ListActivity::class.java).also {
                        it.putExtra("EXTRA_TITLE", bookTitle)
                        it.putExtra("EXTRA_AUTHOR", bookAuthor)
                        it.putExtra("EXTRA_RATING", bookRating)
                        it.putExtra("EXTRA_ADD_BOOK", true)
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
            R.id.miAbout -> Toast.makeText(this, "About is work in progress", Toast.LENGTH_SHORT).show()
            R.id.miSettings -> Toast.makeText(this, "Settings are work in progress", Toast.LENGTH_SHORT).show()
        }
        return true
    }
}