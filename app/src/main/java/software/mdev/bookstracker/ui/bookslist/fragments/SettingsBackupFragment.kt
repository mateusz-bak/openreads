package software.mdev.bookstracker.ui.bookslist.fragments

import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.os.Bundle
import androidx.appcompat.app.AlertDialog
import androidx.core.content.ContextCompat
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Backup
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel


class SettingsBackupFragment : PreferenceFragmentCompat(), OnSharedPreferenceChangeListener {

    private lateinit var viewModel: BooksViewModel

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.preferences_backup, rootKey)
        viewModel = (activity as ListActivity).booksViewModel

        var preferenceExport = findPreference<Preference>(Constants.KEY_EXPORT)
        var preferenceExportLocal = findPreference<Preference>(Constants.KEY_EXPORT_LOCAL)
        var preferenceImport = findPreference<Preference>(Constants.KEY_IMPORT)
        val preferenceCsvImport = findPreference<Preference>(Constants.KEY_CSV_IMPORT)

        if (preferenceExport != null) {
            preferenceExport.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                Backup().exportAndShare(activity as ListActivity, true)
                true
            }
        }

        if (preferenceExportLocal != null) {
            preferenceExportLocal.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                Backup().runExporter(activity as ListActivity)
                true
            }
        }

        if (preferenceImport != null) {
            preferenceImport.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                confirmBackupImportAndExecute(activity as ListActivity)
                true
            }
        }

        if (preferenceCsvImport != null) {
            preferenceCsvImport.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                Backup().runImporterCSV(activity as ListActivity)
                true
            }
        }
    }

    override fun onResume() {
        super.onResume()
        preferenceScreen.sharedPreferences
            ?.registerOnSharedPreferenceChangeListener(this)
    }

    override fun onPause() {
        super.onPause()
        preferenceScreen.sharedPreferences
            ?.unregisterOnSharedPreferenceChangeListener(this)
    }

    override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences?, key: String?) {
    }

    private fun confirmBackupImportAndExecute(activity: ListActivity) {
        val restoreBackupWarningDialog = this.context?.let { it1 ->
            AlertDialog.Builder(it1)
                .setTitle(R.string.restore_backup_warning_title)
                .setMessage(R.string.restore_backup_warning_message)
                .setIcon(R.drawable.ic_iconscout_exclamation_triangle_24)
                .setNegativeButton(R.string.warning_take_me_back) { _, _ ->
                }
                .setPositiveButton(R.string.warning_understand) { _, _ ->
                    Backup().runImporter(activity)
                }
                .create()
        }

        restoreBackupWarningDialog?.show()
        restoreBackupWarningDialog?.getButton(AlertDialog.BUTTON_NEGATIVE)?.setTextColor(ContextCompat.getColor(activity.baseContext, R.color.grey_500))
    }
}