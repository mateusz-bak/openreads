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
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory

class ListActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        val booksRepository = BooksRepository(BooksDatabase(this))
        val booksViewModelProviderFactory = BooksViewModelProviderFactory(booksRepository)
        booksViewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

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
    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.app_bar_menu, menu)
        return true
    }

    private fun setAppTheme(){
        val sharedPref = getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        var accent = sharedPref.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_LightGreen)
            Constants.THEME_ACCENT_RED_800 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Red)
            Constants.THEME_ACCENT_CYAN_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Cyan)
            Constants.THEME_ACCENT_GREEN_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Green)
            Constants.THEME_ACCENT_BROWN_400 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Brown)
            Constants.THEME_ACCENT_LIME_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Lime)
            Constants.THEME_ACCENT_PINK_300 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Pink)
            Constants.THEME_ACCENT_PURPLE_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Purple)
            Constants.THEME_ACCENT_TEAL_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Teal)
            Constants.THEME_ACCENT_YELLOW_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Yellow)
        }
    }

}