package software.mdev.bookstracker.other

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.ProgressBar
import androidx.appcompat.app.AlertDialog
import androidx.core.content.FileProvider.getUriForFile
import androidx.sqlite.db.SimpleSQLiteQuery
import com.github.doyaaaaaken.kotlincsv.dsl.csvReader
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
import software.mdev.bookstracker.utils.FileUtils
import java.io.*
import java.lang.StringBuilder
import java.text.Normalizer
import java.text.SimpleDateFormat
import java.util.*
import java.util.zip.*


class Backup {

    fun exportAndShare(activity: ListActivity, share: Boolean, selectedPath: Uri? = null) {
        CoroutineScope(Dispatchers.IO).launch {
            controlProgressBar(activity, true)

            val exported = exportBackup(activity, selectedPath)
            if (share && exported.isNotBlank()) shareBackup(exported, activity)

            controlProgressBar(activity, false)
        }
    }

    private fun exportBackup(context: Context, selectedPath: Uri?): String {
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
        val backupVersion = Constants.BACKUP_VERSION
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
                context.showSnackbar(context.resources.getString(R.string.backup_export_success))
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
                context.showSnackbar(context.getString(R.string.backup_export_success))
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

        zipAll(context, fullPath, zipFilePath.absolutePath, selectedPath)

        File(booksFileFullPath).delete()
        File(yearsFileFullPath).delete()
        File(fullPath).delete()

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

    fun runExporter(activity: ListActivity) {
        activity.selectExportPath.launch("")
    }

    fun runImporter(activity: ListActivity) {
        activity.selectBackup.launch("*/*")
    }

    fun runImporterCSV(activity: ListActivity) {
        activity.selectCSV.launch("text/*")
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

    private fun importCSV(
        context: Context,
        fileUri: Uri,
        notFinishedShelf: String? = null
    ): Boolean {
        try {
            val fileStream = context.contentResolver.openInputStream(fileUri)!!
            val books = parseGoodReadsCSV(fileStream, notFinishedShelf)

            for (book in books)
                (context as ListActivity).booksViewModel.upsert(book)

            (context as ListActivity).showSnackbar(context.getString(R.string.backup_import_success))
        } catch (e: Exception) {
            val string = "${context.getString(R.string.csv_import_failure)}: $e"
            (context as ListActivity).showSnackbar(string)
            e.printStackTrace()
            return false
        }

        restartActivity(context)
        return true
    }

    fun decideNotFinishedShelf(context: Context, fileUri: Uri) {
        val fileStream = context.contentResolver.openInputStream(fileUri)!!
        val rows = csvReader().readAllWithHeader(fileStream)
        var notFinishedCandidates: MutableList<String> = ArrayList()

        for (row in rows) {
            if (row["Exclusive Shelf"] != null &&
                row["Exclusive Shelf"] != "" &&
                row["Exclusive Shelf"] != "read" &&
                row["Exclusive Shelf"] != "currently-reading" &&
                row["Exclusive Shelf"] != "to-read"
            )
                if (!notFinishedCandidates.contains(row["Exclusive Shelf"]!!))
                    notFinishedCandidates.add(row["Exclusive Shelf"]!!)
        }

        if (notFinishedCandidates.isNotEmpty()) {
            (context as ListActivity).runOnUiThread {
                AlertDialog.Builder(context)
                    .setTitle(context.getString(R.string.choose_a_shelf))
                    .setItems(notFinishedCandidates.toTypedArray()) { _, pos ->
                        importCSV(context, fileUri, notFinishedCandidates[pos])
                    }
                    .setPositiveButton(context.getString(R.string.skip_choosing_shelf)) { _, _ ->
                        importCSV(context, fileUri)
                    }
                    .show()
            }
        } else {
            importCSV(context, fileUri)
        }
    }

    private fun zipAll(context: Context, directory: String, zipFile: String, zipUri: Uri? = null) {
        val sourceFile = File(directory)
        val outputStream = if  (zipUri == null) {
            FileOutputStream(File(zipFile))
        } else {
            context.contentResolver.openOutputStream(zipUri)
        }

        ZipOutputStream(BufferedOutputStream(outputStream)).use { zos ->
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
        val uri = FileUtils.getFilenameFromUri(context, fileUri) ?: ""

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

    private fun parseGoodReadsCSV(inputStream: InputStream, notFinishedShelf: String?): List<Book> {
        val rows = csvReader().readAllWithHeader(inputStream)
        var newBooks: MutableList<Book> = ArrayList()

        for (row in rows)
            newBooks.add(parseGoodReadsBook(row, notFinishedShelf))

        return newBooks
    }

    private fun parseGoodReadsBook(row: Map<String, String>, notFinishedShelf: String?): Book {
        val regexUnaccented = "\\p{InCombiningDiacriticalMarks}+".toRegex()

        fun CharSequence.unaccented(): String {
            val temp = Normalizer.normalize(this, Normalizer.Form.NFD)
            return regexUnaccented.replace(temp, "")
        }

        val title = row["Title"] ?: Constants.EMPTY_STRING

        var author: String = row["Author"] ?: Constants.EMPTY_STRING
        val additionalAuthors = row["Additional Authors"] ?: Constants.EMPTY_STRING
        if (additionalAuthors.isNotEmpty())
            author = "$author, $additionalAuthors"

        var dateAdded = Constants.DATABASE_EMPTY_VALUE
        if (row["Date Added"]?.isNotEmpty() == true) {
            dateAdded = row["Date Added"]?.let {
                SimpleDateFormat("yyyy/MM/dd").parse(it).time
            }.toString()
        }

        var dateStarted = Constants.DATABASE_EMPTY_VALUE
        if (row["Date Started"]?.isNotEmpty() == true) {
            dateStarted = row["Date Started"]?.let {
                SimpleDateFormat("yyyy/MM/dd").parse(it).time
            }.toString()
        }

        // need to check if notFinishedShelf != null to assign proper status
        val bookStatus = if (notFinishedShelf != null) {
            when (row["Exclusive Shelf"]) {
                "currently-reading" -> Constants.BOOK_STATUS_IN_PROGRESS
                "to-read" -> Constants.BOOK_STATUS_TO_READ
                notFinishedShelf -> Constants.BOOK_STATUS_NOT_FINISHED
                else -> Constants.BOOK_STATUS_READ
            }
        } else {
            when (row["Exclusive Shelf"]) {
                "currently-reading" -> Constants.BOOK_STATUS_IN_PROGRESS
                "to-read" -> Constants.BOOK_STATUS_TO_READ
                else -> Constants.BOOK_STATUS_READ
            }
        }

        var dateFinished = Constants.DATABASE_EMPTY_VALUE
        if (row["Date Read"]?.isNotEmpty() == true) {
            dateFinished = row["Date Read"]?.let {
                SimpleDateFormat("yyyy/MM/dd").parse(it).time
            }.toString()
        } else if (bookStatus == Constants.BOOK_STATUS_READ) {
            dateFinished = dateAdded
        }

        var tags: List<String>? = emptyList()
        if (row["Bookshelves"]?.isNotEmpty() == true) {
            val unfilteredTags = row["Bookshelves"]!!.split(", ")
            for (unfilteredTag in unfilteredTags) {
                if (unfilteredTag != row["Exclusive Shelf"])
                    tags = tags!! + unfilteredTag
            }
        }
        if (tags?.isEmpty() == true)
            tags = null

        return Book(
            bookTitle = title,
            bookAuthor = author,
            bookRating = row["My Rating"]?.toFloatOrNull() ?: 0F,
            bookStatus = bookStatus,
            bookPriority = Constants.DATABASE_EMPTY_VALUE,
            bookStartDate = dateStarted,
            bookFinishDate = dateFinished,
            bookNumberOfPages = row["Number of Pages"]?.toIntOrNull() ?: 0,
            bookTitle_ASCII = title.unaccented().replace("ł", "l", false),
            bookAuthor_ASCII = author.unaccented().replace("ł", "l", false),
            bookIsDeleted = false,
            bookCoverUrl = Constants.DATABASE_EMPTY_VALUE,
            bookOLID = Constants.DATABASE_EMPTY_VALUE,
            bookISBN10 = row["ISBN"]?.removeSurrounding("=\"", "\"")
                ?: Constants.DATABASE_EMPTY_VALUE,
            bookISBN13 = row["ISBN13"]?.removeSurrounding("=\"", "\"")
                ?: Constants.DATABASE_EMPTY_VALUE,
            bookPublishYear = row["Original Publication Year"]?.toIntOrNull() ?: 0,
            bookIsFav = false,
            bookCoverImg = null,
            bookNotes = row["My Review"] ?: Constants.DATABASE_EMPTY_VALUE,
            bookTags = tags,
        )
    }
}