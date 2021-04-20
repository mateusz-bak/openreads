package com.example.mybooks

import android.content.Intent
import android.os.Bundle
import android.view.Gravity
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_adder.*
import kotlinx.android.synthetic.main.activity_main.*


class AdderActivity: AppCompatActivity() {

    //    private lateinit var listElementAdapter: ListElementAdapter
    private lateinit var listElementAdapter: ListElementAdapter


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_adder)

//        listElementAdapter = ListElementAdapter(mutableListOf())
        listElementAdapter = ListElementAdapter(mutableListOf())


        btnAddBook.setOnClickListener { view ->
            val bookTitle = etTitle.text.toString()
            val bookAuthor = etAuthor.text.toString()
            val bookRating = rbRating.rating as Float



            if (bookTitle.isNotEmpty()) {
                if (bookAuthor.isNotEmpty()){
//                    val author = ListElement(bookTitleRaw, bookAuthorRaw)
//                    listElementAdapter.addBook(author)
                    val book = ListElement(bookTitle, bookAuthor, bookRating)
                    listElementAdapter.addBook(book)

                    Intent(this, MainActivity::class.java).also {
//                        it.putExtra("EXTRA_BOOK", book)
//                        it.putExtra("EXTRA_TITLE", bookTitle)
//                        it.putExtra("EXTRA_AUTHOR", bookAuthor)
//                        it.putExtra("EXTRA_RATING", bookRating)
                        startActivity(it)
                    }

                    etAuthor.text.clear()
                    etTitle.text.clear()
                    rbRating.setRating(0.0f)
                }
                else {
//                    Toast.makeText(this, "Fill in the author", Toast.LENGTH_SHORT).show()
                    Snackbar.make(view, "Fill in the author", Snackbar.LENGTH_SHORT).show()
                }
            } else {
//                Toast.makeText(this, "Fill in the title", Toast.LENGTH_SHORT).show()
                Snackbar.make(view, "Fill in the title", Snackbar.LENGTH_SHORT).show()
            }



//            Snackbar.make(view, "ADD clicked!", Snackbar.LENGTH_SHORT)
//                .setAction("Action", null).show()
        }
    }
}