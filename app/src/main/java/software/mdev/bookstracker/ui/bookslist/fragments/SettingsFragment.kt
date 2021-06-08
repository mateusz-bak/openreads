package software.mdev.bookstracker.ui.bookslist.fragments

import android.app.Activity
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.os.Bundle
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.PreferenceManager
import software.mdev.bookstracker.R
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel


class SettingsFragment : PreferenceFragmentCompat(), OnSharedPreferenceChangeListener {

    private lateinit var viewModel: BooksViewModel

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.preferences, rootKey)
        viewModel = (activity as ListActivity).booksViewModel
    }

    override fun onResume() {
        super.onResume()
        preferenceScreen.sharedPreferences
            .registerOnSharedPreferenceChangeListener(this)
    }

    override fun onPause() {
        super.onPause()
        preferenceScreen.sharedPreferences
            .unregisterOnSharedPreferenceChangeListener(this)
    }

    override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences, key: String) {
        when (key) {
            "accent_color" -> hotReloadActivity(activity)
        }
    }

    private fun hotReloadActivity(activity: Activity?) {
        if (activity == null) return
        val sharedPrefs = PreferenceManager.getDefaultSharedPreferences(activity)
        sharedPrefs.edit().putBoolean("refreshed", true).apply()
        activity.recreate()
    }
}