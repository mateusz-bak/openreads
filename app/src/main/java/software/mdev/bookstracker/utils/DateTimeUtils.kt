package software.mdev.bookstracker.utils

import java.util.*

object DateTimeUtils {

    fun clearDateOfTime(orgDate: Long): Long {
        val date = Calendar.getInstance()
        date.timeInMillis = orgDate

        val year = date.get(Calendar.YEAR)
        val month = date.get(Calendar.MONTH)
        val day = date.get(Calendar.DAY_OF_MONTH)

        val dateWithoutTime = Calendar.getInstance()
        dateWithoutTime.timeInMillis = 0L
        dateWithoutTime.set(Calendar.YEAR, year)
        dateWithoutTime.set(Calendar.MONTH, month)
        dateWithoutTime.set(Calendar.DAY_OF_MONTH, day)
        dateWithoutTime.set(Calendar.HOUR, 0)
        dateWithoutTime.set(Calendar.MINUTE, 0)
        dateWithoutTime.set(Calendar.SECOND, 0)
        dateWithoutTime.set(Calendar.MILLISECOND, 0)

        return dateWithoutTime.timeInMillis
    }
}