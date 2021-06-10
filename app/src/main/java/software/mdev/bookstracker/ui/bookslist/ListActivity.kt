package software.mdev.bookstracker.ui.bookslist

import android.content.Context
import android.os.Bundle
import android.view.Menu
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.setupWithNavController
import kotlinx.android.synthetic.main.activity_list.*
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_KEY_ACCENT
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_NAME
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_AMBER_500
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory

class ListActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        setAppTheme()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list)

        bottomNavigationView.setupWithNavController(booksNavHostFragment.findNavController())

        booksNavHostFragment.findNavController()
            .addOnDestinationChangedListener { _, destination, _ ->
                when(destination.id) {
                    R.id.readFragment, R.id.inProgressFragment, R.id.toReadFragment ->
                        bottomNavigationView.visibility = View.VISIBLE
                    else -> bottomNavigationView.visibility = View.GONE
                }
            }

        val booksRepository = BooksRepository(BooksDatabase(this))
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)
        booksViewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.app_bar_menu, menu)
        return true
    }

    private fun setAppTheme(){
        val sharedPref = getSharedPreferences(SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        var accent = sharedPref.getString(
            SHARED_PREFERENCES_KEY_ACCENT,
            THEME_ACCENT_AMBER_500
        ).toString()

        when(accent){
            "accent_amber" -> setTheme(R.style.Theme_Mdev_Bookstracker)
            "accent_blue" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Blue)
            "accent_cyan" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Cyan)
            "accent_green" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Green)
            "accent_indigo" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Indigo)
            "accent_lime" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Lime)
            "accent_pink" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Pink)
            "accent_purple" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Purple)
            "accent_teal" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Teal)
            "accent_yellow" -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Yellow)
        }
    }

}