package com.example.mybooks.ui.bookslist

import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import android.view.Menu
import android.view.MenuItem
import androidx.lifecycle.Observer
import androidx.lifecycle.ViewModelProviders
import androidx.navigation.fragment.NavHostFragment
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.setupWithNavController
import androidx.recyclerview.widget.LinearLayoutManager
import com.example.mybooks.other.ReadBookAdapter
import com.example.mybooks.R
import com.example.mybooks.data.db.ReadBooksDatabase
import com.example.mybooks.data.repositories.ReadBooksRepository
import kotlinx.android.synthetic.main.activity_list.*

class ListActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list)

        bottomNavigationView.setupWithNavController(booksNavHostFragment.findNavController())

//        val database = BooksDatabase(this)
//        val repository = BooksRepository(database)
//        val factory = BooksViewModelFactory(repository)
//
//        val viewModel = ViewModelProviders.of(this, factory).get(BooksViewModel::class.java)
//
//        val adapter = ListElementAdapter(listOf(), viewModel, this)
//
//        rvListOfBooks.adapter = adapter
//        rvListOfBooks.layoutManager = LinearLayoutManager(this)
//
//        viewModel.getAllListElements().observe(this, Observer {
//            adapter.books = it
//            adapter.notifyDataSetChanged()
//        })
//
//        fabGoToAdder.setOnClickListener {
//            Intent(this, AdderActivity::class.java).also {
//                startActivity(it)
//            }
//        }
//    }
//
//    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
//        menuInflater.inflate(R.menu.app_bar_menu, menu)
//        return true
//    }
//
//    override fun onOptionsItemSelected(item: MenuItem): Boolean {
//        when(item.itemId) {
//            R.id.miAbout -> Intent(this, AboutActivity::class.java).also {
//                startActivity(it)
//            }
//        }
//        return true
    }
}