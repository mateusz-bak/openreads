package software.mdev.bookstracker.ui.bookslist.fragments

import android.Manifest
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.os.Build
import android.os.Bundle
import android.widget.Toast
import androidx.navigation.fragment.findNavController
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Functions
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import java.io.File
import java.lang.Exception
import java.text.SimpleDateFormat
import java.util.*


class SettingsBackupFragment : PreferenceFragmentCompat(), OnSharedPreferenceChangeListener {

    private lateinit var viewModel: BooksViewModel

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.preferences_backup, rootKey)
        viewModel = (activity as ListActivity).booksViewModel

        var preferenceExport = findPreference<Preference>(Constants.KEY_EXPORT)
        var preferenceImport = findPreference<Preference>(Constants.KEY_IMPORT)

        if (preferenceExport != null) {
            preferenceExport.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                exportDbToFile(activity as ListActivity)
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

    private fun exportDbToFile(activity: ListActivity) {
        val functions = Functions()
        if (functions.checkPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE)) {
            val database = BooksDatabase(activity.baseContext)
            database.close()

            when (Build.VERSION.SDK_INT) {
                in 1..28 -> exportDbToFileApi28AndLower(activity)
                29 -> exportDbToFileApi29(activity)
                30 -> exportDbToFileApi30(activity)
            }
        } else {
            functions.requestPermission(activity, Manifest.permission.WRITE_EXTERNAL_STORAGE)
        }
    }

    private fun exportDbToFileApi28AndLower(activity: ListActivity) {
        val dbFile: File = activity.baseContext.getDatabasePath("BooksDB.db")
        val sdf = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss")
        val currentDate = sdf.format(Date())
        val dbBackupFile = File("/sdcard/Backup/BooksTracker", "books_tracker_$currentDate.backup")

        try {
            dbFile.copyTo(dbBackupFile)
            Toast.makeText(activity.baseContext, R.string.backup_success, Toast.LENGTH_SHORT).show()
        } catch (e: Exception) {
            val error = e.toString()
            Toast.makeText(activity.baseContext, "Error: $error", Toast.LENGTH_SHORT).show()
        }
    }

    private fun exportDbToFileApi29(activity: ListActivity) {
        Toast.makeText(activity.baseContext, R.string.api_29_not_yet_supported, Toast.LENGTH_SHORT).show()
    }

    private fun exportDbToFileApi30(activity: ListActivity) {
        Toast.makeText(activity.baseContext, R.string.api_30_not_yet_supported, Toast.LENGTH_SHORT).show()
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