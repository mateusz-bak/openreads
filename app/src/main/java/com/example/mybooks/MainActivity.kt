package com.example.mybooks

import android.content.Intent
import android.os.Bundle
import com.google.android.material.floatingactionbutton.FloatingActionButton
import com.google.android.material.snackbar.Snackbar
import androidx.appcompat.app.AppCompatActivity
import android.view.Menu
import android.view.MenuItem
import android.widget.Toast
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.activity_main.*

class MainActivity : AppCompatActivity() {

    private lateinit var listElementAdapter: ListElementAdapter

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

//        val title = intent.getStringExtra("EXTRA_TITLE")
//        val author = intent.getStringExtra("EXTRA_AUTHOR")
//        val rating = intent.getFloatExtra("EXTRA_RATING", 1.0F)

        listElementAdapter = ListElementAdapter(mutableListOf())
        rvListOfBooks.adapter = listElementAdapter
        rvListOfBooks.layoutManager = LinearLayoutManager(this)

//        val bookSerialized = intent.getSerializableExtra("EXTRA_BOOK")

//        if (bookSerialized == null) {
//            val book = ListElement("Title placeholder", "Author placeholder", 0.0F)
//            listElementAdapter.addBook(book)
//        }
//        else {
//            val book = bookSerialized as ListElement
//        val book = ListElement(title.toString(), author.toString(), rating)
//            listElementAdapter.addBook(book)
//        }




        fabGoToAdder.setOnClickListener() {
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