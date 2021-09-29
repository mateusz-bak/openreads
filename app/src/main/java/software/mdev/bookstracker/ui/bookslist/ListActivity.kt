package software.mdev.bookstracker.ui.bookslist

import android.annotation.SuppressLint
import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.view.Menu
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_list.*
import software.mdev.bookstracker.BuildConfig
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.LanguageDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.repositories.BooksRepository
import software.mdev.bookstracker.data.repositories.LanguageRepository
import software.mdev.bookstracker.data.repositories.OpenLibraryRepository
import software.mdev.bookstracker.data.repositories.YearRepository
import software.mdev.bookstracker.other.Backup
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Functions
import software.mdev.bookstracker.other.Updater
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModelProviderFactory
import java.io.IOException

class ListActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        val booksRepository = BooksRepository(BooksDatabase(this))
        val yearRepository = YearRepository(YearDatabase(this))
        val openLibraryRepository = OpenLibraryRepository()
        val languageRepository = LanguageRepository(LanguageDatabase(this))

        val updater = Updater()

        val booksViewModelProviderFactory = BooksViewModelProviderFactory(
            booksRepository,
            yearRepository,
            openLibraryRepository,
            languageRepository
        )

        booksViewModel = ViewModelProvider(this, booksViewModelProviderFactory).get(
            BooksViewModel::class.java)

        setAppTheme()
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_list)

        updater.checkForAppUpdate(this, false)

        // ask for rating only in gplay release
        if (BuildConfig.FLAVOR == "gplay" && BuildConfig.BUILD_TYPE == "release")
            askForRating()

        bottomNavigationView.setupWithNavController(booksNavHostFragment.findNavController())

        booksNavHostFragment.findNavController()
            .addOnDestinationChangedListener { _, destination, _ ->
                when(destination.id) {
                    R.id.readFragment, R.id.inProgressFragment, R.id.toReadFragment , R.id.statisticsFragment->
                        bottomNavigationView.visibility = View.VISIBLE
                    else -> bottomNavigationView.visibility = View.GONE
                }
            }

        booksViewModel.getBookCount(Constants.BOOK_STATUS_READ).observe(this) { count ->
            setBadge(0, count.toInt())
        }

        booksViewModel.getBookCount(Constants.BOOK_STATUS_IN_PROGRESS).observe(this) { count ->
            setBadge(1, count.toInt())
        }

        booksViewModel.getBookCount(Constants.BOOK_STATUS_TO_READ).observe(this) { count ->
            setBadge(2, count.toInt())
        }

    }

    override fun onCreateOptionsMenu(menu: Menu?): Boolean {
        menuInflater.inflate(R.menu.app_bar_menu, menu)
        return true
    }

    private fun setBadge(index: Int, count: Int) {
        var menuItemId = bottomNavigationView.menu.getItem(index).itemId

        if (count > 0) {
            bottomNavigationView.getOrCreateBadge(menuItemId).backgroundColor =
                resources.getColor(R.color.grey_500)

            bottomNavigationView.getOrCreateBadge(menuItemId).number = count
        } else {
            bottomNavigationView.removeBadge(menuItemId)
        }
    }

    private fun setAppTheme(){
        var sharedPreferencesName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        var accent = sharedPref.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_LightGreen)
            Constants.THEME_ACCENT_ORANGE_500 -> setTheme(R.style.Theme_Mdev_Bookstracker_CustomTheme_Orange)
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

    // Show a snackbar containing a given text and an optional action, with a 5 seconds duration
    @SuppressLint("ResourceType")
    fun showSnackbar(
        content: String,
        attachView: View? = null,
        action: (() -> Unit)? = null,
        actionText: String? = null,
    ) {
        val snackbar = Snackbar.make(findViewById(android.R.id.content), content, 5000)
        snackbar.isGestureInsetBottomIgnored = true
        if (attachView != null)
            snackbar.anchorView = attachView
        else
            snackbar.anchorView = this.bottomNavigationView
        if (action != null) {
            snackbar.setAction(actionText) {
                action()
            }
        }
        snackbar.show()
    }

    // Choose a backup registering a callback and following the latest guidelines
    val selectBackup =
        registerForActivityResult(ActivityResultContracts.GetContent()) { fileUri: Uri? ->

            try {
                val backupImporter = Backup()
                if (fileUri != null) backupImporter.importBackup(this, fileUri)
            } catch (e: IOException) {
                showSnackbar(e.toString())
                e.printStackTrace()
            }
        }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (grantResults.isNotEmpty()
            && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
            when (requestCode) {
                Constants.PERMISSION_CAMERA_FROM_LIST_1 -> booksNavHostFragment.findNavController()
                    .navigate(R.id.action_readFragment_to_addBookScanFragment)
                Constants.PERMISSION_CAMERA_FROM_LIST_2 -> booksNavHostFragment.findNavController()
                    .navigate(R.id.action_inProgressFragment_to_addBookScanFragment)
                Constants.PERMISSION_CAMERA_FROM_LIST_3 -> booksNavHostFragment.findNavController()
                    .navigate(R.id.action_toReadFragment_to_addBookScanFragment)
            }
        }
    }

    private fun askForRating() {
        var askForRatingTime = checkNextAskingTime()

        if (askForRatingTime == 0L)
            setNextAskingTime(System.currentTimeMillis() + Constants.MS_ONE_WEEK)
        else if (askForRatingTime == Long.MAX_VALUE) {

        } else {
            if (askForRatingTime < System.currentTimeMillis())
                displayAskForRatingDialog()
        }
    }

    private fun displayAskForRatingDialog() {
        val askForRatingDialog = AlertDialog.Builder(this)
                .setTitle(R.string.ask_for_rating_dialog_title)
                .setMessage(R.string.ask_for_rating_dialog_message)
                .setIcon(R.drawable.ic_baseline_star_rate_24)
                .setPositiveButton(R.string.ask_for_rating_dialog_pos) { _, _ ->
                    try {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=$packageName")))
                    } catch (e: ActivityNotFoundException) {
                        startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://play.google.com/store/apps/details?id=$packageName")))
                    }
                    setNextAskingTime(Long.MAX_VALUE)
                }
                .setNeutralButton(R.string.ask_for_rating_dialog_neu) { _, _ ->
                    setNextAskingTime(System.currentTimeMillis() + Constants.MS_THREE_DAYS)
                }
                .setNegativeButton(R.string.ask_for_rating_dialog_neg) { _, _ ->
                    setNextAskingTime(Long.MAX_VALUE)
                }
                .create()

        askForRatingDialog?.show()
        askForRatingDialog?.getButton(AlertDialog.BUTTON_NEGATIVE)?.setTextColor(ContextCompat.getColor(this.baseContext, R.color.grey_500))
        askForRatingDialog?.getButton(AlertDialog.BUTTON_NEUTRAL)?.setTextColor(ContextCompat.getColor(this.baseContext, R.color.grey_500))
    }

    private fun setNextAskingTime(time: Long) {
        var sharedPrefName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPrefName, Context.MODE_PRIVATE)
        val sharedPrefEditor = sharedPref?.edit()

        sharedPrefEditor?.apply {
            putLong(Constants.SHARED_PREFERENCES_KEY_TIME_TO_ASK_FOR_RATING, time)
            apply()
        }
    }

    private fun checkNextAskingTime(): Long {
        var sharedPrefName = getString(R.string.shared_preferences_name)
        val sharedPref = getSharedPreferences(sharedPrefName, Context.MODE_PRIVATE)

        return sharedPref.getLong(
            Constants.SHARED_PREFERENCES_KEY_TIME_TO_ASK_FOR_RATING,
            0L
        )
    }
}