package software.mdev.bookstracker.ui.bookslist.dialogs

import android.content.Context
import android.graphics.Color
import android.graphics.Typeface
import android.graphics.drawable.ColorDrawable
import android.os.Bundle
import android.view.View
import android.view.Window
import software.mdev.bookstracker.R
import androidx.appcompat.app.AppCompatDialog
import androidx.core.content.ContextCompat
import androidx.recyclerview.widget.LinearLayoutManager
import kotlinx.android.synthetic.main.dialog_filter_books.*
import software.mdev.bookstracker.adapters.YearsAdapter
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity


class FilterBooksDialog(
    var view: View,
    var filterBooksDialogListener: FilterBooksDialogListener,
    var years: Array<String>,
    var listActivity: ListActivity
) : AppCompatDialog(view.context) {

    private var onlyFav = false

    override fun onCreate(savedInstanceState: Bundle?) {

        super.onCreate(savedInstanceState)
        supportRequestWindowFeature(Window.FEATURE_NO_TITLE)
        setContentView(R.layout.dialog_filter_books)

        this.window?.setBackgroundDrawable(ColorDrawable(Color.TRANSPARENT))

        val yearsAdapter = YearsAdapter(view.context, listActivity)
        rvYears.adapter = yearsAdapter
        rvYears.layoutManager = LinearLayoutManager(view.context)

        yearsAdapter.differ.submitList(years.toList())

        setInitialStateOfOnlyFav()

        clOnlyFav.setOnClickListener {
            if (cbOnlyFav.isChecked) {
                onlyFavHighlight(false)
                onlyFav = false
            } else {
                onlyFavHighlight(true)
                onlyFav = true
            }
        }

        btnFilterExecute.setOnClickListener {
            filterBooksDialogListener.onSaveFilterButtonClicked()
            saveOnlyFavPref(onlyFav)
            dismiss()
        }
    }

    private fun setInitialStateOfOnlyFav() {
        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = (listActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        onlyFavHighlight(sharedPref.getBoolean(Constants.SHARED_PREFERENCES_KEY_ONLY_FAV, false))

    }

    private fun onlyFavHighlight(b: Boolean) {
        if (b) {
            cbOnlyFav.isChecked = true
            tvOnlyFav.setTextColor(getAccentColor(context))
            tvOnlyFav.setTypeface(null, Typeface.BOLD)
            onlyFav = true
        } else {
            cbOnlyFav.isChecked = false
            tvOnlyFav.setTextColor(ContextCompat.getColor(context, R.color.colorDefaultText))
            tvOnlyFav.setTypeface(null, Typeface.NORMAL)
            onlyFav = false
        }
    }

    private fun saveOnlyFavPref(onlyFav: Boolean) {
        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = (listActivity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
        val editor = sharedPref.edit()
        editor.putBoolean(Constants.SHARED_PREFERENCES_KEY_ONLY_FAV, onlyFav)
        editor.apply()
    }

    fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref =
            context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

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
