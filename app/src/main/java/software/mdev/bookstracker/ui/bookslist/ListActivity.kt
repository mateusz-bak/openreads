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
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_BLUE_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_CYAN_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_DEFAULT
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_GREEN_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_INDIGO_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_LIME_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_PINK_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_PURPLE_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_TEAL_500
import software.mdev.bookstracker.other.Constants.THEME_ACCENT_YELLOW_500
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
            THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            THEME_ACCENT_AMBER_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Amber)
            THEME_ACCENT_BLUE_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Blue)
            THEME_ACCENT_CYAN_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Cyan)
            THEME_ACCENT_GREEN_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Green)
            THEME_ACCENT_INDIGO_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Indigo)
            THEME_ACCENT_LIME_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Lime)
            THEME_ACCENT_PINK_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Pink)
            THEME_ACCENT_PURPLE_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Purple)
            THEME_ACCENT_TEAL_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Teal)
            THEME_ACCENT_YELLOW_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Yellow)
        }
    }

}