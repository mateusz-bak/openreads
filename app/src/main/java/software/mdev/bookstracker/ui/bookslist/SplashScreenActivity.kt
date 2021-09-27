package software.mdev.bookstracker.ui.bookslist

import android.annotation.SuppressLint
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.view.Menu
import android.view.View
import androidx.activity.result.contract.ActivityResultContracts
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.ViewModelProvider
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.setupWithNavController
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.activity_list.*
import kotlinx.android.synthetic.main.activity_splash_screen.*
import kotlinx.android.synthetic.main.item_setup.view.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
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

class SplashScreenActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash_screen)

        prepareSplashScreenViews()

        animateSplashScreenViews()

        launchListActivity()
    }

    private fun prepareSplashScreenViews() {
        ivLogo.alpha = 0F
        tvAppName.alpha = 0F
        tvAppVersion.alpha = 0F

        ivLogo.visibility = View.VISIBLE
        tvAppName.visibility = View.VISIBLE
        tvAppVersion.visibility = View.VISIBLE
    }

    private fun animateSplashScreenViews() {
        var duration = 600L
        var startDelay = 100L

        ivLogo.animate()
            .setStartDelay(startDelay)
            .setDuration(duration)
            .alpha(1F)
            .start()

        tvAppName.animate()
            .setStartDelay(startDelay)
            .setDuration(duration)
            .alpha(1F)
            .start()

        tvAppVersion.animate()
            .setStartDelay(startDelay)
            .setDuration(duration)
            .alpha(1F)
            .start()
    }

    private fun launchListActivity() {
        MainScope().launch {
            delay(700)

            val intent = Intent(this@SplashScreenActivity, ListActivity::class.java)
            startActivity(intent)
            finish()
        }
    }
}