package com.example.mybooks

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.mybooks.data.db.entities.ListElement
import kotlinx.android.synthetic.main.activity_list.*

class ListActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list)

        var booksList = mutableListOf<ListElement>()

        val adapter = ListElementAdapter(booksList)
        rvListOfBooks.adapter = adapter
        rvListOfBooks.layoutManager = LinearLayoutManager(this)

        if (intent.getBooleanExtra("EXTRA_ADD_BOOK", false)){
            val newTitle = intent.getStringExtra("EXTRA_TITLE").toString()
            val newAuthor = intent.getStringExtra("EXTRA_AUTHOR").toString()
            val newRating = intent.getFloatExtra("EXTRA_RATING", 0F)
            val newBook = ListElement(newTitle, newAuthor, newRating)
            booksList.add(newBook)
            adapter.notifyItemInserted(booksList.size -1)
        }

        fabGoToAdder.setOnClickListener {
            Intent(this, AdderActivity::class.java).also {
                startActivity(it)
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