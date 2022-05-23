package software.mdev.bookstracker.other

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.ProgressBar
import androidx.core.content.FileProvider.getUriForFile
import androidx.sqlite.db.SimpleSQLiteQuery
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
import java.util.zip.*


class Backup {

    fun exportAndShare(activity: ListActivity, share: Boolean) {
        CoroutineScope(Dispatchers.IO).launch {
            controlProgressBar(activity, true)

            val exported = exportBackup(activity)
            if (share && exported.isNotBlank()) shareBackup(exported, activity)

            controlProgressBar(activity, false)
        }
    }

    private fun exportBackup(context: Context): String {
        // Perform a checkpoint to empty the write ahead logging temporary files and avoid closing the entire db
        val booksDao = BooksDatabase.getBooksDatabase(context).getBooksDao()
        booksDao.checkpoint(SimpleSQLiteQuery("pragma wal_checkpoint(full)"))
        val booksDbFile = context.getDatabasePath(Constants.DATABASE_FILE_NAME).absoluteFile

        val yearsDao = YearDatabase.getYearDatabase(context).getYearDao()
        yearsDao.checkpoint(SimpleSQLiteQuery("pragma wal_checkpoint(full)"))
        val yearsDbFile = context.getDatabasePath(Constants.DATABASE_YEAR_FILE_NAME).absoluteFile

        val appDirectory = File(context.getExternalFilesDir(null)!!.absolutePath)

        val sdf = SimpleDateFormat("yyyy-MM-dd_HH-mm-ss")
        val currentDate = sdf.format(Date())

        val appVersion = context.resources.getString(R.string.app_version)
        val backupVersion = "3"
        val backupName = "openreads_${backupVersion}_${appVersion}_${currentDate}"

        val booksFileName = "books.sql"
        val booksFileFullPath: String = appDirectory.path + File.separator.toString() + backupName +
                File.separator.toString() + booksFileName

        val yearsFileName = "years.sql"
        val yearsFileFullPath: String = appDirectory.path + File.separator.toString() + backupName +
                File.separator.toString() + yearsFileName

        // Snackbar need the ui thread to work, so they must be forced on that thread
        try {
            booksDbFile.copyTo(File(booksFileFullPath), true)
            (context as ListActivity).runOnUiThread {
                context.showSnackbar(context.getString(R.string.backup_success))
            }
        } catch (e: Exception) {
            (context as ListActivity).runOnUiThread {
                val string = "${context.getString(R.string.backup_failure)} ERROR: $e"
                context.showSnackbar(string)
            }
            e.printStackTrace()
            return ""
        }

        try {
            yearsDbFile.copyTo(File(yearsFileFullPath), true)
            context.runOnUiThread {
                context.showSnackbar(context.getString(R.string.backup_success))
            }
        } catch (e: Exception) {
            context.runOnUiThread {
                val string = "${context.getString(R.string.backup_failure)} ERROR: $e"
                context.showSnackbar(string)
            }
            e.printStackTrace()
            return ""
        }

        val fullPath: String = appDirectory.path + File.separator.toString() + backupName
        val zipFilePath = File(appDirectory.path, "$backupName.zip")// new zip file

        zipAll(fullPath, zipFilePath.absolutePath)

        File(booksFileFullPath).delete()
        File(yearsFileFullPath).delete()
        File(appDirectory.path + File.separator.toString() + backupName).delete()

        return zipFilePath.absolutePath
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

            3 -> {
                controlProgressBar(context as ListActivity, true)

                try {
                    BooksDatabase.destroyInstance()
                    YearDatabase.destroyInstance()

                    val fileStream = context.contentResolver.openInputStream(fileUri)!!

                    val booksDbFile =
                        context.getDatabasePath(Constants.DATABASE_FILE_NAME).absoluteFile
                    val yearsDbFile =
                        context.getDatabasePath(Constants.DATABASE_YEAR_FILE_NAME).absoluteFile

                    val appDirectory = File(context.getExternalFilesDir(null)!!.absolutePath)
                    val tempDir = appDirectory.path + File.separator.toString() + "temp"
                    val unzippedDir = appDirectory.path + File.separator.toString() + "unzipped"

                    fileStream.copyTo(FileOutputStream(tempDir))
                    File(tempDir).unzip(File(unzippedDir))

                    val unzippedBooksDbFile = unzippedDir + File.separator.toString() + "books.sql"
                    val unzippedYearsDbFile = unzippedDir + File.separator.toString() + "years.sql"

                    val booksFIS = FileInputStream(unzippedBooksDbFile)
                    val yearsFIS = FileInputStream(unzippedYearsDbFile)

                    booksFIS.copyTo(FileOutputStream(booksDbFile))
                    yearsFIS.copyTo(FileOutputStream(yearsDbFile))

                    File(unzippedBooksDbFile).delete()
                    File(unzippedYearsDbFile).delete()
                    File(unzippedDir).delete()
                    File(tempDir).delete()

                    context.showSnackbar(context.getString(R.string.backup_import_success))
                } catch (e: Exception) {
                    val string = "${context.getString(R.string.backup_import_failure)} ERROR: $e"
                    context.showSnackbar(string)
                    e.printStackTrace()
                    return false
                }

                controlProgressBar(context, false)
                restartActivity(context)
                return true
            }
            else -> {
                (context as ListActivity).showSnackbar(context.getString(R.string.backup_import_invalid_file))
                return false
            }
        }
    }

    private fun zipAll(directory: String, zipFile: String) {
        val sourceFile = File(directory)
        val outputZipFile = File(zipFile)

        ZipOutputStream(BufferedOutputStream(FileOutputStream(outputZipFile))).use { zos ->
            sourceFile.walkTopDown().forEach { file ->
                val zipFileName =
                    file.absolutePath.removePrefix(sourceFile.absolutePath).removePrefix("/")
                val entry = ZipEntry("$zipFileName${(if (file.isDirectory) "/" else "")}")
                zos.putNextEntry(entry)
                if (file.isFile) {
                    file.inputStream().copyTo(zos)
                }
            }
        }
    }

    fun File.unzip(to: File? = null) {
        val destinationDir = to ?: File(parentFile, nameWithoutExtension)
        destinationDir.mkdirs()

        ZipFile(this).use { zipFile ->
            zipFile
                .entries()
                .asSequence()
                .filter { !it.isDirectory }
                .forEach { zipEntry ->
                    val currFile = File(destinationDir, zipEntry.name)
                    currFile.parentFile?.mkdirs()
                    zipFile.getInputStream(zipEntry).use { input ->
                        currFile.outputStream().use { output -> input.copyTo(output) }
                    }
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
            // First backup convention - only books db
            1
        } else if (uri.contains("openreads_3_", true)) {
            // Third convention - books and years dbs zipped
            3
        } else if (uri.contains("openreads_", true)) {
            // Second backup convention - books & years in a JSON (very slow)
            2
        } else
            0
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