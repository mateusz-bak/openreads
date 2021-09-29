package software.mdev.bookstracker.other

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.core.content.FileProvider.getUriForFile
import androidx.sqlite.db.SimpleSQLiteQuery
import software.mdev.bookstracker.BuildConfig
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.ui.bookslist.ListActivity
import java.io.File
import java.io.FileOutputStream
import java.io.InputStreamReader
import java.text.SimpleDateFormat
import java.util.*


class Backup {

    fun exportAndShare(activity: ListActivity) {
        val thread = Thread {
            val exported = exportBackup(activity)
            if (exported.isNotBlank()) shareBackup(exported, activity)
        }
        thread.start()
    }

    // Export the room database to a file in Android/data/software.mdev.bookstracker(.debug)/files
    private fun exportBackup(context: Context): String {
        // Perform a checkpoint to empty the write ahead logging temporary files and avoid closing the entire db
        val getBooksDao = BooksDatabase.getBooksDatabase(context).getBooksDao()
        getBooksDao.checkpoint(SimpleSQLiteQuery("pragma wal_checkpoint(full)"))

        val dbFile = context.getDatabasePath(Constants.DATABASE_FILE_NAME).absoluteFile
        val appDirectory = File(context.getExternalFilesDir(null)!!.absolutePath)

        val sdf = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss")
        val currentDate = sdf.format(Date())

        val fileName = "books_tracker_$currentDate.backup"
        val fileFullPath: String = appDirectory.path + File.separator.toString() + fileName

        // Snackbar need the ui thread to work, so they must be forced on that thread
        try {
            dbFile.copyTo(File(fileFullPath), true)
            (context as ListActivity).runOnUiThread {
                (context as ListActivity).showSnackbar(context.getString(R.string.backup_success))
            }
        } catch (e: Exception) {
            (context as ListActivity).runOnUiThread {
                val string = context.getString(R.string.backup_failure) + " ERROR: ${e.toString()}"
                (context as ListActivity).showSnackbar(string)
            }
            e.printStackTrace()
            return ""
        }
        return fileFullPath
    }

    // Share the backup to a supported app
    private fun shareBackup(fileUri: String, activity: ListActivity) {
        val file = File(fileUri)
        val contentUri: Uri = getUriForFile(activity, "${BuildConfig.APPLICATION_ID}.fileprovider", file)
        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_STREAM, contentUri)
            type = "*/*"
        }
        // Verify that the intent will resolve to an activity
        if (shareIntent.resolveActivity(activity.packageManager) != null)
            activity.startActivity(shareIntent)
    }

    fun runImporter(activity: ListActivity) {
        activity.selectBackup.launch("*/*")
    }

    // Import a backup overwriting any existing data and checking if the file is valid
    fun importBackup(context: Context, fileUri: Uri): Boolean {
        if (!isBackupValid(fileUri, context)) {
            (context as ListActivity).showSnackbar(context.getString(R.string.backup_import_invalid_file))
            return false
        }

        BooksDatabase.destroyInstance()

        val fileStream = context.contentResolver.openInputStream(fileUri)!!
        val dbFile = context.getDatabasePath(Constants.DATABASE_FILE_NAME).absoluteFile

        try {
            fileStream.copyTo(FileOutputStream(dbFile))
            (context as ListActivity).showSnackbar(context.getString(R.string.backup_import_success))
        } catch (e: Exception) {
            val string = context.getString(R.string.backup_import_failure) + " ERROR: ${e.toString()}"
            (context as ListActivity).showSnackbar(string)
            e.printStackTrace()
            return false
        }
        // Completely restart the application with a slight delay to be extra-safe
        val intent: Intent =
            (context as ListActivity).baseContext.packageManager.getLaunchIntentForPackage((context as ListActivity).baseContext.packageName)!!
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
        Handler(Looper.getMainLooper()).postDelayed({ (context as ListActivity).startActivity(intent) }, 400)
        return true
    }

    // Check if a backup file is valid. A wrong import would result in a crash or empty db
    private fun isBackupValid(fileUri: Uri, context: Context): Boolean {
        val uri = fileUri.path ?: ""

        // An initial, naive validation
        if (!(uri.contains("books_tracker", true) ||
                    uri.contains("document", true) ||
                    uri.contains("external", true))
        ) {
            (context as ListActivity).showSnackbar(uri.toString())
            return false
        }

        // Read the first bytes of the file: every SQLite DB starts with the same string
        val fileStream = context.contentResolver.openInputStream(fileUri)!!
        try {
            val fr = InputStreamReader(fileStream)
            val buffer = CharArray(16)
            fr.read(buffer, 0, 16)
            val str = String(buffer)
            fr.close()
            if (str == "SQLite format 3\u0000")
                return true
        } catch (e: java.lang.Exception) {
            (context as ListActivity).showSnackbar(e.toString())
            e.printStackTrace()
            return false
        }
        return false
    }
}