package software.books.tracker.ui.bookslist

import android.content.Intent
import android.os.Bundle
import android.view.Menu
import android.view.MenuItem
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.setupWithNavController
import software.books.tracker.R
import software.books.tracker.data.db.BooksDatabase
import software.books.tracker.data.repositories.BooksRepository
import software.books.tracker.ui.bookslist.viewmodel.BooksViewModel
import software.books.tracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import kotlinx.android.synthetic.main.activity_list.*

class ListActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list)

        bottomNavigationView.setupWithNavController(booksNavHostFragment.findNavController())

        val booksRepository = BooksRepository(BooksDatabase(this))
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)
        booksViewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)
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
}