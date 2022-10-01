package software.mdev.bookstracker.other

import android.content.Context
import android.content.Intent
import androidx.activity.result.contract.ActivityResultContracts
import software.mdev.bookstracker.R
import java.text.SimpleDateFormat
import java.util.*

class ExportHelper(private var fileName: String = "") :
    ActivityResultContracts.CreateDocument("application/zip") {
    override fun createIntent(context: Context, input: String): Intent {
        val intent = super.createIntent(context, input)
        if (fileName.isBlank()) {
            fileName = getDefaultExportFileName(context)
        }
        fileName += ".zip"
        intent.putExtra(Intent.EXTRA_TITLE, fileName)
        return intent
    }

    private fun getDefaultExportFileName(context: Context): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss")
        val currentDate = sdf.format(Date())

        val appVersion = context.resources.getString(R.string.app_version)
        val backupVersion = Constants.BACKUP_VERSION
        return "openreads_${backupVersion}_${appVersion}_${currentDate}"
    }
}
