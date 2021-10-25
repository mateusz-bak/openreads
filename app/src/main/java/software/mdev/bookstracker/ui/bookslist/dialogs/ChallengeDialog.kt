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
import com.google.android.material.slider.Slider
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

        var string = context.applicationContext.getString(R.string.tvChallengeEditorTitle) + " " + year.year
        tvChallengeEditorTitle.text = string

        if (year.yearChallengeBooks != null) {
            etChallengeEditorBooksNumber.setText(year.yearChallengeBooks.toString())
        } else {
            etChallengeEditorBooksNumber.setText("0")
        }

        etChallengeEditorBooksNumber.requestFocus()
        etChallengeEditorBooksNumber.setSelection(etChallengeEditorBooksNumber.text.toString().length)

        btnChallengeEditorSet.setOnClickListener {
            var chosenDifficulty = etChallengeEditorBooksNumber.text.toString()

            if (chosenDifficulty.isNotEmpty()) {

                if (chosenDifficulty.toInt() > 0) {
                    year.yearChallengeBooks = etChallengeEditorBooksNumber.text.toString().toInt()
                    challengeDialogListener.onSaveButtonClicked(year)
                    dismiss()
                } else {
                    Snackbar.make(
                        it,
                        R.string.warning_challenge_difficulty_not_set,
                        Snackbar.LENGTH_SHORT
                    ).show()
                }
            } else {
                Snackbar.make(
                    it,
                    R.string.warning_challenge_difficulty_not_set,
                    Snackbar.LENGTH_SHORT
                ).show()
            }
        }

        btnChallengeEditorCancel.setOnClickListener {
            dismiss()
        }

        slChallenge.addOnChangeListener(Slider.OnChangeListener { slider, value, fromUser ->
            etChallengeEditorBooksNumber.setText(value.toInt().toString())
            etChallengeEditorBooksNumber.requestFocus()
            etChallengeEditorBooksNumber.setSelection(etChallengeEditorBooksNumber.text.toString().length)
        })
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

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

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