package software.mdev.bookstracker.ui.bookslist

import android.content.Intent
import android.os.Bundle
import android.view.View
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_splash_screen.*
import kotlinx.coroutines.MainScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import software.mdev.bookstracker.BuildConfig
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel

class SplashScreenActivity : AppCompatActivity() {

    lateinit var booksViewModel: BooksViewModel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash_screen)

        if (BuildConfig.BUILD_TYPE == "debug")
            launchListActivityNoDelay()
        else {
            prepareSplashScreenViews()
            animateSplashScreenViews()
            launchListActivityDelay()
        }
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
        var duration = 400L
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

    private fun launchListActivityDelay() {
        MainScope().launch {
            delay(750L)

            val intent = Intent(this@SplashScreenActivity, ListActivity::class.java)
            startActivity(intent)
            finish()
        }
    }

    private fun launchListActivityNoDelay() {
        val intent = Intent(this@SplashScreenActivity, ListActivity::class.java)
        startActivity(intent)
        finish()
    }
}