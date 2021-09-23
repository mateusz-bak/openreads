package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.os.Bundle
import android.widget.Toast
import androidx.navigation.fragment.findNavController
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Backup
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import java.io.File


class SettingsBackupFragment : PreferenceFragmentCompat(), OnSharedPreferenceChangeListener {

    private lateinit var viewModel: BooksViewModel

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.preferences_backup, rootKey)
        viewModel = (activity as ListActivity).booksViewModel

        var preferenceExport = findPreference<Preference>(Constants.KEY_EXPORT)
        var preferenceImport = findPreference<Preference>(Constants.KEY_IMPORT)

        if (preferenceExport != null) {
            preferenceExport.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                Backup().exportAndShare(activity as ListActivity)
                true
            }
        }

        if (preferenceImport != null) {
            preferenceImport.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                lookForDbBackups(activity as ListActivity, this)
                true
            }
        }
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

    override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences?, key: String?) {
    }

    private fun lookForDbBackups(activity: ListActivity, fragment: SettingsBackupFragment) {
        val files = File("/sdcard/Backup/BooksTracker").listFiles()

        if (files != null) {
            if (files.isNotEmpty()) {
                fragment.findNavController().navigate(R.id.restoreBackupFragment, null)
            } else {
                Toast.makeText(activity.baseContext, R.string.no_backups_found, Toast.LENGTH_SHORT).show()
            }
        } else {
            Toast.makeText(activity.baseContext, R.string.no_backups_found, Toast.LENGTH_SHORT).show()
        }
    }
}