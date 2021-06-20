package software.mdev.bookstracker.ui.bookslist.dialogs

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import android.view.inputmethod.InputMethodManager
import software.mdev.bookstracker.R
import android.widget.EditText
import androidx.appcompat.app.AppCompatDialog
import androidx.core.content.ContextCompat
import com.google.android.material.snackbar.Snackbar
import kotlinx.android.synthetic.main.dialog_edit_challenge.*
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.other.Constants
import java.util.*


class ChallengeDialog(
    context: Context,
    var year: Year,
    var challengeDialogListener: ChallengeDialogListener
) : AppCompatDialog(context) {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_edit_challenge)
        var accentColor = getAccentColor(context.applicationContext)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        var challengeDifficulty: Int?

        if (year.yearChallengeBooks == null) {
            challengeDifficulty = null
        } else {
            challengeDifficulty = year.yearChallengeBooks
        }

        tvChallengeEditorYear.text = year.year
        when (year.yearChallengeBooks) {
            0 -> btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_0)
            1 -> btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_1)
            2 -> btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_2)
            3 -> btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_3)
            4 -> btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_4)
            else -> btnChallengeEditorBooksNumber.text =
                context.getString(R.string.click_to_set_challenge)
        }

        btnChallengeEditorBeginner.visibility = View.GONE
        btnChallengeEditorEasy.visibility = View.GONE
        btnChallengeEditorNormal.visibility = View.GONE
        btnChallengeEditorHard.visibility = View.GONE
        btnChallengeEditorInsane.visibility = View.GONE

        btnChallengeEditorBooksNumber.setOnClickListener {
            tvChallengeEditorTitle.visibility = View.GONE
            tvChallengeEditorYear.visibility = View.GONE
            btnChallengeEditorBooksNumber.visibility = View.GONE
            btnChallengeEditorCancel.visibility = View.GONE
            btnChallengeEditorSet.visibility = View.GONE

            btnChallengeEditorBeginner.visibility = View.VISIBLE
            btnChallengeEditorEasy.visibility = View.VISIBLE
            btnChallengeEditorNormal.visibility = View.VISIBLE
            btnChallengeEditorHard.visibility = View.VISIBLE
            btnChallengeEditorInsane.visibility = View.VISIBLE
        }

        btnChallengeEditorBeginner.setOnClickListener {
            btnChallengeEditorBeginner.visibility = View.GONE
            btnChallengeEditorEasy.visibility = View.GONE
            btnChallengeEditorNormal.visibility = View.GONE
            btnChallengeEditorHard.visibility = View.GONE
            btnChallengeEditorInsane.visibility = View.GONE

            tvChallengeEditorTitle.visibility = View.VISIBLE
            tvChallengeEditorYear.visibility = View.VISIBLE
            btnChallengeEditorBooksNumber.visibility = View.VISIBLE
            btnChallengeEditorCancel.visibility = View.VISIBLE
            btnChallengeEditorSet.visibility = View.VISIBLE
            challengeDifficulty = 0
            btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_0)
        }
        btnChallengeEditorEasy.setOnClickListener {
            btnChallengeEditorBeginner.visibility = View.GONE
            btnChallengeEditorEasy.visibility = View.GONE
            btnChallengeEditorNormal.visibility = View.GONE
            btnChallengeEditorHard.visibility = View.GONE
            btnChallengeEditorInsane.visibility = View.GONE

            tvChallengeEditorTitle.visibility = View.VISIBLE
            tvChallengeEditorYear.visibility = View.VISIBLE
            btnChallengeEditorBooksNumber.visibility = View.VISIBLE
            btnChallengeEditorCancel.visibility = View.VISIBLE
            btnChallengeEditorSet.visibility = View.VISIBLE
            challengeDifficulty = 1
            btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_1)
        }
        btnChallengeEditorNormal.setOnClickListener {
            btnChallengeEditorBeginner.visibility = View.GONE
            btnChallengeEditorEasy.visibility = View.GONE
            btnChallengeEditorNormal.visibility = View.GONE
            btnChallengeEditorHard.visibility = View.GONE
            btnChallengeEditorInsane.visibility = View.GONE

            tvChallengeEditorTitle.visibility = View.VISIBLE
            tvChallengeEditorYear.visibility = View.VISIBLE
            btnChallengeEditorBooksNumber.visibility = View.VISIBLE
            btnChallengeEditorCancel.visibility = View.VISIBLE
            btnChallengeEditorSet.visibility = View.VISIBLE
            challengeDifficulty = 2
            btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_2)
        }
        btnChallengeEditorHard.setOnClickListener {
            btnChallengeEditorBeginner.visibility = View.GONE
            btnChallengeEditorEasy.visibility = View.GONE
            btnChallengeEditorNormal.visibility = View.GONE
            btnChallengeEditorHard.visibility = View.GONE
            btnChallengeEditorInsane.visibility = View.GONE

            tvChallengeEditorTitle.visibility = View.VISIBLE
            tvChallengeEditorYear.visibility = View.VISIBLE
            btnChallengeEditorBooksNumber.visibility = View.VISIBLE
            btnChallengeEditorCancel.visibility = View.VISIBLE
            btnChallengeEditorSet.visibility = View.VISIBLE
            challengeDifficulty = 3
            btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_3)
        }
        btnChallengeEditorInsane.setOnClickListener {
            btnChallengeEditorBeginner.visibility = View.GONE
            btnChallengeEditorEasy.visibility = View.GONE
            btnChallengeEditorNormal.visibility = View.GONE
            btnChallengeEditorHard.visibility = View.GONE
            btnChallengeEditorInsane.visibility = View.GONE

            tvChallengeEditorTitle.visibility = View.VISIBLE
            tvChallengeEditorYear.visibility = View.VISIBLE
            btnChallengeEditorBooksNumber.visibility = View.VISIBLE
            btnChallengeEditorCancel.visibility = View.VISIBLE
            btnChallengeEditorSet.visibility = View.VISIBLE
            challengeDifficulty = 4
            btnChallengeEditorBooksNumber.text = context.getString(R.string.challenge_4)
        }

        btnChallengeEditorSet.setOnClickListener {
            if (challengeDifficulty != null) {
                when (challengeDifficulty) {
                    0 -> year.yearChallengeBooks = 0
                    1 -> year.yearChallengeBooks = 1
                    2 -> year.yearChallengeBooks = 2
                    3 -> year.yearChallengeBooks = 3
                    4 -> year.yearChallengeBooks = 4
                }
                challengeDialogListener.onSaveButtonClicked(year)
                dismiss()
            } else {
                Snackbar.make(
                    it,
                    R.string.warning_challenge_difficulty_not_set,
                    Snackbar.LENGTH_SHORT
                ).show()
            }
        }
    }

    fun View.hideKeyboard() {
        val inputManager =
            context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        inputManager.hideSoftInputFromWindow(windowToken, 0)
    }

    fun showKeyboard(et: EditText, delay: Long) {
        val timer = Timer()
        timer.schedule(object : TimerTask() {
            override fun run() {
                val inputManager =
                    context.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
                inputManager.showSoftInput(et, 0)
            }
        }, delay)
    }

    fun getAccentColor(context: Context): Int {
        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        val sharedPref =
            context.getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when (accent) {
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor =
                ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.orange_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor =
                ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor =
                ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor =
                ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor =
                ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor =
                ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor =
                ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor =
                ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }
}