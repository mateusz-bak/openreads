package software.mdev.bookstracker.other

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider.getUriForFile
import androidx.sqlite.db.SimpleSQLiteQuery
import software.mdev.bookstracker.R
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.ui.bookslist.ListActivity

import java.io.File
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
        val contentUri: Uri = getUriForFile(activity, "software.mdev.bookstracker.fileprovider", file)
        val shareIntent = Intent().apply {
            action = Intent.ACTION_SEND
            putExtra(Intent.EXTRA_STREAM, contentUri)
            type = "*/*"
        }
        // Verify that the intent will resolve to an activity
        if (shareIntent.resolveActivity(activity.packageManager) != null)
            activity.startActivity(shareIntent)
    }
}