package software.mdev.bookstracker.other

import android.content.Context
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.gson.Gson
import software.mdev.bookstracker.R
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
        var sharedPreferencesName = activity.getString(R.string.shared_preferences_name)
        val sharedPref = (activity).getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)
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
                        if (book !in filteredBooks)
                            filteredBooks += book
                    }
                } else {
                    if (book !in filteredBooks)
                        filteredBooks += book
                }
            }
        }

        bookAdapter.differ.submitList(filteredBooks)
    }

    fun getAccentColor(context: Context): Int {

        var accentColor = ContextCompat.getColor(context, R.color.purple_500)

        var sharedPreferencesName = context.getString(R.string.shared_preferences_name)
        val sharedPref = context.getSharedPreferences(sharedPreferencesName, Context.MODE_PRIVATE)

        var accent = sharedPref?.getString(
            Constants.SHARED_PREFERENCES_KEY_ACCENT,
            Constants.THEME_ACCENT_DEFAULT
        ).toString()

        when(accent){
            Constants.THEME_ACCENT_LIGHT_GREEN -> accentColor = ContextCompat.getColor(context, R.color.light_green)
            Constants.THEME_ACCENT_ORANGE_500 -> accentColor = ContextCompat.getColor(context, R.color.orange_500)
            Constants.THEME_ACCENT_CYAN_500 -> accentColor = ContextCompat.getColor(context, R.color.cyan_500)
            Constants.THEME_ACCENT_GREEN_500 -> accentColor = ContextCompat.getColor(context, R.color.green_500)
            Constants.THEME_ACCENT_BROWN_400 -> accentColor = ContextCompat.getColor(context, R.color.brown_400)
            Constants.THEME_ACCENT_LIME_500 -> accentColor = ContextCompat.getColor(context, R.color.lime_500)
            Constants.THEME_ACCENT_PINK_300 -> accentColor = ContextCompat.getColor(context, R.color.pink_300)
            Constants.THEME_ACCENT_PURPLE_500 -> accentColor = ContextCompat.getColor(context, R.color.purple_500)
            Constants.THEME_ACCENT_TEAL_500 -> accentColor = ContextCompat.getColor(context, R.color.teal_500)
            Constants.THEME_ACCENT_YELLOW_500 -> accentColor = ContextCompat.getColor(context, R.color.yellow_500)
        }
        return accentColor
    }

    fun checkPermission(activity: ListActivity, permission: String) =
        ActivityCompat.checkSelfPermission(activity.baseContext, permission) == PackageManager.PERMISSION_GRANTED

    fun requestPermission(activity: ListActivity, permission: String, requestCode: Int) {
        ActivityCompat.requestPermissions(activity, arrayOf(permission), requestCode)
    }
}