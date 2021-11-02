package software.mdev.bookstracker.ui.bookslist.fragments

import android.app.Activity
import android.content.SharedPreferences
import android.content.SharedPreferences.OnSharedPreferenceChangeListener
import android.os.Bundle
import android.widget.LinearLayout
import android.widget.Toast
import androidx.navigation.fragment.findNavController
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import androidx.preference.PreferenceManager
import com.google.android.material.bottomsheet.BottomSheetDialog
import software.mdev.bookstracker.R
import software.mdev.bookstracker.other.Constants
import software.mdev.bookstracker.other.Updater
import software.mdev.bookstracker.ui.bookslist.ListActivity
import software.mdev.bookstracker.ui.bookslist.viewmodel.BooksViewModel
import android.content.Intent
import android.net.Uri
import android.os.Build


class SettingsFragment : PreferenceFragmentCompat(), OnSharedPreferenceChangeListener {

    private lateinit var viewModel: BooksViewModel

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.preferences, rootKey)
        viewModel = (activity as ListActivity).booksViewModel

        val preferenceCheckForUpdates = findPreference<Preference>(Constants.KEY_CHECK_FOR_UPDATES)
        val preferenceTrash = findPreference<Preference>(Constants.KEY_TRASH)
        val preferenceChangelog = findPreference<Preference>(Constants.KEY_CHANGELOG)
        val preferenceBackup = findPreference<Preference>(Constants.KEY_BACKUP)
        val preferenceFeedback = findPreference<Preference>(Constants.KEY_FEEDBACK)

        if (preferenceCheckForUpdates != null) {
            val updater = Updater()

            preferenceCheckForUpdates.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                context?.let { it1 ->
                    updater.checkForAppUpdate(it1, true)
                }
                true
            }
        }

        if (preferenceTrash != null) {
            preferenceTrash.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                findNavController().navigate(R.id.trashFragment, null)
                true
            }
        }

        if (preferenceChangelog != null) {
            preferenceChangelog.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                findNavController().navigate(R.id.changelogFragment, null)
                true
            }
        }

        if (preferenceBackup != null) {
            preferenceBackup.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                findNavController().navigate(R.id.settingsBackupFragment, null)
                true
            }
        }

        if (preferenceFeedback != null) {
            preferenceFeedback.onPreferenceClickListener = Preference.OnPreferenceClickListener {
                showBottomSheetDialog()
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

    override fun onSharedPreferenceChanged(sharedPreferences: SharedPreferences, key: String) {
        when (key) {
            Constants.SHARED_PREFERENCES_KEY_ACCENT -> {
                hotReloadActivity(activity)
            }
            Constants.SHARED_PREFERENCES_KEY_RECOMMENDATIONS -> {
                Toast.makeText(context?.applicationContext, R.string.notYetImplemented, Toast.LENGTH_LONG).show()
            }
        }
    }

    private fun hotReloadActivity(activity: Activity?) {
        if (activity == null) return
        val sharedPref = PreferenceManager.getDefaultSharedPreferences(activity)
        sharedPref.edit().putBoolean(Constants.SHARED_PREFERENCES_REFRESHED, true).apply()
        activity.recreate()
    }

    private fun showBottomSheetDialog() {
        if (context != null) {
            val bottomSheetDialog =
                BottomSheetDialog(requireContext(), R.style.AppBottomSheetDialogTheme)
            bottomSheetDialog.setContentView(R.layout.bottom_sheet_contact_dev)

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llSendEmail)
                ?.setOnClickListener {
                    constructAnEmail()
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llOpenIssue)
                ?.setOnClickListener {
                    val i = Intent(Intent.ACTION_VIEW, Uri.parse(resources.getString(R.string.github_issue_url)))
                    startActivity(i)
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.findViewById<LinearLayout>(R.id.llOpenFeatureRequest)
                ?.setOnClickListener {
                    val i = Intent(Intent.ACTION_VIEW, Uri.parse(resources.getString(R.string.github_feature_url)))
                    startActivity(i)
                    bottomSheetDialog.dismiss()
                }

            bottomSheetDialog.show()
        }
    }

    private fun constructAnEmail() {
        val intent = Intent(Intent.ACTION_VIEW)
        val mail = requireContext().resources.getString(R.string.dev_mailto)
        val appName = requireContext().resources.getString(R.string.app_name)
        val appVersion = requireContext().resources.getString(R.string.app_version)
        val sdkVersion = android.os.Build.VERSION.SDK_INT

        val subject = "$appName feedback"
        val body = "\n\n\n\n" +
                "App name: $appName" + "\n" +
                "App version: $appVersion" + "\n" +
                "SDK: $sdkVersion" + "\n" +
                "Device: ${getDeviceName()}"

        val data: Uri = Uri.parse(
            "$mail?subject=" + Uri.encode(subject)
                .toString() + "&body=" + Uri.encode(body)
        )
        intent.data = data
        startActivity(intent)
    }

    fun getDeviceName(): String? {
        val manufacturer = Build.MANUFACTURER
        val model = Build.MODEL
        return if (model.toLowerCase().startsWith(manufacturer.toLowerCase())) {
            capitalize(model)
        } else {
            capitalize(manufacturer) + " " + model
        }
    }


    private fun capitalize(s: String?): String {
        if (s == null || s.length == 0) {
            return ""
        }
        val first = s[0]
        return if (Character.isUpperCase(first)) {
            s
        } else {
            Character.toUpperCase(first).toString() + s.substring(1)
        }
    }
}