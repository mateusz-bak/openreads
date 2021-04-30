package com.example.mybooks.ui.bookslist

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import android.view.View
import android.view.animation.Animation
import android.view.animation.AnimationUtils
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.setupWithNavController
import com.example.mybooks.R
import com.example.mybooks.data.db.BooksDatabase
import com.example.mybooks.data.db.entities.Book
import com.example.mybooks.data.repositories.BooksRepository
import com.example.mybooks.ui.bookslist.inprogressbooks.AddInProgressBookDialog
import com.example.mybooks.ui.bookslist.inprogressbooks.AddInProgressBookDialogListener
import com.example.mybooks.ui.bookslist.readbooks.AddReadBookDialog
import com.example.mybooks.ui.bookslist.readbooks.AddReadBookDialogListener
import com.example.mybooks.ui.bookslist.toreadbooks.AddToReadBookDialog
import com.example.mybooks.ui.bookslist.toreadbooks.AddToReadBookDialogListener
import kotlinx.android.synthetic.main.activity_list.*

class ListActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel

    private val rotateOpen: Animation by lazy {AnimationUtils.loadAnimation(this, R.anim.rotate_open_anim)}
    private val rotateClose: Animation by lazy {AnimationUtils.loadAnimation(this, R.anim.rotate_close_anim)}
    private val fromBottom: Animation by lazy {AnimationUtils.loadAnimation(this, R.anim.from_bottom_anim)}
    private val toBottom: Animation by lazy {AnimationUtils.loadAnimation(this, R.anim.to_bottom_anim)}
    private var clicked = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list)

        bottomNavigationView.setupWithNavController(booksNavHostFragment.findNavController())

        val booksRepository = BooksRepository(BooksDatabase(this))
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)
        booksViewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

        fabExpandAddOptions.setOnClickListener {
            onExpandAddOptionsButtonClicked()
        }

        fabAddReadBook.setOnClickListener{
            onExpandAddOptionsButtonClicked()
            AddReadBookDialog(this,
                object: AddReadBookDialogListener {
                    override fun onSaveButtonClicked(item: Book) {
                        booksViewModel.upsert(item)
                    }
                }
            ).show()
        }

        fabAddInProgressBook.setOnClickListener{
            onExpandAddOptionsButtonClicked()
            AddInProgressBookDialog(this,
                object: AddInProgressBookDialogListener {
                    override fun onSaveButtonClicked(item: Book) {
                        booksViewModel.upsert(item)
                    }
                }
            ).show()
        }

        fabAddToReadBook.setOnClickListener{
            onExpandAddOptionsButtonClicked()
            AddToReadBookDialog(this,
                object: AddToReadBookDialogListener {
                    override fun onSaveButtonClicked(item: Book) {

                        booksViewModel.upsert(item)
                    }
                }
            ).show()
        }
    }
    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.app_bar_menu, menu)
        return true
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        when(item.itemId) {
            R.id.miAbout -> Intent(this, AboutActivity::class.java).also {
                startActivity(it)
            }
        }
        return true
    }

    private fun onExpandAddOptionsButtonClicked() {
        setVisibility(clicked)
        setAnimation(clicked)
        setClickable(clicked)
        clicked = !clicked
    }

    private fun setAnimation(clicked: Boolean) {
        if(!clicked){
            fabAddReadBook.startAnimation(fromBottom)
            fabAddInProgressBook.startAnimation(fromBottom)
            fabAddToReadBook.startAnimation(fromBottom)
            fabExpandAddOptions.startAnimation(rotateOpen)
        }else{
            fabAddReadBook.startAnimation(toBottom)
            fabAddInProgressBook.startAnimation(toBottom)
            fabAddToReadBook.startAnimation(toBottom)
            fabExpandAddOptions.startAnimation(rotateClose)
        }
    }

    private fun setVisibility(clicked: Boolean) {
        if(!clicked){
            fabAddReadBook.visibility = View.VISIBLE
            fabAddInProgressBook.visibility = View.VISIBLE
            fabAddToReadBook.visibility = View.VISIBLE
        }else{
            fabAddReadBook.visibility = View.INVISIBLE
            fabAddInProgressBook.visibility = View.INVISIBLE
            fabAddToReadBook.visibility = View.INVISIBLE
        }
    }

    private fun setClickable(clicked: Boolean){
        if (!clicked){
            fabAddReadBook.isClickable = true
            fabAddInProgressBook.isClickable = true
            fabAddToReadBook.isClickable = true
        }else{
            fabAddReadBook.isClickable = false
            fabAddInProgressBook.isClickable = false
            fabAddToReadBook.isClickable = false
        }
    }
}