package software.mdev.bookstracker.ui.bookslist.fragments

import android.app.Activity
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.os.Bundle
import android.widget.Toast
import androidx.navigation.fragment.findNavController
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.PreferenceManager
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_KEY_ACCENT
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_KEY_RECOMMENDATIONS
import software.mdev.bookstracker.other.Constants.SHARED_PREFERENCES_REFRESHED
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
            SHARED_PREFERENCES_KEY_ACCENT -> {
                Toast.makeText(context?.applicationContext, R.string.changes_after_app_restart, Toast.LENGTH_LONG).show()
                hotReloadActivity(activity)
            }
            SHARED_PREFERENCES_KEY_RECOMMENDATIONS -> {
                Toast.makeText(context?.applicationContext, R.string.notYetImplemented, Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun hotReloadActivity(activity: Activity?) {
        if (activity == null) return
        val sharedPref = PreferenceManager.getDefaultSharedPreferences(context?.applicationContext)
        sharedPref.edit().putBoolean(SHARED_PREFERENCES_REFRESHED, true).apply()
        findNavController().navigate(R.id.settingsFragment, null)
    }
}