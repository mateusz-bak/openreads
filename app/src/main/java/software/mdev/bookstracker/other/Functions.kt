package software.mdev.bookstracker.other

import android.content.Context
import com.google.gson.Gson
import software.mdev.bookstracker.adapters.BookAdapter
import software.mdev.bookstracker.data.db.entities.Book
import software.mdev.bookstracker.ui.bookslist.ListActivity
import java.text.SimpleDateFormat
import java.util.*

class Functions {

    fun convertLongToYear(time: Long): String {
        val date = Date(time)
        val format = SimpleDateFormat("yyyy")
        return format.format(date)
    }

    fun convertYearToLong(year: String): Long {
        val timeStamp = SimpleDateFormat("yyyy").parse(year)
        return timeStamp.time
    }

    fun calculateYearsFromDb(listOfBooks: List<Book>): Array<String> {
        var arrayOfYears: Array<String>

        var years = listOf<String>()
        var year: Int

        for (item in listOfBooks) {
            if (item.bookFinishDate != "null" && item.bookFinishDate != "none") {
                year = convertLongToYear(item.bookFinishDate.toLong()).toInt()
                if (year.toString() !in years) {
                    years = years + year.toString()
                }
            }
        }

        arrayOfYears = years.toTypedArray()
        return arrayOfYears
    }


    fun filterBooksList(
        activity: ListActivity,
        bookAdapter: BookAdapter,
        notFilteredBooks: List<Book>
    ) {
        val sharedPref =
            (activity).getSharedPreferences(Constants.SHARED_PREFERENCES_NAME, Context.MODE_PRIVATE)
        var filteredBooks: List<Book> = emptyList()

        var gson1 = Gson()
        var emptyArray1: Array<String> =
            arrayOf(Calendar.getInstance().get(Calendar.YEAR).toString())
        var jsonString1 = gson1.toJson(emptyArray1)
        jsonString1 =
            sharedPref.getString(Constants.SHARED_PREFERENCES_KEY_FILTER_YEARS, jsonString1)
        var currentArray1 = gson1.fromJson(jsonString1, Array<String>::class.java).toList()


        for (book in notFilteredBooks) {
            for (yearToBeShown in currentArray1) {
                val startTimeStamp = convertYearToLong(yearToBeShown)
                val endTimeStamp = convertYearToLong((yearToBeShown.toInt() + 1).toString())

                if (book.bookFinishDate != "null" && book.bookFinishDate != "none") {
                    if (book.bookFinishDate.toLong() in startTimeStamp..endTimeStamp) {
                        filteredBooks += book
                    }
                }
            }
        }

        bookAdapter.differ.submitList(filteredBooks)
    }
}