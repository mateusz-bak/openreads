package software.mdev.bookstracker.other

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.ProgressBar
import androidx.core.content.FileProvider.getUriForFile
import kotlinx.android.synthetic.main.fragment_add_book_search.*
import kotlinx.coroutines.*
import software.mdev.bookstracker.BuildConfig
import software.mdev.bookstracker.R
import software.mdev.bookstracker.api.RetrofitInstance.Companion.gson
import software.mdev.bookstracker.data.db.BooksDatabase
import software.mdev.bookstracker.data.db.YearDatabase
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.data.db.entities.Year
import software.mdev.bookstracker.ui.bookslist.ListActivity
import java.io.*
import java.lang.StringBuilder
import java.text.SimpleDateFormat
import java.util.*
import java.util.zip.GZIPInputStream
import java.util.zip.GZIPOutputStream


class Backup {

    fun exportAndShare(activity: ListActivity, share: Boolean) {
        CoroutineScope(Dispatchers.IO).launch {
            controlProgressBar(activity, true)

            val exported = exportBackupAsCsv(activity)
            if (share && exported.isNotBlank()) shareBackup(exported, activity)

            controlProgressBar(activity, false)
        }
    }

    // Export the room database to a file in Android/data/software.mdev.bookstracker(.debug)/files
    private fun exportBackupAsCsv(context: Context): String {
        // Perform a checkpoint to empty the write ahead logging temporary files and avoid closing the entire db
        val getBooksDao = BooksDatabase.getBooksDatabase(context).getBooksDao()
        val getYearDao = YearDatabase.getYearDatabase(context).getYearDao()

        val books = getBooksDao.getBooksForBackup()
        val booksJson = gson.toJson(books)
        val years = getYearDao.getYearsForBackup()
        val yearsJson = gson.toJson(years)

        val combined = listOf(
            booksJson,
            yearsJson
        )
        val combinedJson = gson.toJson(combined)
        val compressedJson = compressString(combinedJson)

        val appDirectory = File(context.getExternalFilesDir(null)!!.absolutePath)

        val sdf = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss")
        val currentDate = sdf.format(Date())

        val fileName = "openreads_$currentDate.backup"
        val fileFullPath: String = appDirectory.path + File.separator.toString() + fileName

        // Snackbar need the ui thread to work, so they must be forced on that thread
        try {
            File(fileFullPath).writeBytes(compressedJson)
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
                controlProgressBar(context as ListActivity, true)
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

                controlProgressBar(context as ListActivity, false)
                restartActivity(context)
                return true
            }
            2 -> {
                controlProgressBar(context as ListActivity, true)
                BooksDatabase.destroyInstance()

                val fileStream = context.contentResolver.openInputStream(fileUri)!!
                val compressedJson = fileStream.readBytes()

                try {
                    val combinedJson = decompressString(compressedJson)
                    val combined = gson.fromJson(combinedJson, Array<String>::class.java).toList()

                    val booksJson = combined[0]
                    val yearsJson = combined[1]

                    val booksFromBackup = gson.fromJson(booksJson, Array<Book>::class.java).toList()
                    val yearsFromBackup = gson.fromJson(yearsJson, Array<Year>::class.java).toList()

                    val getBooksDao = BooksDatabase.getBooksDatabase(context).getBooksDao()
                    val getYearDao = YearDatabase.getYearDatabase(context).getYearDao()

                    val currentBooks = getBooksDao.getBooksForBackup()
                    val currentYears = getYearDao.getYearsForBackup()

                    for (book in currentBooks)
                        getBooksDao.delete(book)

                    for (year in currentYears)
                        getYearDao.delete(year)

                    for (book in booksFromBackup)
                        getBooksDao.upsert(book)

                    for (year in yearsFromBackup) {
                        getYearDao.upsert(year)
                    }

                    (context as ListActivity).showSnackbar(context.getString(R.string.backup_import_success))
                } catch (e: Exception) {
                    val string = context.getString(R.string.backup_import_failure) + " ERROR: ${e.toString()}"
                    (context as ListActivity).showSnackbar(string)
                    e.printStackTrace()
                    return false
                }
                controlProgressBar(context as ListActivity, false)
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

    @Throws(IOException::class)
    private fun compressString (data: String): ByteArray {
        val bos = ByteArrayOutputStream(data.length)
        val gzip = GZIPOutputStream(bos)
        gzip.write(data.toByteArray())
        gzip.close()
        val compressed: ByteArray = bos.toByteArray()
        bos.close()
        return compressed
    }

    @Throws(IOException::class)
    private fun decompressString (compressed: ByteArray?): String {
        val bis = ByteArrayInputStream(compressed)
        val gis = GZIPInputStream(bis)
        val br = BufferedReader(InputStreamReader(gis, "UTF-8"))
        val sb = StringBuilder()
        var line: String?
        while (br.readLine().also { line = it } != null) {
            sb.append(line)
        }
        br.close()
        gis.close()
        bis.close()
        return sb.toString()
    }

    private suspend fun controlProgressBar(activity: ListActivity, state: Boolean) {
        withContext(Dispatchers.Main) {
            val progressBar = activity.findViewById<ProgressBar>(R.id.pbActivityLoading)
            if (state)
                progressBar?.visibility = View.VISIBLE
            else
                progressBar?.visibility = View.INVISIBLE

            if (state)
                progressBar?.bringToFront()
        }
    }
}