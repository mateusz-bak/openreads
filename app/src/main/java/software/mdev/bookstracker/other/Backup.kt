package software.mdev.bookstracker.other

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import androidx.core.content.FileProvider.getUriForFile
import software.mdev.bookstracker.BuildConfig
import software.mdev.bookstracker.R
import software.mdev.bookstracker.api.RetrofitInstance.Companion.gson
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.ui.bookslist.ListActivity
import java.io.File
import java.io.FileOutputStream
import java.text.SimpleDateFormat
import java.util.*


class Backup {

    fun exportAndShare(activity: ListActivity) {
        val thread = Thread {
            val exported = exportBackupAsCsv(activity)
            if (exported.isNotBlank()) shareBackup(exported, activity)
        }
        thread.start()
    }

    // Export the room database to a file in Android/data/software.mdev.bookstracker(.debug)/files
    private fun exportBackupAsCsv(context: Context): String {
        // Perform a checkpoint to empty the write ahead logging temporary files and avoid closing the entire db
        val getBooksDao = BooksDatabase.getBooksDatabase(context).getBooksDao()

        val books = getBooksDao.getBooksForBackup()
        val booksJson = gson.toJson(books)

        val appDirectory = File(context.getExternalFilesDir(null)!!.absolutePath)

        val sdf = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss")
        val currentDate = sdf.format(Date())

        val fileName = "openreads_$currentDate.backup"
        val fileFullPath: String = appDirectory.path + File.separator.toString() + fileName

        // Snackbar need the ui thread to work, so they must be forced on that thread
        try {
            File(fileFullPath).writeText(booksJson)
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
    suspend fun importBackup(context: Context, fileUri: Uri): Boolean {
        when (validateBackup(fileUri, context)) {
            1 -> {
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
                restartActivity(context)
                return true
            }
            2 -> {
                BooksDatabase.destroyInstance()

                val fileStream = context.contentResolver.openInputStream(fileUri)!!
                val json = fileStream.readBytes().toString(Charsets.UTF_8)

                try {
                    val booksBackup = gson.fromJson(json, Array<Book>::class.java).toList()

                    val getBooksDao = BooksDatabase.getBooksDatabase(context).getBooksDao()
                    val books = getBooksDao.getBooksForBackup()

                    for (book in books)
                            getBooksDao.delete(book)

                    for (book in booksBackup)
                            getBooksDao.upsert(book)

                    (context as ListActivity).showSnackbar(context.getString(R.string.backup_import_success))
                } catch (e: Exception) {
                    val string = context.getString(R.string.backup_import_failure) + " ERROR: ${e.toString()}"
                    (context as ListActivity).showSnackbar(string)
                    e.printStackTrace()
                    return false
                }
                restartActivity(context)
                return true
            }
            else -> {
                (context as ListActivity).showSnackbar(context.getString(R.string.backup_import_invalid_file))
                return false
            }
        }
    }

    private fun restartActivity(context: Context) {
        // Completely restart the application with a slight delay to be extra-safe
        val intent: Intent =
            (context as ListActivity).baseContext.packageManager.getLaunchIntentForPackage((context as ListActivity).baseContext.packageName)!!
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK)
        Handler(Looper.getMainLooper()).postDelayed({ (context as ListActivity).startActivity(intent) }, 400)
    }

    // Check if a backup file is valid. A wrong import would result in a crash or empty db
    private fun validateBackup(fileUri: Uri, context: Context): Int {
        val uri = fileUri.path ?: ""

        return if (uri.contains("books_tracker_", true)) {
            1
        } else if (uri.contains("openreads_", true)) {
            2
        } else
            0
    }
}